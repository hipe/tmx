require_relative '../core'

module Skylab::Face::TestSupport

  Face_ = ::Skylab::Face
  TestSupport_ = Face_::Autoloader_.require_sidesystem :TestSupport
  TestSupport_::Regret[ self ]
  TestSupport_::Sandbox::Host[ self ]

  TestLib_ = ::Module.new

  module CONSTANTS
    Face_ = Face_  # the new preferred way
    Face = Face_  # necessary for compat with lots of doc-test generatees
    TestLib_ = TestLib_
    TestSupport_ = ::Skylab::TestSupport
  end

  extend ( module Methods_
    def apply_x_a_on_child_test_node x_a, child
      send( :bundles_class ).new( self, x_a, child ).apply_x_a_on_child ; nil
    end
    self
  end )

  def self.bundles_class
    Bundles_
  end

  class Bundles_  # might replace 'Common_setup_'
    def initialize parent, x_a, child
      @child = child ; @parent = parent ; @x_a = x_a
    end
    def apply_x_a_on_child
      begin
        send :"#{ @x_a.shift }="
      end while @x_a.length.nonzero?
    end
    def flight_of_stairs=
      @child.extend Methods_
    end
    def sandboxes_et_al=
      @child.const_set :TS__, @child
      @child.include @child.const_get( :CONSTANTS, false )
      @child.const_set :Face, Face_
      @child.const_set :Sandbox, Face_::Autoloader_[ ::Module.new ]
      @child::Sandbox.dir_pathname
      @child::CONSTANTS.const_set :Sandbox, @child::Sandbox
      @child.extend TestSupport_::Quickie ; nil
    end
  end  # #posterity the predecessor ('Common_setup_') 1st iambic?

  module InstanceMethods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

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
      @info_lines ||= build_info_lines
    end

    def build_info_lines
      io = @infostream ; @infostream = :spent
      io.string.split "\n"
    end

    def infostream
      @infostream ||= build_infostream
    end

    def build_infostream
      TestSupport_::IO::Spy.new(
        :do_debug_proc, -> { do_debug },
        :debug_IO, debug_IO,
        :debug_prefix, 'info >>> ' )
    end
  end

  stowaway :CLI, 'cli/test-support'  # [#045] this is part of our public API
end
