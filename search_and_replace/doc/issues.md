[#013]       the context lines algorithm ..

[#012]       a "tagged sexp node" node is (at writing) effectively a string
             plus a symbolic tag that indicates which one of three categories
             the string is (original, replacement, or newline sequence).
             there can be no newline sequences in the strings of nodes
             of the first two categories. streams of these nodes facilitate
             modality clients rendering content with semantic styling.

[#011] #open  #blocker this will CONVERT non-unixy newlines to unixy.
             this was an accident stemming from the "optimization" near
             `NEWLINE_SEXP_` and the custom line scanner and will
             require some redesign (either never use a const value for
             these or detect which was used and whether (ICK) the
             sequence changes.)

[#010]       edit sessions
[#009] #open consider merging read-only & not read-only file session ?  (are they??)
[#008]       #feature have the multiple forms save to one file
[#007]       #feature explicit choice of single line v. multiline
[#006]       #feature support for spaces in list items
[#005]       #feature make this one button with three labels instead of three buttons
[#004]       #feature should check mtime before write, abort for that file if stale
[#003]       [ track a historic node ]
[#002]       -wip-them-all (in [ts]) *uses* this guy..
[#001]       [ the readme ]
