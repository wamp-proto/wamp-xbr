import json
import os
import posixpath
import re
from collections import OrderedDict
from itertools import takewhile
from antlr4 import FileStream, CommonTokenStream, ParseTreeWalker
from antlr4.tree.Tree import TerminalNodeImpl
from peewee import Model, CharField, TextField, SqliteDatabase
from .SolidityLexer import SolidityLexer
from .SolidityParser import SolidityParser
from .SolidityListener import SolidityListener

db = SqliteDatabase(':memory:')


class SolidityObject(Model):
    objtype = CharField()
    file = CharField()
    signature = CharField()
    name = CharField(null=True)
    paramtypes = CharField(null=True)
    contract_name = CharField(null=True)
    docs = TextField(default='')

    class Meta:
        database = db


def remove_prefix(text, prefix):
    # https://stackoverflow.com/a/16891418
    if text.startswith(prefix):
        return text[len(prefix):]
    return text


def build_source_registry(app):
    db.connect()
    db.create_tables((SolidityObject,))

    lookup_path = app.env.config.autodoc_lookup_path

    for root, dirs, files in os.walk(lookup_path):
        for name in files:
            if os.path.splitext(name)[1].lower() == '.sol':
                parse_sol(os.path.join(root, name), relsrcpath=remove_prefix(
                    posixpath.join(
                        posixpath.relpath(root, lookup_path),
                        name),
                    './'))


def teardown_source_registry(app, exception):
    db.close()


tag_re = re.compile(
    r''' @ (\w+)
        \s+
        ( [^@]+ (?: (?: (?<! \s) @ | @ \s) [^@]+)* )
    ''',
    re.VERBOSE | re.MULTILINE | re.DOTALL
)

param_re = re.compile(
    r'(\S*)\s*(.*)',
    re.MULTILINE | re.DOTALL
)


def get_docs_from_comments_for_obj(ctx):
    rawlines = []

    for comment in ctx.parser._input.getHiddenTokensToLeft(
        ctx.start.tokenIndex
    ) or ():
        if comment.text.startswith('///'):
            rawlines.append(comment.text[3:].strip())
        elif comment.text.startswith('/**'):
            for rawline in comment.text[3:-2].splitlines():
                rawlines.append(rawline.strip().lstrip('*').lstrip())

    rawdocs = '\n'.join(rawlines)

    doclines = []
    options = []

    def demux_and_append_docs(docs):
        docs = docs.strip()
        if docs:
            for line in docs.splitlines():
                if line.startswith(':'):
                    options.append(line)
                else:
                    doclines.append(line)

    def prep_payload_docs(docs):
        docs = docs.strip()
        lines = docs.splitlines()
        if len(lines) == 1:
            lines[0] = remove_prefix(lines[0], '-').lstrip()
        # HACK?: indent after first line
        return '\n   '.join(lines)

    for tagmatch in tag_re.finditer(rawdocs):
        tagname, tagpayload = tagmatch.groups()

        if tagname == 'dev':
            demux_and_append_docs(tagpayload)
        elif tagname == 'param':
            pmatch = param_re.fullmatch(tagpayload)
            pname, pdocs = pmatch.groups()
            options.append(':{} {}: {}'.format(
                tagname, pname,
                prep_payload_docs(pdocs),
            ))
        elif tagname == 'return':
            try:
                returns = json.loads(tagpayload, object_pairs_hook=OrderedDict)
                for ret_name, ret_docs in returns.items():
                    options.append(':{} {}: {}'.format(
                        tagname, ret_name,
                        prep_payload_docs(ret_docs)))
            except json.JSONDecodeError:
                options.append(':{}: {}'.format(
                    tagname, prep_payload_docs(tagpayload)))
        else:
            options.append(':{}: {}'.format(
                tagname, prep_payload_docs(tagpayload)))

    moredocs = demux_and_append_docs(tag_re.sub('', rawdocs))

    if moredocs:
        doclines.append(moredocs)

    return '\n\n'.join(filter(lambda x: x,
                              map('\n'.join, (doclines, options))))


def format_ctx_list(ctx_list):
    if ctx_list is None:
        return ''

    return '(' + ', '.join(
        ' '.join(
            child.getText()
            for child in pctx.getChildren())
        for pctx in ctx_list) + ')'


