require 'skylab/snag'
require 'skylab/test_support'

module Skylab::Snag::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self, ::File.dirname( __FILE__ ) ]

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

    def memoize_ sym, & p
      define_method sym, Callback_.memoize( & p )
    end

    define_method :dangerous_memoize_, TestSupport_::DANGEROUS_MEMOIZE

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

    # ~ near upstream

    def upstream_identifier_via_string_ s

      Home_.lib_.basic::String::Byte_Upstream_Identifier.new s
    end

    # ~ near downstream

    def build_byte_stream_expag_ d, d_, d__

      Home_::Models_::Node_Collection::Expression_Adapters::
        Byte_Stream::Expression_Agent_.new d, d_, d__
    end

    def downstream_ID_for_output_string_ivar_

      s = ""
      @output_s = s
      downstream_ID_via_string_ s
    end

    def downstream_ID_via_string_ s

      Home_.lib_.basic::String::Byte_Downstream_Identifier.new s
    end

    def downstream_ID_via_array_ a

      Home_.lib_.basic::List::Byte_Downstream_Identifier.new a
    end

    # ~ near verification

    def scanner_via_output_string_
      scanner_via_string_ @output_s
    end

    def scanner_via_string_ s
      TestSupport_::Expect_Line::Scanner.via_string s
    end
  end

  module Criteria_Library_Support  # (disciple of [pa] t.s)

    def self.[] mod
      mod.include self
      def mod.subject_module_
        Home_::Models_::Criteria::Library_
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
      Home_.lib_.parse_lib::Input_Streams_::Array.new s_a
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
        :subject_CLI, -> { Home_::CLI },
        :program_name, 'sn0g',
        :generic_error_exitstatus,
          -> { Home_.lib_.brazen::CLI::GENERIC_ERROR_EXITSTATUS } )

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
      Home_::API
    end

    def black_and_white_expression_agent_for_expect_event
      Home_.lib_.brazen::API.expression_agent_instance
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
        h[ sym ] = ::File.join(
          Fixture_tree_dir___[],
          Callback_::Name.via_variegated_symbol( sym ).as_slug )
      end
    end
  end.call

  Home_ = ::Skylab::Snag

  Callback_ = Home_::Callback_

  Fixture_tree_dir___ = Callback_.memoize do

    TS_.dir_pathname.join( 'fixture-trees' ).to_path
  end

  My_Tmpdir_ = -> do

    o = nil  # :+[#ts-042] nasty OCD memoize

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
          o = TestSupport_.tmpdir.new_with(
            :path, ::File.join(
               Home_.lib_.system.defaults.dev_tmpdir_path,
               'snaggle' ),
            :be_verbose, do_debug,
            :debug_IO, debug_IO )
        end
        o
      end
    end
  end.call

  module Node_Support

    class << self

      def [] tcm
        tcm.send :define_method, :expect_noded_, EXPECT_NODED___
      end  # >>

      EXPECT_NODED___ = -> node_id_d do
        expect_no_more_events
        @result.ID.to_i.should eql node_id_d
      end
    end
  end

  Path_alpha_ = Callback_.memoize do

    ::File.join( Fixture_tree_[ :mock_project_alpha ], 'doc/issues.md' )
  end

  ACHIEVED_ = true
  EMPTY_P_ = Home_::EMPTY_P_
  EMPTY_S_ = Home_::EMPTY_S_
  NIL_ = nil
  NEWLINE_ = "\n"
  SPACE_ = Home_::SPACE_
  UNDERSCORE_ = Home_::UNDERSCORE_

end