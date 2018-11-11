import re
from collections import namedtuple
from docutils import nodes
from sphinx import addnodes
from sphinx.directives import ObjectDescription
from sphinx.domains import Domain, ObjType
from sphinx.locale import _
from sphinx.roles import XRefRole
from sphinx.util.docfields import Field, GroupedField, TypedField
from sphinx.util.nodes import make_refnode

SolObjFullName = namedtuple(
    'SolObjFullName', ('name', 'obj_path', 'param_types'))


def fullname2namepath(fullname):
    return '.'.join(fullname.obj_path + (fullname.name,))


def fullname2id(fullname):
    return fullname2namepath(fullname) + (
        '' if fullname.param_types is None else
        '(' + ','.join(fullname.param_types) + ')'
    )


class SolidityObject(ObjectDescription):
    def add_target_and_index(self, fullname, sig, signode):
        if fullname not in self.state.document.ids:
            signode['ids'].append(fullname2id(fullname))
            self.state.document.note_explicit_target(signode)
            domaindata = self.env.domaindata['sol']
            if fullname in domaindata:
                self.state_machine.reporter.warning(
                    'duplicate {type} description of {fullname}, '
                    'other instance in {otherloc}'.format(
                        type=self.objtype,
                        fullname=fullname,
                        otherloc=domaindata[fullname][0],
                    ), line=self.lineno)
                domaindata[fullname] = (self.env.docname, self.objtype)

        indextext = '{} ({})'.format(fullname2namepath(fullname), _(self.objtype))
        if (self.objtype == 'constructor' or
                self.objtype == 'function' and fullname.name == '<fallback>'):
            glossary_classifier = (fullname.obj_path or ('?',))[-1][0].upper()
        else:
            glossary_classifier = fullname.name[:1].upper()
        self.indexnode['entries'].append((
            'single',
            indextext,
            fullname2id(fullname),
            False,
            glossary_classifier,
        ))

    def before_content(self):
        if self.names:
            obj_path = self.env.ref_context.setdefault('sol:obj_path', [])
            obj_path.append(self.names.pop().name)

    def after_content(self):
        obj_path = self.env.ref_context.setdefault('sol:obj_path', [])
        try:
            obj_path.pop()
        except IndexError:
            pass


contract_re = re.compile(
    r'''\s* (\w+)  # name
        (?: \s+ is \s+
            (\w+ (?:\s*,\s* (?:\w+))*)  # parent contracts
        )? \s*''', re.VERBOSE)


class SolidityTypeLike(SolidityObject):
    def handle_signature(self, sig, signode):
        match = contract_re.fullmatch(sig)
        if match is None:
            raise ValueError

        name, parents_str = match.groups()
        parents = [] if parents_str is None else [
            p.strip()
            for p in parents_str.split(',')]

        signode += nodes.emphasis(text=self.objtype + ' ')
        signode += addnodes.desc_name(text=name)

        if len(parents) > 0:
            signode += nodes.Text(' is ' + ', '.join(parents))

        return SolObjFullName(
            name=name,
            obj_path=tuple(self.env.ref_context.get('sol:obj_path', [])),
            param_types=None,
        )


param_var_re = re.compile(
    r'''\s* ( [\w\s\[\]\(\)=>\.]+? ) # type
        (?: \s* \b (
            public | private | internal |
            storage | memory |
            indexed
        ) )? # modifier
        \s*(\b\w+)? # name
        \s*''', re.VERBOSE)


def normalize_type(type_str):
    type_str = re.sub(r'\s*(\W)', r'\1', type_str)
    type_str = re.sub(r'(\W)\s*', r'\1', type_str)
    type_str = re.sub(r'(\w)\s+(\w)', r'\1 \2', type_str)
    type_str = type_str.replace('mapping(', 'mapping (')
    type_str = type_str.replace('=>', ' => ')
    return type_str


class SolidityStateVariable(SolidityObject):
    def handle_signature(self, sig, signode):
        match = param_var_re.fullmatch(sig)

        if match is None:
            raise ValueError

        # normalize type string
        type_str, visibility, name = match.groups()

        if name is None:
            raise ValueError

        type_str = normalize_type(type_str)

        signode += addnodes.desc_type(text=type_str + ' ')

        if visibility is not None:
            signode += nodes.emphasis(text=visibility + ' ')

        signode += addnodes.desc_name(text=name)

        return SolObjFullName(
            name=name,
            obj_path=tuple(self.env.ref_context.get('sol:obj_path', [])),
            param_types=None,
        )


function_re = re.compile(
    r'''\s* (\w+)?  # name
        \s* \( ([^)]*) \)  # paramlist
        \s* ((?:\w+ \s* (?:\([^)]*\))? \s* )*)  # modifiers
        \s*''', re.VERBOSE)


def _parse_params(paramlist_str):
    params = addnodes.desc_parameterlist()

    if len(paramlist_str.strip()) == 0:
        return params, tuple()

    parammatches = [param_var_re.fullmatch(
        param_str) for param_str in paramlist_str.split(',')]

    if not all(parammatches):
        raise ValueError

    abi_types = []
    for parammatch in parammatches:
        atype, memloc, name = parammatch.groups()
        atype = normalize_type(atype)
        abi_types.append(atype + ('' if memloc != 'storage' else ' storage'))
        params += addnodes.desc_parameter(
            text=' '.join(filter(lambda x: x, (atype, memloc, name))))

    return params, tuple(abi_types)


