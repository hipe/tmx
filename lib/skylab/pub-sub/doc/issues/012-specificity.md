# 012 - can the idea of specificity be built into the graph?

in the really old days we used to resort to `touch!` / `touched?` hacks
to accomplish this thing we're after.

in the now days it seems like what we're doing is using the
`if_unhandled_streams` facility in conjunction with handling every
non-taxonomic stream. But this is less than ideal - it goes a bit
against the founding spirit of the event stream graph to have
perfect knowledge of the upstream graph in order to capture with

but the final, true and complete re-ification of all that is the dream of the
evthe stream-graph dream would be this:

for each event that is emitted, and then of this for each listener
of the event, find only the most specific (whatever that means)
stream that is subscribed to, and emit the event only on that stream..

the open question, thne, is can we deterministicly (and then efficiently)
determine what that stream is for each emission for each listener etc?