class DefinitionsRecorder(SolidityListener):
    def __init__(self, source_unit_name):
        self.current_contract_name = None
        self.source_unit_name = source_unit_name

    def enterContractDefinition(self, ctx):
        name = ctx.identifier().getText()

        if self.current_contract_name is not None:
            raise RuntimeError('trying to enter {} while already in {}'.format(
                name,
                self.current_contract_name))

        objtype = ctx.start.text

        signature = ' '.join((
            name,
            *(ctx.inheritanceSpecifier() and
                ('is', ', '.join(
                    node.getText()
                    for node in ctx.inheritanceSpecifier())))
        ))

        self.current_contract_name = name

        SolidityObject.create(
            objtype=objtype,
            file=self.source_unit_name,
            signature=signature,
            name=name,
            contract_name=None,
            docs=get_docs_from_comments_for_obj(ctx),
        )

    def exitContractDefinition(self, ctx):
        self.current_contract_name = None

    def enterStateVariableDeclaration(self, ctx):
        signature = ' '.join(
            child.getText() for child in takewhile(
                lambda child: child.getText() not in ('=', ';'),
                ctx.getChildren(),
            )
        )

        SolidityObject.create(
            objtype='statevar',
            file=self.source_unit_name,
            signature=signature,
            name=ctx.identifier().getText(),
            contract_name=self.current_contract_name,
            docs=get_docs_from_comments_for_obj(ctx),
        )

    def add_function_like_to_db(self, ctx):
        name = (ctx.identifier().getText()
                if hasattr(ctx, 'identifier')
                and ctx.identifier() is not None else None)

        if hasattr(ctx, 'parameterList') and ctx.parameterList() is not None:
            params = ctx.parameterList().parameter()
        elif hasattr(ctx, 'eventParameterList'):
            params = ctx.eventParameterList().eventParameter()
        else:
            params = None

        if params is None:
            paramtypes = None
        else:
            paramtypes = ','.join(param.typeName().getText()
                                  for param in params)

        params_str = format_ctx_list(params)

        signature = ' '.join((
            ('' if name is None else name) + params_str,
            *(
                ('{}{}'.format(
                    child.identifier().getText(),
                    format_ctx_list(child.expressionList().expression()),
                ) if isinstance(
                    child,
                    SolidityParser.ModifierInvocationContext,
                ) and child.expressionList() is not None else
                    child.getText()
                    for child in ctx.modifierList().getChildren())
                if hasattr(ctx, 'modifierList') else
                ()
            ),
            *(
                (ctx.AnonymousKeyword().getText(),)
                if hasattr(ctx, 'AnonymousKeyword')
                and ctx.AnonymousKeyword() is not None else
                ()
            ),
            *(
                ('{} {}'.format(
                    ctx.returnParameters().start.text, format_ctx_list(
                        ctx.returnParameters().parameterList().parameter())),)
                if hasattr(ctx, 'returnParameters')
                and ctx.returnParameters() is not None
                else
                ()
            ),
        ))

        SolidityObject.create(
            objtype=ctx.start.text,
            file=self.source_unit_name,
            signature=signature,
            name=name,
            paramtypes=paramtypes,
            contract_name=self.current_contract_name,
            docs=get_docs_from_comments_for_obj(ctx),
        )

    enterConstructorDefinition = add_function_like_to_db
    enterFunctionDefinition = add_function_like_to_db
    enterModifierDefinition = add_function_like_to_db
    enterEventDefinition = add_function_like_to_db

    def enterStructDefinition(self, ctx):
        docs = get_docs_from_comments_for_obj(ctx)

        signature = ' '.join((
            ctx.start.text,
            ctx.identifier().getText(),
        ))

        members = tuple(
            ' '.join(
                child.getText()
                for child in vdctx.getChildren()
            )
            for vdctx in ctx.variableDeclaration()
        )

    def enterEnumDefinition(self, ctx):
        docs = get_docs_from_comments_for_obj(ctx)

        signature = ' '.join((
            ctx.start.text,
            ctx.identifier().getText(),
        ))

        members = tuple(
            enum_val.getText()
            for enum_val in ctx.enumValue()
        )


def parse_sol(srcpath, relsrcpath):
    src = FileStream(srcpath, encoding='utf8')
    lexer = SolidityLexer(src)
    stream = CommonTokenStream(lexer)
    parser = SolidityParser(stream)
    tree = parser.sourceUnit()
    recorder = DefinitionsRecorder(relsrcpath)
    walker = ParseTreeWalker()
    walker.walk(recorder, tree)
