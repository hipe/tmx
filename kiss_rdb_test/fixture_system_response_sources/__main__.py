def cli_for_production():
    from sys import stdout, stderr, argv
    exit(_CLI(None, stdout, stderr, argv))


def _CLI(sin, sout, serr, argv):
    from os.path import dirname
    here = dirname(__file__)
    from modality_agnostic.fixture_system_responses.CLI_support import func
    return func(sin, sout, serr, argv, here)


if True:
    cli_for_production()

# #born
