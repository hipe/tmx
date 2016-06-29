# run edge cases :[#023]

(edge cases)


## indent can decrease in a discussion (#coverpoint1-4)

indent can decrease in a discussion like so:

    #     there are five blank spaces of margin
    #    now there are four
    #        code (because just enough margin)

note that the second line changed where the threshold margin was.




## transition back to discussion (#coverpoint1-5)

transition back to discussion:

    # disc 1
    #     code
    # disc 2

that.




## blank lines in code get added to the code run (#coverpoint1-6)

blank lines in a code run get added to that code run:

    #   discussion
    #       code line 1
    #
    #        code line 2

that.





## transition back to discussion by reducing indent (#coverpoint1-7)

transition back to discussion while reducing margin:

    #  discussion with 2 spaces of margin
    #      code
    # discussion with 1 space of margin

that.




## whatever this is (#coverpoint1-8)

whatever this is:

    # this discussion line establishes the margin
    #     code
    #    this is deeper than the established margin, and under code threshold

that.




## when all comment lines are blank (#coverpoint1-9)

when all comment lines are blank:

    #
    #

we have special handling for this.
