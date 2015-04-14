require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Snag::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self ]

  extend TestSupport_::Quickie

  module ModuleMethods

    def use sym, * x_a

      if x_a.length.nonzero?
        rest = [ x_a ]
      end

      TS_.const_get(
        Callback_::Name.via_variegated_symbol( sym ).as_const, false
      )[ self, * rest ]

      NIL_
    end

    def with_invocation * i_a
    end

    def with_manifest s
    end

    def with_tmpdir_patch
    end

    def with_tmpdir
    end

    def memoize_ sym, & p
      define_method sym, Callback_.memoize( & p )
    end
  end

  module InstanceMethods

    def tmpdir
      @tmpdir ||= Memoize_.call :tmpdir do
        __build_tmpdir
      end
    end

    def __build_tmpdir

      TestSupport_.tmpdir.new(
        :path, Snag_.lib_.system.filesystem.tmpdir_pathname.
          join( 'snaggle' ).to_path,
        :be_verbose, do_debug,
        :debug_IO, debug_IO )
    end

    # ~ support & officious

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    def subject_API  # #hook-out for expect event
      Snag_::API
    end

    def black_and_white_expression_agent_for_expect_event  # ditto
      Snag_.lib_.brazen::API.expression_agent_instance
    end
  end

  module Criteria_Library_Support  # (draws from [mh] parse t.s)

    def self.[] mod
      mod.include self
      def mod.subject_module_
        Snag_::Models_::Node_Criteria::Library_
      end
    end

    def parse_against * s_a
      against_ input_stream_via_array s_a
    end

    def input_stream_containing * s_a
      input_stream_via_array s_a
    end

    def input_stream_via_array s_a
      Snag_.lib_.parse_lib::Input_Streams_::Array.new s_a
    end

    def against_ st, & x_p
      subject_object_.output_node_via_input_stream st, & x_p
    end

    def subject_module_
      self.class.subject_module_
    end
  end

  Expect_My_CLI = -> do

    p = -> tcm do

      require TS_.dir_pathname.join( 'modality-integrations/expect-cli' ).to_path

      p = TS_::Expect_CLI.new_with(
        :subject_CLI, -> { Snag_::CLI },
        :program_name, 'sn0g',
        :generic_error_exitstatus,
          -> { Snag_.lib_.brazen::CLI::GENERIC_ERROR_ } )

      p[ tcm ]
    end

    -> tcm do
      p[ tcm ]
    end
  end.call

  Expect_Event = -> tcm, x_a=nil do
    Callback_.test_support::Expect_Event[ tcm, x_a ]
  end

  Expect_Stdout_Stderr = -> tcm do

    tcm.include TestSupport_::Expect_Stdout_Stderr::Test_Context_Instance_Methods
    tcm.send :define_method, :expect, tcm.instance_method( :expect )  # :+#this-rspec-annoyance
    NIL_
  end

  Fixture_file_ = -> do
    p = -> sym do
      h = {}

      _path = TS_.dir_pathname.join( 'fixture-files' ).to_path

      rx = /[-\.]/

      ::Dir.glob( "#{ _path }/[^.]*" ).each do | path |
        h[ ::File.basename( path ).gsub( rx, UNDERSCORE_ ).intern ] = path
      end

      h[ :not_there ] = 'not-there.file'

      p = h.method :fetch
      p[ sym ]
    end
    -> sym do
      p[ sym ]
    end
  end.call

  Fixture_tree_ = -> do
    h = {}
    -> sym do
      h.fetch sym do
        h[ sym ] = TS_.dir_pathname.join(
          'fixture-trees',
          Callback_::Name.via_variegated_symbol( sym ).as_slug
        ).to_path
      end
    end
  end.call

  Snag_ = ::Skylab::Snag

  Callback_ = Snag_::Callback_
  NIL_ = nil
  SPACE_ = Snag_::SPACE_
  UNDERSCORE_ = '_'

end
