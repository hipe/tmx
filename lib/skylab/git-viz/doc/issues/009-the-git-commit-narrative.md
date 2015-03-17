# the git commit narrative :[#009]

## :#storypoint-15

the trailing double dash is necessary to make the command non-
ambiguous: the variable represents a commit and not a tree. its
utility isn't always evident unless the commit is not found.

large commits (in terms of the number of files affected) that go
over the buffer threshold will bork against this naive
implementation, but this is enough to get us off the ground.




## :#storypoint-36

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


:#tombstone: ramblings about the '-z' option, before we knew about '-M'
