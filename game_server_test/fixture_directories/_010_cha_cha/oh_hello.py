PARAMETERS = None

class Command:
    def __init__(self, _listener):
        self.__listener = _listener

    def execute(self):
        def f(o, style):
            o('hello ' + style.em('world') + '!')
        self.__listener('info', 'expression', f)
