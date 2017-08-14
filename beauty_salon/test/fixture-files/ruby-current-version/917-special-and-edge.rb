# (see sibling README)

x = nil
y = nil
z = nil


# -- operators we missed


# `match_with_lvasgn` #testpoint1.48
# (as seen in (at writing) arc/lib/skylab/arc/magnetics/qualified-component-via-value-and-association.rb:425)

/xxx/ =~ x




# -- magic variables (globals) and similar




# (magic) `gvar` #testpoint1.44
# (as seen in (at writing) common/lib/skylab/common/name/conversion-functions.rb:57)

x, y, z = $~.captures




# #testpoint1.3

x = $1




# `defined?` #testpoint1.33
# (as seen in (at writing) test_support/lib/skylab/test_support/slowie/core.rb:374)

defined? x

# #born - deleted spiritual ancestor in same commit (rename and rewrite)
