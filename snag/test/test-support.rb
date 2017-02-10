require 'skylab/snag'
require 'skylab/test_support'

module Skylab::Snag::TestSupport

  class << self
    def [] tcc
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  module ModuleMethods___

    def use sym, * x_a

      _ = TS_.___lib sym

      if x_a.length.nonzero?
        x = [ x_a ]
      end

      _[ self, * x ]
    end

    def memoize sym, & p
      define_method sym, Common_.memoize( & p )
    end

    define_method :dangerous_memoize, TestSupport_::DANGEROUS_MEMOIZE
  end

  cache = {}
  define_singleton_method :___lib do | sym |
    cache.fetch sym do
      x = TestSupport_.fancy_lookup sym, TS_
      cache[ sym ] = x
      x
    end
  end

  module InstanceMethods___

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    def handle_event_selectively_
      event_log.handle_event_selectively
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
        Byte_Stream::ByteStreamExpressionAgent.new d, d_, d__
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

  My_CLI = -> do

    p = -> tcc do

      p = TS_::CLI.new_with(
        :subject_CLI, -> { Home_::CLI },
        :program_name, 'sn0g',
        :generic_error_exitstatus,
          -> { Home_.lib_.brazen::CLI_Support::GENERIC_ERROR_EXITSTATUS } )

      p[ tcc ]
    end

    -> tcm do
      p[ tcm ]
    end
  end.call

  module Expect_Event

    class << self
      def [] tcm, x_a=nil
        Common_.test_support::Expect_Emission[ tcm, x_a ]
        tcm.include self
      end
    end  # >>

    def subject_API
      Home_::API
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

      _path = ::File.join TS_.dir_path, 'fixture-files'

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
          Common_::Name.via_variegated_symbol( sym ).as_slug )
      end
    end
  end.call

  Home_ = ::Skylab::Snag

  Common_ = Home_::Common_

  Fixture_tree_dir___ = Common_.memoize do
    ::File.join TS_.dir_path, 'fixture-trees'
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

  module Nodes

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

  Path_alpha_ = Common_.memoize do

    ::File.join( Fixture_tree_[ :mock_project_alpha ], 'doc/issues.md' )
  end

  Home_::Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = true
  EMPTY_P_ = Home_::EMPTY_P_
  EMPTY_S_ = Home_::EMPTY_S_
  NIL_ = nil
  NEWLINE_ = "\n"
  SPACE_ = Home_::SPACE_
  TS_ = self
  UNDERSCORE_ = Home_::UNDERSCORE_
end
