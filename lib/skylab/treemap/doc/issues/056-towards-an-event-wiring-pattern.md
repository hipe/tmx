# towards an event wiring pattern..

How about this: some modality nerk, let's say the modality client,
defines methods named for the common types of events:
`wire_payload`, `wire_info`, `wire_error`. (interestingly applications
whose payload is not ascii-text may opt not to use the `payload` name
at all, but rather `pdf`, because how you handle the production of a
pdf may be vastly different than how you handle a stream of text that
you intend to write to stdout., for e.g.. hm maybe not that interesting ..)

The modality subclient base class, e.g CLI::Action, defines its own
set of these e.g three methods by simply calling up to it's request
client (these could even be put in the s.c i.m)..

(more to come..)
