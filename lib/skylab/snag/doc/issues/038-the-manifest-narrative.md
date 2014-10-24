# the manifest narrative :[#038]

## introduction

would that it needs any introduction



## #note-75

using a hacky regex, scan all msgs emitted by the file utils client and with
any string that looks like an aboslute path run it through a
proc (*of the modality client*, e.g). in turn, `call_digraph_listeners`
these messages as info to `info_event_p`, presumably to the same modality client.

this hack grants us the novelty of letting FileUtils render its own messages
(which it does heartily) while attempting possibly to mask full filenames for
security reasons. but at the end of day, it is still a hack




## file notes

### :#note-12

this is used by services and hence cannot be a sub-client.

[#ba-004] might subsume parts (most?) of this.

a normalized line producer is like a filehandle that you call `gets` on
(in that when you reach the end of the file it returns nil) but a) you
don't have to chomp each line and b) it keeps track of the line number
internally for you (think of it as like a ::StringScanner but instead of
for scanning over bytes in a string it is for scanning lines in a file).



### :#note-42

this method is comparable to File#each (aka `each_line`, `lines`)
except a) it internalizes the fact that it is a file, taking care of
closing the file for you, and b) it chomps each line, so you don't have
to worry about whether your line happens to be the last in the file,
or whether or not the last line in the file ends with newline characters,
or what those characters are.



### :#note-52

necessary in short-circuit finds to checkif the one we found was also the
last one in which case it will be closed already



### :#note-72

there a simplicity to the chain of scanners issues upwards a 'stop' call
and having there not need to be this conditional check. we could
probably do that were it not for the edge case of stopping on what
happens to be the last item in the file (when the item consists of one line).
in such cases the filehandle will be closed already once it has
delivered that final line outward to scanner nodes further down on the
chain. (but our system won't know that it is the
final line yet anyway).

in such cases a node further out on the chain may issue a 'stop' for
whatever reason, but when it gets back to the resource node there is
nothing to do. hence we must conditionaly check that closing the file
is necessary.



from stack overflow #3024372, thank you molf for a tail-like
implementation if we ever need it.




## line edit notes  :#note-9

• `at_position_x`  when it is zero it means "insert the new lines at
                   the begnning of the file" else it is expected to be a
   rendered identifier, for which the the lines will replace the existing
   lines for that node.


• `is_dry_run`  will not actually move the final changed manifest into
                place, but otherwise attempts a realistic simulation.


• `new_line_a`  the array of lines to insert or replace


• `verbose_x`  perhaps more events will be emitted depending on the value


• `client` provides facilities needed by this agent like the manifest
           file, access to a tmpdir, acces to a file utils controller.

• `delegate` is per eventmodel




## #note-73

when you save a file in vi it appears to append a "\n" to the last line
if there was not one already. we follow suit here when rewriting the
manifest. however we leave the below commented out comments in place for
now in case we ever decide to revert back to the dumb way. but see the
next section:



## #line-terminators-versus-line-separators :[#020]

more broadly this has applicability to writing text file in general: we
may typically think of the newline sequence as a line "separator"; but
in fact in UNIX land (and perhaps more broadly than that) the newline
sequence is generally used as more of a line "terminator" than
"separator" [1][1]. the difference is subtle but important: wheras a
separator would separate lines, a terminator terminates every line,
including the last one.

from the manpage for the wc utility [2][2]

   A line is defined as a string of characters delimited by a <newline>
   character.  Characters beyond the final <newline> character will not
   be included in the line count.



### understanding the difference

consider a file whose contents consist of one character, the "\n"
newline character. when using "separator" semantics, this file could be
said to have two lines -- two empty strings separated by the separator.

whereas if we use terminator semantics, this file ("correctly") would be
said to have one line -- one empty string terminated by the terminator.

but then consider the null file, a file with no bytes. using separator
semantics we would say that this file has one item, the empty string.
wheras using terminator semantics the number of lines might be
considered to be zero (because there are no terminators).

but what about a file with one character (or more) and that character
(or characters) is not or do not contain the newline sequence anywhere
at all? using separator semantics we consider this file to have one
item, whereas using terminator semantics this file might be considered
to be invalid or undefined or have zero lines etc.



### as it pertains to the behavior we implement

where it matters we will typically implement a middle-groud behavior,
where we employ terminator (not separator) semantics, but in cases where
the trailing line item does not end in a newine sequence (that is, the
file does not end in a newline sequence), we still consider it a line
(and where it matters we will not automatically add the newline
sequence ourselves, and where it matters we might).



### references

[1]: see `man git-log`, near "the final entry of a single-line format
     will be properly terminated with a new line". the use of that term
     "proper" is taken to support our claim.

     also the behavior in editors like `vi` is taken as "evidence" that the
     terminator semantics are more conventional than separator semantics.

[2]: BSD `wc` February 23, 2005
