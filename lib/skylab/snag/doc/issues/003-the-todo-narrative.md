# the TODO narrative :[#003]




## #note-85

given a `full_source_line` that looks like:

    "      # %todo we would love to have -1, -2 etc"

parse out ranges for:

  + `non_comment_content`  : the leading whitespace before the '#'
  + `commment_content` : the string from 'we' to 'etc'

some of these ranges may be zero width so it is *crucial* that
you check `count` on the range because otherwise getting the
substring 0..-1 of a string may *not* be what you expect, depending
on what you expect!



## :#note-75

we keep the logical redundancy here intact because this:
just because all these ranges are implemented in the same manner doesn't
mean they have to be.



## :#storypoint-100

consider the line:

    @full_tag_string = "##{ @tag_stem }"  # %todo make the '#' be a variable
<--------------------------------------><--><---><------------------------->
                  (1)                    (2) (3)            (4)

+ the 'tag' segment (3) is self evident, and the least interesting.

+ `any_before_comment_content_string` is (1), not guaranteed to have width.

+ `any_pre_tag_string` is (1) and (2), likewise width is not guaranteed.

+ `any_post_tag_string` is (4), and also is not guaranteeed to have width.





## :#note-155

the main reason we need this regex builder is because the regex syntax
supported by `grep` is not the same as the native engine.

also, we have to take some pains to build the regex right because
ultimately this is a hack :[#068]: we are not parsing source code file in
a truly language-aware way: this is just a regex hack.

but given that, and if our tags can for example start with '@' or '#',
then "@todo" the ivar will falsely match. our workaround to try to avoid
such a case is here.




## :#storypoint-210

these are attempts at workarounds for some common mismatches ..
