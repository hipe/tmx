# we are in a race to create this file as fast as possible
# Start: 10:07AM
# Compiles at: 11:03AM
# Feature complete at: 11:27AM


def directives_via_lines(lines, listener):
    try:
        fields = _fields_via_lines(lines, listener)
        for direc in _directives_via_fields(fields, listener):
            yield direc
    except _Stop:
        pass


func = directives_via_lines


def _directives_via_fields(fields, listener):

    # (popular FSA style #[#008.2])

    def from_beginning_state():
        yield if_directive('this_is_all'), move_and_retry(from_this_is_all)

    def from_this_is_all():
        yield if_field_value('in_a_temporary_directory'), begin_temp_dir_direc

    def from_temp_dir_files_state():
        yield if_a_directive_about_copying_files, add_file_copying_directive
        yield otherwise, pop_and_retry  # #here1

    def from_expect_run_this_script():
        yield if_directive('run_this_script'), store_and_pop('finish_init_tmpdir_with_this_script')  # noqa: E501
        yield otherwise, pop_and_retry

    def from_temp_dir_root_state():
        yield if_output_related_parameteric_directive, store_output_related_etc
        yield if_directive('this_is_the_command'), finish_lyfe

    def begin_temp_dir_direc():
        from .compound_directive_common_ import \
            Directive_called_FROM_TEMPDIR_ as klass
        store['compound_directive'] = klass()
        # (NOTE push *two* states on to stack so we can #here1. or do whatever)
        stack.append(from_temp_dir_root_state)
        stack.append(from_expect_run_this_script)
        stack.append(from_temp_dir_files_state)

    # == Business-specific if-else

    def if_a_directive_about_copying_files():
        if 'copy_these_files' == field_name:
            store['is_multiple'] = True
            return True
        if 'copy_this_file' == field_name:
            store['is_multiple'] = False
            return True

    def add_file_copying_directive():
        yn = store.pop('is_multiple')
        typ = 'copy_these_files' if yn else 'copy_this_file'  # meh
        direc = typ, field_value_string
        store['compound_directive'].file_copying_directives.append(direc)

    def if_output_related_parameteric_directive():
        if 'filter_the_following_output_through' == field_name:
            store['use_key'] = 'filter_the_output_through'
            return True
        if 'represent_the_following_as_this_command' == field_name:
            store['use_key'] = 'represent_as_this_command'
            return True

    def store_and_pop(k):
        def action():
            store['compound_directive'].receive_parametric_directive(
                k, field_value_string)
            stack.pop()
        return action

    def store_output_related_etc():
        k = store.pop('use_key')
        store['compound_directive'].receive_parametric_directive(
            k, field_value_string)

    def finish_lyfe():
        cd = store.pop('compound_directive')
        cd.receive_parametric_directive('this_is_the_command', field_value_string)  # noqa: E501
        cd.finish()
        return 'yield_this_and_return', ('compound_directive', cd)

    # == FSA Mechanics

    def if_directive(which):
        return lambda: (which == field_name)

    def if_field_value(string):
        return lambda: (string == field_value_string)

    def otherwise():
        return True

    def move_and_retry(state_function):
        def action():
            stack[-1] = state_function
            return ('retry',)
        return action

    def pop_and_retry():
        assert 0 < len(stack)
        stack.pop()
        return ('retry',)

    # ==

    def find_transition():
        for test, action in stack[-1]():
            yn = test()
            if yn:
                return action

        here = ': '.join((field_name, field_value_string))
        from_where = stack[-1].__name__.replace('_', ' ')
        xx(f"found no transition for \"{here}\" {from_where}")

    stack = [from_beginning_state]
    from . import StrictDict_ as cls
    store = cls()

    for field in fields:
        field_name = field.field_name
        field_value_string = field.field_value_string
        while True:  # while retrying
            action = find_transition()
            direc = action()
            if direc is None:
                break  # continue to the next token
            typ = direc[0]
            if 'retry' == typ:
                assert 1 == len(direc)
                continue
            assert 'yield_this_and_return' == typ
            sexp, = direc[1:]
            yield sexp
            return
    from_where = stack[-1].__name__.replace('_', ' ')
    xx(f'premature end of input in file {from_where}')


def _fields_via_lines(lines, listener):
    from kiss_rdb.storage_adapters_.rec import ErsatzScanner as cls
    scanner = cls(lines)
    while True:
        blk = scanner.next_block(listener)
        assert blk

        if blk.is_separator_block:
            continue

        if blk.is_field_line:
            yield blk
            continue

        assert blk.is_end_of_file
        break


class _Stop(RuntimeError):
    pass


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