modifier_re = re.compile(r'(\w+)(?:\s*\(([^)]*)\))?')


class SolidityFunctionLike(SolidityObject):
    doc_field_types = [
        TypedField('parameter', label=_('Parameters'),
                   names=('param', 'parameter', 'arg', 'argument'),
                   typenames=('type',)),
        TypedField('returnvalue', label=_('Returns'),
                   names=('return', 'returns'),
                   typenames=('rtype',)),
    ]

    def handle_signature(self, sig, signode):
        signode.is_multiline = True
        primary_line = addnodes.desc_signature_line(add_permalink=True)
        match = function_re.fullmatch(sig)
        if match is None:
            raise ValueError

        name, paramlist_str, modifiers_str = match.groups()

        if name is None:
            if self.objtype == 'constructor':
                name = 'constructor'
                primary_line += addnodes.desc_name(text=self.objtype)
            elif self.objtype == 'function':
                name = '<fallback>'
                primary_line += addnodes.desc_name(text=_('<fallback>'))
                primary_line += nodes.emphasis(text=' ' + self.objtype)
                if len(paramlist_str.strip()) != 0:
                    raise ValueError
            else:
                raise ValueError
        else:
            primary_line += nodes.emphasis(text=self.objtype + ' ')
            primary_line += addnodes.desc_name(text=name)

        params_parameter_list, param_types = _parse_params(paramlist_str)
        primary_line += params_parameter_list
        signode += primary_line

        if self.objtype == 'modifier' and len(modifiers_str.strip()) != 0:
            raise ValueError

        for match in modifier_re.finditer(modifiers_str):
            modname, modparams_str = match.groups()
            newline = addnodes.desc_signature_line()
            newline += nodes.Text(' ')  # HACK: special whitespace :/
            if modname in (
                'public', 'private',
                'external', 'internal',
                'pure', 'view', 'payable',
                'anonymous',
            ):
                newline += nodes.emphasis(text=modname)
                if modparams_str is not None:
                    raise ValueError
            elif modname == 'returns':
                newline += nodes.emphasis(text=modname + ' ')
                if modparams_str is not None:
                    newline += _parse_params(modparams_str)[0]
            else:
                newline += nodes.Text(modname)
                if modparams_str is not None:
                    modparamlist = addnodes.desc_parameterlist()
                    for modparam in modparams_str.split(','):
                        modparam = modparam.strip()
                        if modparam:
                            modparamlist += addnodes.desc_parameter(
                                text=modparam)
                    newline += modparamlist

            signode += newline

        if self.objtype not in ('function', 'event'):
            param_types = None

        return SolObjFullName(
            name=name,
            obj_path=tuple(self.env.ref_context.get('sol:obj_path', [])),
            param_types=param_types,
        )


class SolidityStruct(SolidityTypeLike):
    doc_field_types = [
        TypedField('member', label=_('Members'), names=(
            'member',), typenames=('type', )),
    ]


class SolidityEnum(SolidityTypeLike):
    doc_field_types = [
        GroupedField('member', label=_('Members'), names=('member',)),
    ]


class SolidityXRefRole(XRefRole):
    def process_link(self, env, refnode, has_explicit_title, title, target):
        # type: (BuildEnvironment, nodes.reference, bool, unicode, unicode) -> Tuple[unicode, unicode]  # NOQA
        """Called after parsing title and target text, and creating the
        reference node (given in *refnode*).  This method can alter the
        reference node and must return a new (or the same) ``(title, target)``
        tuple.
        """
        return title, target


class SolidityDomain(Domain):
    """Solidity language domain."""
    name = 'sol'
    label = 'Solidity'

    directives = {
        'contract':     SolidityTypeLike,
        'library':      SolidityTypeLike,
        'interface':    SolidityTypeLike,
        'statevar':     SolidityStateVariable,
        'constructor':  SolidityFunctionLike,
        'function':     SolidityFunctionLike,
        'modifier':     SolidityFunctionLike,
        'event':        SolidityFunctionLike,
        'struct':       SolidityStruct,
        'enum':         SolidityEnum,
    }

    roles = {
        'contract':     SolidityXRefRole(),
        'lib':          SolidityXRefRole(),
        'interface':    SolidityXRefRole(),
        'svar':         SolidityXRefRole(),
        'cons':         SolidityXRefRole(),
        'func':         SolidityXRefRole(),
        'mod':          SolidityXRefRole(),
        'event':        SolidityXRefRole(),
        'struct':       SolidityXRefRole(),
        'enum':         SolidityXRefRole(),
    }

    def resolve_xref(self, env, fromdocname, builder,
                     typ, target, node, contnode):
        # type: (BuildEnvironment, unicode, Builder, unicode, unicode, nodes.Node, nodes.Node) -> nodes.Node  # NOQA
        """Resolve the pending_xref *node* with the given *typ* and *target*.

        This method should return a new node, to replace the xref node,
        containing the *contnode* which is the markup content of the
        cross-reference.

        If no resolution can be found, None can be returned; the xref node will
        then given to the :event:`missing-reference` event, and if that yields no
        resolution, replaced by *contnode*.

        The method can also raise :exc:`sphinx.environment.NoUri` to suppress
        the :event:`missing-reference` event being emitted.
        """
