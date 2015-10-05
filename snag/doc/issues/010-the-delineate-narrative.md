# the delineate narrative :[#010]

since this is mutable we assume it was mutated (or created) to
be something different than the (any) delineation that occurred
in storage.

(if we knew that this was a modality-specific mutable body and not
an agnostic one, we could assume it likely *did* come from storage
and was mutated, but we do not.)

each row structure will be output in sequence. the sequence of
zero or more leading row structures that do not appear to have
been mutated will be expressed with their original formatting
intact (regardless of whether they are over any width limit in
the expag).

once we find the first record that appears to have been mutated
(because it is mutable (and an array of objects rather than a
string, at that)), this triggers the word-wrap operation.

currently we will wordwrap this and any remaining rows regardless
of whether they too were mutated, losing the formatting of any
remaining non-mutated rows.

however we are considering engaging the word wrapper IFF the
current mutated row goes over the line limit width, which would
probably have this effect:

we would get the benefit of only breaking delineation when we
"need" to to avoid expressing a line that is too wide (that was
not that way to begin with); at a cost that over time this would
lead to some lines that might become unasthetically narrow over
time.

we are considering opening an issue for the case of us having
two adjacent non-space elements, and wanting to preserve the
non-spaciness at this joint. but this will require considerable
reworking of the vendor node.
_
