def close_issue(readme, eid, listener, opn=None):
    def main():
        iden = parse_identifier()
        from . import coll_impl_via_ as func
        ci = func(readme, listener, opn)
        edit = (('update_attribute', 'main_tag', '#hole'),
                ('update_attribute', 'content', ''))
        two = ci.update_entity_as_storage_adapter_collection(
            iden, edit, throwing_listener)
        if two is None:
            return
        before, after = two

        def lines():
            yield f"BEFORE: {before.to_line()}"
            yield f"AFTER:  {after.to_line()}"
        listener('info', 'expression', 'closed_issue', lines)

    def parse_identifier():
        # Give eid's w/o leading '[', '#' a '#' so we can use cust iden class
        use_eid = f"#{eid}" if re.match(r'^(?!=\[|#)', eid) else eid
        from . import build_identifier_parser_ as func
        return func(throwing_listener)(use_eid)

    def throwing_listener(sev, *rest):
        listener(sev, *rest)
        if 'error' == sev:
            raise stop()

    class stop(RuntimeError):
        pass

    import re
    try:
        main()  # no result except emissions!
    except stop:
        pass


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))

# #born
