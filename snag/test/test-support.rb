require 'skylab/snag'
require 'skylab/test_support'

module Skylab::Snag::TestSupport

  class << self
    def [] tcc
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___
    end
  end  # >>

  # --

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  Home_ = ::Skylab::Snag
  Common_ = Home_::Common_
  Lazy_ = Common_::Lazy

  # --

  module ModuleMethods___

    def use sym, * x_a

      _ = TS_.__lib sym

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
  define_singleton_method :__lib do |sym|
    cache.fetch sym do
      x = TestSupport_.fancy_lookup sym, TS_
      cache[ sym ] = x
      x
    end
  end

  module InstanceMethods___

    # -- assertions

    def want_these_lines_in_array_with_trailing_newlines_ a, & p
      TestSupport_::Want_Line::
          Want_these_lines_in_array_with_trailing_newlines[ a, p, self ]
    end

    def want_these_lines_in_array_ a, & p
      TestSupport_::Want_these_lines_in_array[ a, p, self ]
    end

    # -- setup

    def ignore_emissions_whose_terminal_channel_is_in_this_hash
      NOTHING_
    end

    def subject_API_value_of_failure
      NIL  # not false - i.e use [#ze-007.5] semantics
    end

    def subject_API
      Home_::API
    end

    define_method :invocation_resources_, ( Lazy_.call do
      Home_::InvocationResources___.new :_no_argument_scanner_from_SN_
    end )

    def handle_event_selectively_
      event_log.handle_event_selectively
    end

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  # -- large-ish and/or application-level test-support extension modules

  module Operations

    def self.[] tcc
      Zerk_lib_[].test_support::Want_CLI_or_API[ tcc ]
      tcc.include self
    end

    def prepare_subject_API_invocation invo
      invo
    end
  end

  My_CLI = -> tcc do
    Eew_get_rid_of_this___[][ tcc ]
  end

  Eew_get_rid_of_this___ = Lazy_.call do

    _ = TS_::CLI.with(
        :subject_CLI, -> { Home_::CLI },
        :program_name, 'sn0g',
        :generic_error_exitstatus,
          -> { Home_.lib_.brazen::CLI_Support::GENERIC_ERROR_EXITSTATUS } )
    _  # hi. #todo
  end

  module Byte_Up_And_Downstreams

    class << self
      def [] tcm
        tcm.include self
      end
    end  # >>

    # ~ near upstream

    def upstream_reference_via_string_ s

      Home_.lib_.basic::String::ByteUpstreamReference.via_big_string s
    end

    # ~ near downstream

    def build_byte_stream_expag_ d, d_, d__

      Home_::Models_::NodeCollection::ExpressionAdapters::
        ByteStream::ByteStreamExpressionAgent.new d, d_, d__
    end

    def downstream_ID_for_output_string_ivar_

      s = ""
      @output_s = s
      downstream_ID_via_string_ s
    end

    def downstream_ID_via_string_ s

      Home_.lib_.basic::String::ByteDownstreamReference.via_big_string s
    end

    def downstream_ID_via_array_ a

      Home_.lib_.basic::List::ByteDownstreamReference.via_line_array a
    end

    # ~ near verification

    def scanner_via_output_string_
      scanner_via_string_ @output_s
    end

    def scanner_via_string_ s
      TestSupport_::Want_Line::Scanner.via_string s
    end
  end

  # -- test-support extension modules for models & similar

  module Want_Piece

    class << self
      def [] tcm
        tcm.include self
      end
    end  # >>

    def want_piece_ i, x

      part = @piece_st.gets
      part or fail "expected more parts, had none"
      expect( part.category_symbol ).to eql i
      expect( part.get_string ).to eql x
      part
    end

    def want_no_more_pieces_

      x = @piece_st.gets
      x and fail "expecting no more parts, had #{ x.category_symbol }"
    end
  end

  Nodes = -> tcc do

    tcc.send :define_method, :want_noded_, -> node_id_d do
      want_no_more_events
      expect( @result.ID.to_i ).to eql node_id_d
    end
  end

  # -- short test support extensions

  Want_Stdout_Stderr = -> tcm do

    tcm.include TestSupport_::Want_Stdout_Stderr::Test_Context_Instance_Methods
    ::Kernel._CHANGED
    # tcm.send :define_method, :expect, tcm.instance_method( :expect )  # :+#this-rspec-annoyance
    NIL
  end

  Want_Emission_Fail_Early = -> tcc do
    Common_.test_support::Want_Emission_Fail_Early[ tcc ]
  end

  Want_Event = -> tcc, x=nil do  # deprected-ish. as you can, etc
    Common_.test_support::Want_Emission[ tcc, x ]
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  # -- objects

  API_expag_ = Lazy_.call do
    Home_::Zerk_lib_[]::API::InterfaceExpressionAgent::THE_LEGACY_CLASS.
      via_expression_agent_injection :_no_injection_from_SN
  end

  # -- functions

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
          _head = Home_.lib_.system.defaults.dev_tmpdir_path
          _path = ::File.join _head, 'snaggle'
          o = Home_.lib_.system_lib::Filesystem::Tmpdir.with(
            :path, _path,
            :be_verbose, do_debug,
            :debug_IO, debug_IO,
          )
        end
        o
      end
    end
  end.call

  Path_alpha_ = Common_.memoize do

    ::File.join( Fixture_tree_[ :mock_project_alpha ], 'doc/issues.md' )
  end

  # --

  Home_::Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = true
  EMPTY_P_ = Home_::EMPTY_P_
  EMPTY_S_ = Home_::EMPTY_S_
  NIL_ = nil
  NIL = nil  # open [#sli-016.C]
  NOTHING_ = Home_::NOTHING_
  NEWLINE_ = "\n"
  SPACE_ = Home_::SPACE_
  TS_ = self
  UNDERSCORE_ = Home_::UNDERSCORE_
  Zerk_lib_ = Home_::Zerk_lib_
end
# #tombstone-A (temporary)
