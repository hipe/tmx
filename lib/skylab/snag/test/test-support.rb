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

    def nasty_OCD_memoize_ sym, & p  # read caveat in [#ts-042]

      did = false
      x = nil

      define_method sym do
        if did
          x
        else
          did = true
          x = instance_exec( & p )
        end
      end
    end
  end

  module InstanceMethods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  module Byte_Up_And_Downstreams

    class << self
      def [] tcm
        tcm.include self
      end
    end  # >>

    # ~ near downstream

    def build_byte_stream_expag_ d, d_, d__

      Snag_::Models_::Node_Collection::Expression_Adapters::
        Byte_Stream::Expression_Agent_.new d, d_, d__
    end

    def downstream_ID_for_output_string_ivar_

      s = ""
      @output_s = s
      Snag_.lib_.basic::String::Byte_Downstream_Identifier.new s
    end

    # ~ near verification

    def scanner_via_output_string_
      scanner_via_string_ @output_s
    end

    def scanner_via_string_ s
      TestSupport_::Expect_Line::Scanner.via_string s
    end
  end

  module Criteria_Library_Support  # (draws from [mh] parse t.s)

    def self.[] mod
      mod.include self
      def mod.subject_module_
        Snag_::Models_::Criteria::Library_
      end
    end

    def parse_against_ * s_a, & x_p
      against_ input_stream_via_array( s_a ), & x_p
    end

    def against_ in_st, & x_p

      _obj = subject_object_
      _context = grammatical_context_

      _obj.interpret_out_of_under_ in_st, _context, & x_p
    end

    define_method :grammatical_context_for_singular_subject_number_, -> do

      x = nil
      -> do
        x ||= subject_module_::Grammatical_Context_.new_with :subject_number, :singular
      end
    end.call

    def input_stream_containing * s_a
      input_stream_via_array s_a
    end

    def input_stream_via_array s_a
      Snag_.lib_.parse_lib::Input_Streams_::Array.new s_a
    end

    def visual_tree_against_ st
      _x = against_ st
      _x.to_ascii_visualization_string_
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

  module Expect_Event

    class << self
      def [] tcm, x_a=nil
        Callback_.test_support::Expect_Event[ tcm, x_a ]
        tcm.include self
      end
    end  # >>

    def subject_API
      Snag_::API
    end

    def black_and_white_expression_agent_for_expect_event
      Snag_.lib_.brazen::API.expression_agent_instance
    end
  end

  module Expect_Piece

    class << self
      def [] tcm
        tcm.include self
      end
    end  # >>

    def expect_piece_ i, x

      part = @piece_st.gets
      part or fail "expected more parts, had none"
      part.category_symbol.should eql i
      part.get_string.should eql x
      part
    end

    def expect_no_more_pieces_

      x = @piece_st.gets
      x and fail "expecting no more parts, had #{ x.category_symbol }"
    end
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

  My_Tmpdir_ = -> do

    o = nil  # :+#nasty_OCD_memoize_ (see)

    -> tcm do

      tcm.send :define_method, :my_tmpdir_ do

        if o
          if do_debug
            if ! o.be_verbose
              o = o.new_with :debug_IO, debug_IO, :be_verbose, true
            end
          elsif o.be_verbose
            o.new_with :be_verbose, false
          end
        else
          o = TestSupport_.tmpdir.new(
            :path, ::File.join(
               Snag_.lib_.system.defaults.dev_tmpdir_path,
               'snaggle' ),
            :be_verbose, do_debug,
            :debug_IO, debug_IO )
        end
        o
      end
    end
  end.call

  Callback_ = Snag_::Callback_

  Path_alpha_ = Callback_.memoize do

    ::File.join( Fixture_tree_[ :mock_project_alpha ], 'doc/issues.md' )
  end

  ACHIEVED_ = true
  EMPTY_P_ = Snag_::EMPTY_P_
  EMPTY_S_ = Snag_::EMPTY_S_
  NIL_ = nil
  NEWLINE_ = "\n"
  SPACE_ = Snag_::SPACE_
  UNDERSCORE_ = Snag_::UNDERSCORE_

end
