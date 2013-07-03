module Skylab::Test

  module Adapters::Relish

    # we use a strange name as an exercise in modularity, and so we don't
    # get false-positives when searching for the real ::R-Spec/r-spec

    Test::Adapter::Anchor_Module[ self ]  # do all the common things

    def self.load_core_if_necessary
      MetaHell::FUN.require_quietly[ 'rspec' ] unless defined? ::RSpec
      nil
    end
  end
end
