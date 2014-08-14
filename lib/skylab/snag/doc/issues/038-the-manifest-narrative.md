# the manifest narrative :[#038]

## introduction

would that it needs any introduction



## #note-75

using a hacky regex, scan all msgs emitted by the file utils client and with
any string that looks like an aboslute path run it through `escape_path_p`
proc (*of the modality client*, e.g). in turn, `call_digraph_listeners`
these messages as info to `info_p`, presumably to the same modality client.

this hack grants us the novelty of letting FileUtils render its own messages
(which it does heartily) while attempting possibly to mask full filenames for
security reasons. but at the end of day, it is still a hack




## file notes

### :#note-12

this is used by services and hence cannot be a sub-client.

[#ba-004] might subsume parts (most?) of this.

`normalized_line_producer` is like a filehandle that you call `gets` on
(in that when you reach the end of the file it returns nil) but a) you
don't have to chomp each line and b) it keeps track of the line number
internally for you (think of it as like a ::StringScanner but instead of
for scanning over bytes in a string it is for scanning lines in a file).



### :#note-42

`normalized_lines` is comparable to File#each (aka `each_line`, `lines`)
except a) it internalizes the fact that it is a file, taking care of
closing the file for you, and b) it chomps each line, so you don't have
to worry about whether your line happens to be the last in the file,
or whether or not the last line in the file ends with newline characters,
or what those characters are.



### :#note-52

necessary in short-circuit finds to checkif the one we found was also the
last one in which case it will be closed already


from stack overflow #3024372, thank you molf for a tail-like
implementation if we ever need it.




## line edit notes

• `at_position_x`  when it is zero it means "insert the new lines at
                   the begnning of the file" else it is expected to be a
   rendered identifier, for which the the lines will replace the existing
   lines for that node.


• `error_p`  error callback (is passed what?) to be called for e.g when
             the node is not found.


• `escape_path_p`  #eew should be curried into above


• `file_utils_p`  #eew ditto


• `info_p`  called for e.g verbose output or informational.


• `is_dry_run`  will not actually write to disk, but tries to otherwise
                be a realistic simulation


• `manifest_file_p`  the model of the file, for our persistence impl.


• `new_line_a`  the array of lines to insert or replace


• `pathname`  #todo - redundant with above


• `raw_info_p` probably lines to be written directly to stderr


• `tmpdir_p`  used for our persistence implementation


• `verbose_x`  perhaps more events will be emitted



## #note-73

when you save a file in vi it appears to append a "\n" to the
last line if there was not one already. we follow suit here when
rewriting the manifest. however we leave the below in place in case
we ever decide to revert back to the dumb way.
