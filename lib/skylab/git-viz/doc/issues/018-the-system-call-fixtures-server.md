# the system call fixtures server :[#018]


## :#introduction-to-the-server-micro-architecture

for now the server lifecycle is like this: there is a "frontend" that is
just a shell script that loads a correct ruby version with rbenv, and then
execs out to the middle-end, having changed the path and made the symlinks
etc. through rbenv to get the correct ruby loaded.

the middle-end is concerned with everything to do with zero MQ: it listens on
ports and so on. when it gets requests, it dispatches them out to the backend.

the backend is concerned with nothing about zero MQ and everything about our
business logix. the "business responder" of the backend is documented at
[#034]  (currently in this document).


## :#introduction-to-the-middle-end

(for now, please see #introduction-to-the-server-micro-architecture)



# :#the-fields-of-a-record-command, :[#034]

(note: the "record" above is the verb (rhymes with "accord"), not the noun
(as in "record player"). it's confusing because "rows"/"entries"/"objects"
may be referred to as "records", but that is not our intended meaning here.
here we are referring the (related) act of recording something.)

the response from our "fixture server" back to the caller will be a semi-
structured iambic statement. these are sort of freeform, and may require
knowlege of the grammar from the caller's end to un-marshall this, if she
wants something other than a sequence of strings. but we generally find it
to be a nice balance: enconding and unencoding JSON is overkill at this point,
but a fixed-field "CSV"-style row will be too rigid. iambic statements let
us do interesting things with how we write handlers. and if the caller choses
to ignore the response, it still looks pretty.

so, the "iambic statement" for a single command will consist of five (5)
"business" fields in addition to any channel info we put in the leading
fields (likely we will have something like a 2-term header 'payload',
'command' to tell the caller the channel and the shape of this statement.)

they are (but in no particular order, because the rest will be iambic
key-value pairs):

1) the command to execute as a shell-escaped string. (it is stored and
returned this way only out of conveninece. sometimes it would be nicer to have
it as an array instead, but Shellwords works well enough.)

2) zero or one relative path to execute the command from. the relative path
will have the head fragment stripped from it; the head fragment being a path
prefix in the request we haven't documented yet.

3) the file to write any stdout to (more below about this).

4) the file to write any stderr to (more below about this).

5) the expected exitstatus result from this system command (more below).


when the fields for stdout and stderr are empty variously, it is an indication
from the manifest to the system agent that no such output is expected, under
penalty of fatal error. this is the recommended behavior of the system agent:
when such a path is provided and there is no output on that stream from that
actual command, a notice will be issued and a blank file will be written. the
reasoning for this will be explained below.

normally if an exitstatus is provided from the manfest API it must be a
positive integer (maybe negative?). the way the manifest API may indicate that
a zero exitstatus is expected is by sending the empty string (i.e nothing/
blank/nil) for this field. because this is expected to be the most common
exitstatus for general use of this, we make it a forcible default: the way
you specify '0' is by not specifying anything, and that is the only way you
can specify it. this allows us to keep our manifests free from the noise of
having '0' for most of its entries. this also forces us to assert always some
exitstatus, which is more a feature than a hinderance as explained below.

like with unexpected stdout and stderr, when the first exitstatus is
encountered that does not match what the API expects, further action is ceased
and a fatal error is issued. if the manifest does not yet know what the
exitstatus will be from a command (which is half the reason we are
constructing this castle), the manifest may provide the question-mark ("?")
character as the value in the exitstatus field: during the "performance" the
system agent is then expected to call_digraph_listeners whatever the actual exitstatus integer
was from the system call (as a readable string) in an info statement.

the following strings will all be treated as "question marks:" "?", "???",
"(what is it?)". we intentionally refrain from documenting what the pattern
is because it is certainly subject to change, but suffice it to say the above
three examples (and other strings that fit the above implied "pattern")
should always signify this "query".


## why all the ruckus?

the reason for this delicate dance is twofold: 1) this "system adapter" of the
troika may not write back to the manifest. that's just not how it works
in this family (for now). it's much less ridiculous if the only thing this
system does is write files that are just redirected output, and issues
notices about piddly little integers.

2) when what is expected differs from what actually occurs on the system,
this is considered a showstopper, and given 1), we must literally stop the
show:

the entire first and last point of this whole circus is to get a byte-per-byte
spot-on representation of what a particular system does in response to
commands (along these three relatively narrow axes). to have incomplete or
inaccurate data dumps in your manifest will not only do more harm than good,
it is counter to our sole function.

to prevent the troika "recording session" from ever aborting halfway through,
in your manifest for the particular commands in question you can indicate
filenames for stdout and stderr both, and provide a '?' for the exitstatus,
which are the safe, catch-all choices that will issue notices as approriate.

then after the command is performed and responses are variously announced
and/or written to disk, you can go back and write in the exit code in the
manifest, and remove empty files and their corresponding filenames from
the manifest. then if you re-perform the same command again, you should
(assuming normalization is working where relevant), get the same behavior
from the peformance that you have saved in your manifest, and hopefully
the troika system will report as much.
