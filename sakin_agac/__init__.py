def pop_property(self, var):
    x = getattr(self, var)
    delattr(self, var)
    return x


def cover_me(msg=None):
    _use_msg = 'cover me' if msg is None else ('cover me - %s' % msg)
    raise _exe(_use_msg)


def sanity(s=None):
    _msg = 'sanity' if s is None else 'sanity: %s' % s
    raise _exe(_msg)


_exe = Exception

# #abstracted.
