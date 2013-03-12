require_relative '../test-support'

# WHAT IS GOING ON HERE is that we are testing our test-support components.
# (at the time of writing, we don't even use the contituency directly in
# pub-sub - it is offered as a courtesy. but it is wrong to have code
# sitting around in a library without tests to go with it. it is wrong.)

# So generally, (and hopefully) it follows that any time you see a
# *directory* (not file) explicitly called 'test-support' it indicates
# that you are about to see metatesting.  #neato

module Skylab::PubSub::TestSupport::TestSupport
  ::Skylab::PubSub::TestSupport[ TestSupport_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module InstanceMethods
    include CONSTANTS  # we need to be able to see p.s from i.m's
  end
end
