# the TODO narrative :[#003]





given a `full_source_line` that looks like:

    "      # %todo we would love to have -1, -2 etc"

parse out ranges for:

  + `non_comment_content`  : the leading whitespace before the '#'
  + `commment_content` : the string from 'we' to 'etc'

some of these ranges may be zero width so it is *crucial* that
you check `count` on the range because otherwise getting the
substring 0..-1 of a string may *not* be what you expect, depending
on what you expect!





consider the line:

    @full_tag_string = "##{ @tag_stem }"  # %todo make the '#' be a variable
<--------------------------------------><--><---><------------------------->
                  (1)                    (2) (3)            (4)

+ the 'tag' segment (3) is self evident, and the least interesting.

+ `any_before_comment_content_string` is (1), not guaranteed to have width.

+ `any_pre_tag_string` is (1) and (2), likewise width is not guaranteed.

+ `any_post_tag_string` is (4), and also is not guaranteeed to have width.
