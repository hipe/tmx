def sanity():
    raise Exception('assumption failed')


lazy = 'soon'


@lazy
def writable_tmpdir():
    from os import path as os_path
    return os_path.join(os_path.dirname(__file__), 'writable-tmpdir')

# #abstracted: mostly copy-pasted
