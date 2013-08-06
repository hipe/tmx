require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Face::TestSupport

  module CONSTANTS
    Face = ::Skylab::Face
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  TestSupport::Regret[ self ]

  stowaway :CLI, 'cli/test-support'  # [#mh-030] for [#045]

  TestSupport::Sandbox::Host[ self ]

  TestSupport = TestSupport

  CONSTANTS::Common_setup_ = -> do  # ..
    common = -> do
      include self::CONSTANTS
      extend TestSupport::Quickie
      self::Face = Face
    end
    h = {
      sandbox: -> do
        module self::Sandbox
        end
        self::CONSTANTS::Sandbox = self::Sandbox
      end,
      sandboxer: -> do
        self::Sandboxer = self::TestSupport::Sandbox::Spawner.new
      end
    }.freeze
    -> mod, *i_a do
      mod.module_exec( & common )
      while i_a.length.nonzero?
        i = i_a.shift
        mod.module_exec( & h.fetch( i ) )
      end
      nil
    end
  end.call

  module InstanceMethods

    def only_line
      a = info_lines
      1 == a.length or
        fail "expected 1 had #{ a.length } lines (#{ a[ 1 ].inspect })"
      a.shift
    end

    def line
      info_lines.shift or fail "expected at least one more line, had none"
    end

    def there_should_be_no_lines
      info_lines.length.zero? or fail "expected no lines had #{ info_lines[0]}"
    end

    def info_lines
      @info_lines ||= begin
        io = @infostream ; @infostream = :spent
        io.string.split "\n"
      end
    end

    def infostream
      @infostream ||= begin
        io = TestSupport::IO::Spy.standard
        do_debug and io.debug! 'info >>> '
        io
      end
    end
  end
end
