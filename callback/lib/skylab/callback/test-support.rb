
require_relative 'test/test-support'

# this is a hack to make the 'fire' test work. the 'fire' test specifies
# a const path that it inside the TestSupport node, a node which lies in
# the non-regular (but absolutely conventional) path indicated above.
#
# when 'Fire' (or anything from the normal surface runtime) tries to load
# a path with [cb]::TestSupport::[etc] before the test node is loaded, it
# will first load this file, which in turn loads the correct file above.
#
# another alternative is the set an explicit stowaway entry in the parent
# node (the stowaway facility having been desigend just for such cases).
# however, we don't like that because it pollutes the purity of our all-
# important top node for [cb] just to get this test to pass.
