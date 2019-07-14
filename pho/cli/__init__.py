import click
import os
import sys


_env_var_prefix = 'PHO'
_CONTEXT_SETTINGS = {'auto_envvar_prefix': _env_var_prefix}


def lazy(f):
    is_first_call = True
    x = None

    def use_f():
        nonlocal is_first_call
        nonlocal x
        if is_first_call:
            is_first_call = False
            x = f()
        return x
    return use_f


class _ComplexCLI(click.MultiCommand):

    def list_commands(self, ctx):
        return (cmd.command_name for cmd in _command_branch().sorted)

    def get_command(self, ctx, name):

        dct = _command_branch().command_via_name
        if name not in dct:
            return

        _module_name = _commands_module_name_for(dct[name].module_tail)
        mod = __import__(_module_name, None, None, ['cli'])
        return mod.cli


class _Context:

    def __init__(self):
        self.user_provided_collection_path = None
        self._do_express_verbose = False
        self.DID_ERROR = False

    def build_structure_listener(self):
        def did_error():
            self.DID_ERROR = True
        return _build_structure_listener(did_error, self._do_express_verbose)


pass_context = click.make_pass_decorator(_Context, ensure=True)


def _build_structure_listener(did_error, do_express_verbose):
    def listener(*a):
        mood, shape, *_, payloader = a

        if 'info' == mood:
            if not do_express_verbose:
                return
            key = 'message'
            write_to = sys.stderr
        elif 'error' == mood:
            did_error()
            key = 'reason'
            write_to = sys.stderr
        else:
            assert(False)

        assert('structure' == shape)

        sct = payloader()
        _msg = sct[key]
        click.echo(_msg, file=write_to)

    return listener


# ==

@click.command(cls=_ComplexCLI, context_settings=_CONTEXT_SETTINGS)
@click.option(
        '--collection-path',
        metavar='PATH',
        help=(
            'The path to the directory with the fragments '
            '(the directory that contains the `entities` directory)'
            f' (or set the env var {_env_var_prefix}_COLLECTION_PATH)'
            ),
        )
@click.option(
        '-v', '--verbose',
        is_flag=True,
        help='Express informational emissions where available.',
        )
@pass_context
def cli_for_production(
        ctx,
        collection_path,
        verbose,
        ):
    '''experiments in generating documents from "fragments"'''

    ctx.user_provided_collection_path = collection_path
    ctx._do_express_verbose = verbose


# ==


@lazy
def _command_branch():
    return _CommandBranch()


class _CommandBranch:

    def __init__(self):
        _ = self.__unordered_commands()
        self.sorted = sorted(_, key=lambda cmd: cmd.command_name)
        self.command_via_name = {cmd.command_name: cmd for cmd in self.sorted}

    def __unordered_commands(self):
        for fn in os.listdir(_commands_directory()):
            if not fn.endswith('.py'):
                continue
            module_tail = fn[0:-3]
            yield _Command(
                    command_name=module_tail.replace('_', '-'),
                    module_tail=module_tail)


class _Command:

    def __init__(self, module_tail, command_name):
        self.module_tail = module_tail
        self.command_name = command_name


def _commands_directory():
    return os.path.join(_mono_repo_dir, 'pho', 'cli', 'commands')


def _commands_module_name_for(name):
    return f'pho.cli.commands.{name}'


    o = os.path

# #born.
