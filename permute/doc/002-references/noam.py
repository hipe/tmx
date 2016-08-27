def cross(*args):
    if not args: return [[]]
    c = cross(*args[1:])
    return reduce(lambda a,b: a+b, map(lambda csub: map(lambda elem: [elem]+csub, args[0]), c), [])


print cross(["black", "white", "asian"], ["coder", "barista"])
