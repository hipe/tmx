"""produce a stream of command objects given a directory.

the name of this magnetic is more nominal/aspirational than it is actual:

  - "nominal": we don't actually pass a directory (as a path (string)) as
    the argument. we pass a python module rather than a directory (string)
    because it takes much less hacking and finagling of the python import
    system if we just use its import system instead starting from a
    directory (string) and trying to get imported modules from that.
    HOWEVER we maintain the name "directory" in the name of this magnetic
    because we want it to be clear that that is the semantic intention of
    the magnet.

  - "aspirational": whether or not command files are loaded eagerly or
    lazily is something we want to be buried deep within the system..
"""

def SELF(collection_module):
    # (indented 2x anticipating possible upgrade to a class-based magnetic)

        _dir_path = _dir_path_via_module(collection_module)
        _gen = _generator_via_dir_path(_dir_path)
        return _final_stream_via_generator(_gen, collection_module)

def _final_stream_via_generator(gen, collection_module):
    import importlib
    head_s = collection_module.__name__ + '.'  # DOT
    def _money(posix_path):
        stem = posix_path.stem
        _import_this = head_s + stem
        _mod = importlib.import_module(_import_this)
        return _command_via_module(_mod, stem)
    return( _money(x) for x in gen )

def _command_via_module(mod, stem):
    from game_server._magnetics.command_via_parameter_stream import SELF as cmd
    return cmd(
      name = stem,
      command_module = mod,
    )

def _generator_via_dir_path(dir_path):
    from pathlib import Path
    p = Path(dir_path)
    return p.glob('*.py')

def _dir_path_via_module(collection_module):
    s_a = collection_module.__path__._path  # #todo
    if 1 != len(s_a): cover_me('more than one path element')
    return s_a[0]

# #born.