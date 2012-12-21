require 'skylab/test-support/core' # :Skylab::TestSupport::Tmpdir

require 'tmpdir'                  # Now ::Dir.tmpdir gives you the system-
                                  # specific tmpdir you can write to. The org-
                                  # wide one we use for testing is probably fine
                                  # for testing but it is not appropriate to use
                                  # that as a produciton tmpdir.  Note that this
                                  # tmpdir probably doesn't prettify w/
                                  # escape path.

module Skylab::TanMan

  class Services::Tmpdir

  public

    attr_reader :tmpdir

  protected

    def initialize
      @tmpdir = ::Skylab::TestSupport::Tmpdir.new(
        "#{ ::Dir.tmpdir }/tanny-manny" )
      @tmpdir.debug! if TanMan::API.debug
      @tmpdir.prepare
    end
  end
end
