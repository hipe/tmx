import re

# ==== BEGIN SYNC STUFF ======================================================


# ==== END SYNC STUFF ========================================================


def normal_structs_via_line_record_structs(structs):

    most_recent_date_string = None
    most_recent_time_string = None
    message_list = []
    last_significant_lineno = None

    def has_pending():
        return len(message_list)

    def flush():
        assert(most_recent_date_string)
        assert(most_recent_time_string)
        assert(len(message_list))

        msg_strings = tuple(message_list)
        message_list.clear()
        return _NormalStruct(
                date_string=most_recent_date_string,
                time_string=most_recent_time_string,
                message_strings=msg_strings, lineno=last_significant_lineno)

    def at():
        return f" at line {sct.lineno}"

    for sct in structs:

        ds = sct.date_string
        ts = sct.time_string
        ms = sct.message_string

        assert(len(ms))  # #here1

        if ds is None:
            if ts is None:
                if most_recent_time_string is None:
                    raise _MyExe("supplemental message w/o first msg" + at())
            else:
                if most_recent_date_string is None:
                    raise _MyException("date must be somewhere above" + at())

                if has_pending():
                    yield flush()

                most_recent_time_string = ts
                last_significant_lineno = sct.lineno
        else:
            if ts is None:
                raise _MyException("datestamp without timestamp?" + at())

            if has_pending():
                yield flush()

            most_recent_date_string = ds
            most_recent_time_string = ts
            last_significant_lineno = sct.lineno

        message_list.append(ms)  # #here1

    if has_pending():  # should be true always except for empty files
        yield flush()


class _NormalStruct:
    def __init__(self, date_string, time_string, message_strings, lineno):
        self.date_string = date_string
        self.time_string = time_string
        self.message_strings = message_strings
        self.lineno = lineno


def line_record_structs_via_lines(lines):
    class LineCounter():
        def __init__(self):
            self.count = 0

        def __call__(self):
            self.count += 1
            return self.count

    inc = LineCounter()
    return (_line_record_struct_via_line(line, inc()) for line in lines)


def _line_record_struct_via_line(line, lineno):

    def at():
        return f' at line {lineno} - {line[0:-1]}'

    md = _line_rx.match(line)
    if md is None:
        raise _MyException(f"line must be at least {_min_width} long" + at())

    day_cell, time_cell, message_cell = md.groups()

    md = _day_cell_rx.match(day_cell)
    if md is None:
        raise _MyException(f'must be mm-dd: {repr(day_cell)} ' + at())
    date_string = md[1]

    md = _time_cell_rx.match(time_cell)
    if md is None:
        raise _MyException(f'must be hh:mm:ss {repr(day_cell)} ' + at())
    time_string = md[1]

    md = _message_cell_rx.match(message_cell)
    msg = md and md[1].strip()
    if not msg and len(msg):  # #here1
        raise _MyException("there must be some message " + at())

    return _LineRecordStruct(
            date_string=date_string, time_string=time_string,
            message_string=msg, lineno=lineno)


_seven = 7
_nine = 9
_line_rx = re.compile(f'^(.{{{_seven}}})(.{{{_nine}}})(.+)\\n\\Z')
_min_width = _seven + _nine + 1


_day_cell_rx = re.compile(r'^[ ]{2}(?:(\d\d-\d\d)|[ ]{5})\Z')
_time_cell_rx = re.compile(r'^[ ]{1}(?:(\d\d:\d\d:\d\d)|[ ]{8})\Z')
_message_cell_rx = re.compile(r'^[ ]{2}(.+)\Z')  # #here1


class _LineRecordStruct:

    def __init__(self, date_string, time_string, message_string, lineno):
        self.date_string = date_string
        self.time_string = time_string
        self.message_string = message_string
        self.lineno = lineno


class _MyException(RuntimeError):
    pass


_MyExe = _MyException


if __name__ == '__main__':
    from sys import stdout, stderr, argv
    prog_name, *args = argv
    so = stdout.write
    se = stderr.write

    def usage():
        se(f'usage: {prog_name} <filename>\n')

    if len({'-h', '--help'} & set(args)):
        usage()
        se('description: attempt to parse a timestamps file\n')
        exit(0)

    filename, = args  # ..

    with open(filename) as lines:
        _ = line_record_structs_via_lines(lines)
        for o in normal_structs_via_line_record_structs(_):
            so(f"{o.date_string} {o.time_string} (line {o.lineno}):\n")
            count = 0
            for msg in o.message_strings:
                count += 1
                so(f"  msg {count}:  {msg}\n")
# #born.
