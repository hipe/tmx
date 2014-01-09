# the git commit narrative :[#009]


## :#storypoint-10

either git, ruby, or my OS has some confusion about what ISO-8601 means.
according to wikipedia it appears that ruby is off the hook and either git
or my OS is to blame:

here is an example of an "incorrect" ISO date returned by `git`. we use
the 'ai' signifier which is for the author ISO date. (we pipe it to `head`
(the utility not the commit) just because i didn't know how to get only
the one line of output from the command.)

    $ git show --shortstat --pretty=format:%ai HEAD | head -n 1
    2014-01-05 04:03:24 -0500

then with ruby try to parse that exact string:

    $ irb
    require 'date'
    DateTime.iso8601 "2014-01-05 04:03:24 -0500"  ArgumentError: invalid date
    # yet:
    DateTime.iso8601 "2014-01-05T04:03:24-0500"  # => #<DateTime: 2014-0..>



## :#storypoint-20

in my environment there is an incongruence between what "man git-diff-tree"
reports and the observed behavior, of the '--numstat' flag with regards
to file moves. in the magpage in the sizeable section on --numstat it
describes how it will show file rename information in one line. the behavior
(of 1.7.4.4) appears always to be to give one file rename two separate lines.
the behavior may actually be better from a machine readability standpiont, but
then we miss out on all the crazy fun of the '-z' option described in the
manpage.
