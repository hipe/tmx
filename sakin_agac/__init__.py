def pop_property(self, var):
    x = getattr(self, var)
    delattr(self, var)
    return x


def cover_me(s):
    raise _exe('cover me: {}'.format(s))


def sanity(s=None):
    _msg = 'sanity' if s is None else 'sanity: %s' % s
    raise _exe(_msg)


_exe = Exception

# #abstracted.