require File.expand_path('../../..', __FILE__)

require 'skylab/pub-sub/emitter'
require 'skylab/test-support/tmpdir'

module Skylab::Dependency
  # there is no entrypoint file to include for this module
end

module Skylab::Dependency::TestSupport

  DESCRIBE_BLOCK_COMMON_SETUP = ->(_) do
    include ::Skylab::Porcelain::TiteColor
    let(:fingers) { Hash.new { |h, k| h[k] = [] } }
  end

  TEMP_DIR = ::Skylab::TestSupport::Tmpdir.new(::Skylab::TMPDIR_PATHNAME.to_s)

  BUILD_DIR = Skylab::TestSupport::Tmpdir.new(TEMP_DIR.join('build-dependency'))

  FIXTURES_DIR = Pathname.new(File.expand_path('../fixtures', __FILE__))

  require_relative('../static-file-server')
  FILE_SERVER = Skylab::Dependency::StaticFileServer.new(FIXTURES_DIR, :warn)

  module CustomExpectationMatchers
    def be_including foo
      BeIncluding.new(foo)
    end
    def be_subclass_of foo
      BeSubclassOf.new(foo)
    end
  end

  class BeIncluding
    def initialize expected
      @expected = expected
    end
    def matches? target
      (@target = target).include? @expected
    end
    def failure_message
      "expected #{@target.inspect} to include #{@expected}"
    end
    def negative_failure_message
      "expected #{@target.inspect} not to include #{@expected}"
    end
  end

  class BeSubclassOf < BeIncluding
    def description
      "be subclass of #{@expected}"
    end
    def matches? foo
      super(foo.ancestors)
    end
  end
end

