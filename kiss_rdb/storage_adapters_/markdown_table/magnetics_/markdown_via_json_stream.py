#!/usr/bin/env python3 -W error::Warning::0

"""produce the markdown (custom format) for Dr. K Hong's excellent thing

(this is the content-consumer of the producer/consumer pair)
"""


"""
internal discussion:

this script has a different purpose now than it did when it was born.

when it was born, we didn't have a synchronizer yet, so we didn't have a good
way of detecting changes to the far collection.

our solution to that was to keep this script around, and to keep in version
control a frozen snapshot of the output of this script. we could check for
significant changes in the remote webpage by periodically re-running this
script and comparing the new output against the frozen snapshot. doing this
would reveal changes in the "constituency" of the collection (that is, the
set membership of names; also order).

for one thing, this was sub-optimal because it required that we keep this
garish file around. for another thing, if we detected changes (new items)
in the remote thing, we would have to edit them into our working copy of
the markdown file manually, while also updating the snapshot.

now with the synchronizer, we can achieve this same ends through a more
reasonable arrangement. whereas the above arrangement works from *one*
collection (the far) one, the synchronizer looks at *two* (near and far).

so although this script isn't in theory necessary an longer, we still
keep it around because while refactoring out its 'old-way' code we ended
up pioneering a new facility for resolving input from a CLI, one that
could undergird our data plumbing generally..

.#[#410.N]
"""


def _these():
    def o(s):
        a.append(s + '\n')
    a = []
    o('| Lesson | Read | Emoji | Notes |')
    o('|----|:---|:---|---:|')
    o('| placeholder |◻️|◻️||')  # this expresses nothing but min widths
    return tuple(a)


def _my_CLI(parsed_arg, program_name, sout, serr):

    from script_lib.magnetics import listener_via_resources as o
    listener = o.listener_via_stderr(serr)

    from script.markdown_document_via_json_stream import (
            collection_identifier_via_parsed_arg_ as _,
            )

    _far_collection = _(parsed_arg)

    _near_collection = _these()

    def map_far_objects(obj):
        obj['read'] = '◻️'
        obj['emoji'] = '◻️'
        return obj

    import script.sync as sync
    _rc = sync.OpenNewLines_via_Sync_(
            far_collection=_far_collection,
            near_collection=_near_collection,
            far_format=None,
            near_format='markdown_table',
            custom_mapper_OLDSCHOOL=map_far_objects,
            listener=listener)
    f = sout.write
    with _rc as lines:
        for line in lines:
            f(line)
    return 0  # ..


_my_CLI.__doc__ = __doc__


def _CLI(sin, sout, serr, argv):  # #testpoint

    from script_lib.magnetics import (
            common_upstream_argument_parser_via_everything)

    _exitstatus = common_upstream_argument_parser_via_everything(
            cli_function=_my_CLI,
            std_tuple=(sin, sout, serr, argv),
            argument_moniker='<script>',
            ).execute()
    return _exitstatus


if __name__ == '__main__':
    import sys as o
    o.path.insert(0, '')
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv)
    exit(_exitstatus)

# #history-A.1: (can be temporary) used to use putser_via_IO
# #history-A.1: big refactor, sunsetted file of origin
# #born: abstracted from sibling
