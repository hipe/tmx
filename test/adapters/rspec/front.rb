module Skylab::Test

  module Adapters::Relish

    # (we use a name other than "R-Spec" only for clarity and to ensure
    # that we are accessing the vendor entity in the right way - in production
    # code you should see neither references to "R-elish" nor "R-Spec".)

    Test::Adapter::Anchor_Module[ self ]  # do all the common things

    def self.load_core_if_necessary
      MetaHell::FUN.require_quietly[ 'rspec' ] unless defined? ::RSpec
      nil
    end
  end
end
