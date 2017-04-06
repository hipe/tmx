# the stream narrative :[#032]

## listing a collection of entities

in a typical ORM this is the subject of much complexity because it opens
up the pandora's box of queries, joins etc. we aren't going to get into
all that just yet (as in, it's not implemented). instead, try:


    to_entity_stream_via_model <cls>, & <on event selectively>


using a model class as the "query" is crude and won't scale, but it's
enough to give us a quick start.

because the result (when successful) is a [#co-016.2] stream, you can get
the results progressively, and only as many as you need, without necessarily
knowing how they are being retrieved on the back (there could be a pager
going on, etc).

watch out because we like to use flyweighting here. each next object you
get might be the same object as before but with different values inside.
it depends on the silo's treament of this.

because it is a [#ibid] stream you can do map, reduce, expand, etc (but again
flyweighting might trip you up unless you do something like duping your
each element as necessary).

of all the verbs implemented at this writing, this is the one that most
certainly will need to change because of how crude its "query" is
currently. but again, it's enough to get us started.
