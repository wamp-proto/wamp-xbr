import re
from sphinx.ext.autodoc import (
    ALL, Documenter,
    bool_option, members_option, members_set_option)
from .domain import SolidityDomain
from .sourceregistry import SolidityObject


class SolidityObjectDocumenter(Documenter):
    domain = 'sol'
    option_spec = {
        'members': members_option,
        'undoc-members': bool_option,
        'noindex': bool_option,
        'exclude-members': members_set_option,
    }

    def get_sourcename(self):
        return '{}:docstring of {} {}'.format(
            self.object.file,
            self.object.objtype,
            '.'.join(filter(lambda x: x,
                            (self.object.contract_name,
                             self.object.name))),
        )

    def add_directive_header(self):
        domain = getattr(self, 'domain', 'sol')
        directive = getattr(self, 'directivetype', self.objtype)
        sourcename = self.get_sourcename()

        self.add_line('.. {domain}:{directive}:: {signature}'.format(
            domain=domain, directive=directive, signature=self.object.signature
        ), sourcename)

        if self.options.noindex:
            self.add_line(u'   :noindex:', sourcename)

    def add_content(self, more_content):
        """Add content from source docs and user."""
        sourcename = self.get_sourcename()

        if self.object.docs:
            self.add_line('', sourcename)
            for line in self.object.docs.splitlines():
                self.add_line(line, sourcename)

        # add additional content (e.g. from document), if present
        if more_content:
            self.add_line('', sourcename)
            for line, src in zip(more_content.data, more_content.items):
                self.add_line(line, src[0], src[1])

    def document_members(self, all_members=False):
        # type: (bool) -> None
        """Generate reST for member documentation.

        If *all_members* is True, do all members, else those given by
        *self.options.members*.
        """
        sourcename = self.get_sourcename()

        want_all = all_members or self.options.members is ALL

        if not want_all and not self.options.members:
            return

        expressions = [
            SolidityObject.file == self.object.file,
            SolidityObject.contract_name == self.object.name
        ]

        if not want_all:
            members_inset = set()
            should_include_fallback = False
            should_include_constructor = False

            for member in self.options.members:
                if member == '<fallback>':
                    should_include_fallback = True
                elif member == 'constructor':
                    should_include_constructor = True
                elif member:
                    members_inset.add(member)

            expr = SolidityObject.name.in_(members_inset)
            if should_include_fallback:
                expr |= (SolidityObject.objtype == 'function') & (SolidityObject.name.is_null(True))
            if should_include_constructor:
                expr |= (SolidityObject.objtype == 'constructor') & (SolidityObject.name.is_null(True))

            expressions.append(expr)

        if self.options.exclude_members:
            should_exclude_fallback = False
            should_exclude_constructor = False

            if '<fallback>' in self.options.exclude_members:
                self.options.exclude_members.remove('<fallback>')
                should_exclude_fallback = True
            if 'constructor' in self.options.exclude_members:
                self.options.exclude_members.remove('constructor')
                should_exclude_constructor = True

            expr = SolidityObject.name.not_in(self.options.exclude_members)

            subexpr = SolidityObject.name.is_null(True)
            if should_exclude_fallback:
                subexpr &= (SolidityObject.objtype != 'function')
            if should_exclude_constructor:
                subexpr &= (SolidityObject.objtype != 'constructor')
            expr |= subexpr

            expressions.append(expr)

        for member in SolidityObject.select().where(*expressions):
            self.add_line('', sourcename)
            full_mname = '{file}:{contract}{name}{paramtypes}'.format(
                file=member.file,
                contract='' if member.contract_name is None
                else member.contract_name + '.',
                name=member.name or '',
                paramtypes='' if member.paramtypes is None
                else '(' + member.paramtypes + ')',
            )
            documenter = all_solidity_documenters[member.objtype](
                self.directive, full_mname, self.indent)
            documenter.generate(all_members=True)

    def generate(self, more_content=None, all_members=False):
        # type: (Any, str, bool, bool) -> None
        """Generate reST for the object given by *self.name*, and possibly for
        its members.

        If *more_content* is given, include that content.
        If *all_members* is True, document all members.
        """
        directive = getattr(self, 'directivetype', self.objtype)

        # parse components out of name
        (file, _, namepath) = self.name.rpartition(':')
        (contract_name, _, fullname) = namepath.partition('.')
        (name, _, paramtypes) = fullname.partition('(')

        # normalize components
        name = name.strip() or None

        if directive in ('contract', 'interface', 'library') and name is None:
            name = contract_name
            contract_name = None

        paramtypes = ','.join(ptype.strip() for ptype in paramtypes.split(','))
        paramtypes = re.sub(r'\s+', ' ', paramtypes)
        if paramtypes.endswith(')'):
            paramtypes = paramtypes[:-1]

        # build query
        expressions = [
            SolidityObject.objtype == directive,
            SolidityObject.name == name,
        ]

        if file:
            expressions.append(SolidityObject.file == file)
        if contract_name:
            expressions.append(SolidityObject.contract_name == contract_name)
        if paramtypes:
            expressions.append(SolidityObject.paramtypes == paramtypes)

        # get associated object
        query = SolidityObject.select().where(*expressions)
        sol_objects = tuple(query)
        if len(sol_objects) == 0:
            print([(str(expr.lhs.column_name), expr.rhs) for expr in expressions])
            raise ValueError('{} {} could not be found via query:\n{}'.format(
                directive, self.name, ',\n'.join(
                    '  ' + str(expr.lhs.column_name) +
                    str(expr.op) + expr.rhs
                    for expr in expressions
                )))
        elif len(sol_objects) > 1:
            raise ValueError('multiple candidates for {} {} found:\n{}'.format(
                directive, self.name,
                '\n'.join('  ' + obj.signature for obj in sol_objects)))

        self.object = sol_objects[0]

        # begin rendering output
        sourcename = self.get_sourcename()

        # make sure that the result starts with an empty line.  This is
        # necessary for some situations where another directive preprocesses
        # reST and no starting newline is present
        self.add_line('', sourcename)

        # generate the directive header and options, if applicable
        self.add_directive_header()

        # make sure content is indented
        # TODO: consider adding a source unit directive
        self.indent += self.content_indent

        # add all content (from docstrings, attribute docs etc.)
        self.add_content(more_content)

        # document members, if possible
        if directive in ('contract', 'interface', 'library'):
            self.add_line('', sourcename)
            self.document_members(all_members)


def method_stub(self):
    raise NotImplementedError


for method_name in (
    'parse_name', 'import_object', 'get_real_modname', 'check_module',
    'format_args', 'format_name', 'format_signature', 'get_doc', 'process_doc',
    'get_object_members', 'filter_members',
):
    setattr(SolidityObjectDocumenter, method_name, method_stub)


all_solidity_documenters = dict(
    (objtype, type(
        objtype.capitalize() + 'Documenter',
        (SolidityObjectDocumenter,),
        {
            'objtype': 'sol' + objtype,
            'directivetype': objtype,
        }
    )) for objtype in SolidityDomain.directives.keys()
)
