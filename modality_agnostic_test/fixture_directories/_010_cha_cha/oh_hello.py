PARAMETERS = None


class Command:
    def __init__(self, _listener):
        self.__listener = _listener

    def execute(self):
        def f(style):
            _ = style.em('world')
            yield f"hello {_}!"
        self.__listener('info', 'expression', f)
