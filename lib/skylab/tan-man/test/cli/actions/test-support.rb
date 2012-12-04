require_relative '../test-support'

module Skylab::TanMan::TestSupport::CLI
  if defined? ::RSpec             # ack - avoid loading rspec-depedant things
    require_relative 'for-rspec'  # when we are running (visal tests)
  end                             # without rspec
end
