"""produce the markdown (custom format) for Dr. K Hong's excellent thing

(this is the content-consumer of the producer/consumer pair)
"""

# (above may be used for UI doc. below is for development.)


"""
# discussion about this moment (TEMPORARY SECTION)

At the moment this script contains a "bad reach" because it imports the
syncronizer from "data-pipes", which creates a circular dependency.
(We plan to make "data-pipes" heavily dependent on the host package.
We don't want there to be any dependency in the reverse direction, otherwise
they aren't really modularized at all.)

So normally we would want to house this script in that package not this one.
However, the current package is now the "patron saint" of markdown, so there
is a bit of a taxonomic conflict of interest. Here is our answer to this:

At the moment we are leaving this "bad reach" in because we plan to factor
it out very soon. Using "synchronization" to accomplish pass-thru translation
is either good design or a novelty/smell depending. In our case it becomes a
smell given when we said in the previous paragraph.

As such we will grow the host package (or perhaps data-pipes) to support
generalized pass-thru translation between storage (format) adapters.




# history overview (most recent at top)

* .#history-A.2: re-house in kiss-rdb. (will move or rename again soon.)
* .#history-A.1: rearch to use synchronizer
* .#born: the pre-synchronizer era: keep "frozen snapshots" to detect change




# full narrative

This script has evolved with the changing scope and capabilities of its home.



## the "frozen snapshot" technique and what was wrong with it

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
"""
# #[#874.5] file used to be executable script and may need further changes
# #[#874.8] file generates mardown the old way and may need to be the new way


def _these():
    def o(s):
        a.append(s + '\n')
    a = []
    o('| Lesson | Read | Emoji | Notes |')
    o('|----|:---|:---|---:|')
    o('| placeholder |◻️|◻️||')  # this expresses nothing but min widths
    return tuple(a)


def _my_CLI(parsed_arg, program_name, sout, serr):

    from script_lib.magnetics import listener_via_stderr
    listener = listener_via_stderr(serr)

    from data_pipes import common_producer_script as mod
    _ = mod.LEGACY_markdown_lib().collection_identifier_via_parsed_arg_

    _far_collection = _(parsed_arg)

    _near_collection = _these()

    def map_far_objects(obj):
        obj['read'] = '◻️'
        obj['emoji'] = '◻️'
        return obj

    from data_pipes import common_producer_script as mod
    sync = mod.TEMPORARY_LEGACY_USE_OF_SYNC_LIB()

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

# #history-A.2: move out of scripts directory. no longer an excutable.
# #history-A.1: (can be temporary) used to use putser_via_IO
# #history-A.1: big refactor, sunsetted file of origin
# #born: abstracted from sibling
