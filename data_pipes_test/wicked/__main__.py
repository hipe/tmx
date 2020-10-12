def _wicked_definition():
    yield 'here_file', __file__
    yield 'templates_dir', '../../kiss_rdb/test_support/wicked_templates'
    yield 'template', '001-first-ever.py'
    yield 'file', 'test_1015_csv/test_1007_intro.py'
    yield 'file', 'test_1040_json/test_1040_intro.py'


if '__main__' == __name__:
    from modality_agnostic.wicked import build_CLI as func
    cli = func(_wicked_definition())
    import sys as o
    exit(cli(o.stdin, o.stdout, o.stderr, o.argv, None))

# #born
