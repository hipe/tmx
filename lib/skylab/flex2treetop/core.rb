require_relative '../callback/core'

module Skylab::Flex2Treetop

  FIXTURE_H__ = {
    mini:     'flex2treetop/test/fixtures/mini.flex',
    tokens:   'css-convert/css/parser/tokens.flex',
    fixthix:  'flex2treetop/test/fixtures/fixthis.flex'
  }.freeze

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  VERSION = '0.0.2'

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  module Lib_  # :+[#su-001]

    sidesys = Autoloader_.build_require_sidesystem_proc

    API_lib = -> * a do
      if a.length.zero?
        HL__[]::API
      else
        HL__[]::API.via_arglist a
      end
    end

    Bsc__  = sidesys[ :Basic ]

    CLI_lib = -> do
      HL__[]::CLI
    end

    Delegating = -> cls do
      HL__[]::Delegating[ cls ]
    end

    Funcy_globful = -> x do
      MH__[].funcy_globful x
    end

    HL__ = sidesys[ :Headless ]

    MH__ = sidesys[ :MetaHell ]

    OptionParser = -> { require 'optparse' ; ::OptionParser }

    Strange = -> x do
      MH__[].strange x
    end

    String_lib = -> do
      Bsc__[]::String
    end

    StringScanner = -> { require 'strscan' ; ::StringScanner }

    Stdib_tmpdir = -> { require 'tmpdir' ; ::Dir }

    System = -> do
      HL__[].system
    end
  end

  module CLI
    def self.new i, o, e  # #hook-out[tmx]
      CLI::Client.new i, o, e
    end
  end

  class CLI::Client

    Lib_::CLI_lib[].action self, :DSL

    Lib_::CLI_lib[].client self, :client_instance_methods, :three_streams_notify

    def initialize i, o, e
      @do_ping_API = false
      @param_x_a = []
      three_streams_notify i, o, e
      super()
    end

  private

    def default_action_i
      :translate
    end

    def build_option_parser

      o = Lib_::OptionParser[].new

      o.base.long[ 'ping' ] = ::OptionParser::Switch::OptionalArgument.
          new do |x|
        touch_queue_without_initial_queue
        enqueue_with_args :ping, x
      end

      o.base.long[ 'API' ] = ::OptionParser::Switch::NoArgument.new do
        @do_ping_API = true
      end

      o.on('-g=<grammar>', '--grammar=<grammar>',
        "nest treetop output in this grammar declaration",
        "(e.g. \"Mod1::Mod2::Grammar\")."
      ) do |s|
        @param_x_a.push :wrap_in_grammar_s, s
      end

      o.on('-s', '--sexp',
        "show sexp of parsed flex file.",
        "circumvent normal output. (devel)"
      ) do
        @param_x_a << :show_sexp_only
      end

      o.on('--flex-tt',
       'write the flex treetop grammar to stdout.',
       "circumvent normal output. (devel)"
      ) do
        enqueue_without_initial_queue :show_flex2tt_tt_grammar
      end

      o.on( '-t', '--tempdir[=<dir>]',
        '[write, ]read flex treetop grammar',
        '[from ,] to the filesystem as opposed to in memory. (devel)',
        'multiple times will supress normal output.',
        'use --clear (below) to force a rewrite of the file(s).'
      ) do |s|
        s and @param_x_a.push :FS_parser_dir, s
        @did_tmpdir_option_once ||= begin ; first_time = true end
        if first_time
          @param_x_a << :use_FS_parser
        else
          @param_x_a << :endpoint_is_FS_parser
        end
      end

      o.on('-c', '--clear',
        'if used in conjuction with --tmpdir,',
        'clear any existing parser files first (devel).'
      ) do
        @param_x_a << :clear_generated_files
      end

      o.on '-h', '--help', 'this' do
        enqueue_without_initial_queue :help
      end
      o.on('-v', '--version', 'show version') do
        enqueue_without_initial_queue :version
      end
      o.on('--test', '(shows some visual tests that can be run)') do
        enqueue_without_initial_queue :show_tests
      end
      o
    end

    def ping arg=nil
      if @do_ping_API
        invoke_API :ping, :arg_1, arg
      elsif arg
        "(#{ arg })"
      else
        ping_simple
      end
    end

    def ping_simple
      @IO_adapter.errstream.puts "hello from flex2treetop."
      :hello_from_flex2treetop
    end

    def show_flex2tt_tt_grammar
      @IO_adapter.outstream.write TREETOP_GRAMMAR__
      PROCEDE__
    end

    def show_tests
      pwd = ::Pathname.pwd
      emit_info_line say { "#{ kbd 'some nerks to try:' }" }
      FIXTURE_H__.each_pair do |k, path|
        pn = ::Skylab.dir_pathname.join path
        rel_pn = pn.relative_path_from pwd
        if pn.exist?
          emit_payload_line "  #{ program_name } #{ rel_pn }"
        else
          emit_error_line "( missing example - fix this - #{ rel_pn })"
        end
      end
      PROCEDE__
    end

    def version
      s = invoke_API :version
      s and emit_payload_line s
      nil
    end

    def translate flexfile
      @param_x_a.unshift :translate,
        :emit_info_string_p, method( :emit_info_line ),
        :emit_info_line_p, method( :emit_info_line ),
        :flexfile, flexfile,
        :paystream_via, :IO, @IO_adapter.outstream,
        :pp_IO_for_show_sexp, @IO_adapter.errstream
      _endpoint_symbol = API.invoke_with_iambic @param_x_a
      resolve_some_exit_behavior_and_value_for_endpoint_symbol _endpoint_symbol
    end

    def resolve_some_exit_behavior_and_value_for_endpoint_symbol i
      case i
      when :showed_sexp, :translated ; 0
      when :parser_dir_not_exist ; rslv_exit_when_parser_dir_not_exist
      when :parse_failure ; rslv_exit_when_parse_failure
      when :translate_failure ; rslv_exit_when_translate_failure
      else rslv_exit_for_unexpected_endpoint_symbol( i ) end
    end

    def rslv_exit_when_parser_dir_not_exist
      help_yielder << invite_line
      GENERIC_ERROR_EXITSTATUS__
    end

    def rslv_exit_when_parse_failure
      help_yielder << say_try_again
      GENERIC_ERROR_EXITSTATUS__
    end

    def say_try_again
      "try fixing the issues in the flexfile grammar (or our grammar grammar)?"
    end

    def rslv_exit_when_translate_failure
      help_yielder << say_translate_failure
      GENERIC_ERROR_EXITSTATUS__
    end

    def say_translate_failure
      "had to stop mid-translation because of the above issue."
    end

    def rslv_exit_for_unexpected_endpoint_symbol i
      help_yielder << say_unexp_endpoint_symbol( i )
      GENERIC_ERROR_EXITSTATUS__
    end

    def say_unexp_endpoint_symbol i
      "encountered unexpected endpoint symbol '#{ i }'. not sure if OK."
    end
    GENERIC_ERROR_EXITSTATUS__ = 1

    # ~ support for multiple "action-like" methods

    def invoke_API * x_a
      x_a[ 1, 0 ] = :errstream, @IO_adapter.errstream
      API.invoke_with_iambic x_a
    end

    def resolve_upstream_status_tuple  # #hook-in to [hl], up for chopping soon
      r = resolve_instream_status_tuple
      r or help_yielder << invite_line
      r
    end
  end

  module Iambics_  # #storypoint-210

    Lib_::API_lib[].iambic_builder self

    parameter__parse_class

    class Parameter
      class Parse
      private
        def flag=
          @param.argument_arity_i = :zero
          @param.ivar = @x_a.shift
          send :optional= ; nil
        end
        def optional=
          @param.parameter_arity_i = :zero_or_one ; nil
        end
      end
      attr_accessor :parameter_arity_i
    end
    instance_methods_module
    module Instance_Methods
      PROTOTYPE_PARAMETER = Parameter.new do |p|
        p.argument_arity_i = :one
        p.has_generated_writer = true
        p.parameter_arity_i = :one
      end
    private
      def initialize_with_iambic x_a
        nilify_and_absorb_iambic_fully x_a
        assert_parameter_arity
      end
      def assert_parameter_arity
        scn = self.class.get_parameter_scanner ; y = nil
        while (( param = scn.gets ))
          :one == param.parameter_arity_i or next
          x = instance_variable_get param.ivar
          x.nil? or next
          ( y ||= [] ) << param
        end
        y and raise ::ArgumentError, "'#{ moniker_for_errmsg }' #{
          }is missing the required iambic parameter(s) #{
           }#{ y.map { |p| "'#{ p.param_i }'" } * ' and ' }" ; nil
      end
      def moniker_for_errmsg
        o = F2TT_::Lib_::Old_name_lib[]
        o.naturalize o.normify o.const_basename self.class.name
      end
    end
  end

  module API

    Lib_::API_lib[ self, :with_service, :with_session, :with_actions ]

    action_class
    class Action

      parameter_members
      def initialize x_a
        initialize_with_iambic x_a
        @client = Services_For_API_Action__.new @service, @session
        @service = @session = nil  # #storypoint-250
        super()
      end
    private
      def initialize_with_iambic x_a
        nilify_and_absorb_iambic_fully x_a
      end
      def emit_error_string s
        @errstream.puts s ; nil
      end
      def emit_info_line s
        @errstream.puts s ; nil
      end
    end

    class Services_For_API_Action__

      Lib_::Delegating[ self ]

      delegating :to, :@session, %i( program_name )

      def initialize service, session
        @service = service ; @session = session ; nil
      end
    end

    class Actions::Ping < Action
      params :arg_1, [ :ivar, :@arg_x ]

      def execute
        @errstream.puts "helo:(#{ @arg_x })"
        :_hello_from_API_
      end
    end

    class Actions::Version < Action

      params :bare, %i( argument_arity zero )

      def execute
        if @bare
          "#{ VERSION }"
        else
          "#{ @client.program_name }: #{ VERSION }"
        end
      end
    end

    session_class
    class Session
    private
      def program_name=
        @service._CHANGE_PROGRAM_NAME! @x_a.shift ; nil
      end
    public
      def program_name
        @service.program_name
      end
    end

    service_class
    class Service
      def initialize *_
        @program_name = nil
        super
      end
      def _CHANGE_PROGRAM_NAME! x
        @program_name = x ; nil
      end
      def program_name
        @program_name || ::File.basename( $PROGRAM_NAME )
      end
    end

    Pathname_writer__ = -> param do
      ivar = param.ivar
      -> do
        x = @x_a.shift and x = Convert_to_pathname_if_necessary__[ x ]
        instance_variable_set ivar, x ; nil
      end
    end

    Convert_to_pathname_if_necessary__ = -> x do
      x and ( x.respond_to?( :relative_path_from ) ? x : ::Pathname.new( x ) )
    end

    class Actions::Translate < Action

      Iambics_[ self,
        :params,
        * parameter_members,  # #storypoint-315
        :case_sensitive, %i( flag @is_case_sensitive ),
        :clear_generated_files, %i( flag @do_clear_files ),
        :endpoint_is_FS_parser, %i( flag @endpoint_is_FS_parser ),
        :flexfile, [ :write_with, Pathname_writer__ ],
        :force, %i( flag @force_is_present ),
        :FS_parser_dir, [ :write_with, Pathname_writer__, :optional ],
        :emit_info_line_p,
        :emit_info_string_p,
        :paystream_via, %w( has_custom_writer ),
        :pp_IO_for_show_sexp,
        :show_sexp_only, %i( flag @do_show_sexp_only ),
        :use_FS_parser, %i( flag @do_use_FS_parser ),
        :verbose, [ :flag, :@be_verbose, :default, true ],
        :wrap_in_grammar_s, %i( optional ) ]
      private
        def paystream_via=  # a diadic term
          @paystream_via = :_provided_
          case (( type_i = @x_a.shift ))
          when :IO   ; @pay_i = :IO   ; @pay_x = @x_a.shift
          when :path ; @pay_i = :path ; @pay_x = @x_a.shift
          else raise ::ArgumentError, "no: '#{ type_i }'"
          end ; nil
        end
      public

      def execute
        endpoint_symbol = resolve_some_endpoint_symbol_for_paystream
        if :_procede_ == endpoint_symbol
          endpoint_symbol = resolve_endpoint_symbol_when_IO_resolved
        end
        endpoint_symbol
      end

    private

      def resolve_some_endpoint_symbol_for_paystream
        send :"rslv_IO_when_#{ @pay_i }"
      end

      def rslv_IO_when_path
        pay_x = @pay_x ; @pay_x = @pay_IO = nil
        @pay_pn = Convert_to_pathname_if_necessary__[ pay_x ]
        _listener = Yes_No_Listener_[ self, :IO_resolved, :cannot_resolve_IO ]
        _endpoint_symbol = Resolve_IO__[ :force_is_present, @force_is_present,
          :infile, @flexfile, :listener, _listener, :out_pn, @pay_pn ]
        _endpoint_symbol
      end

      def rslv_IO_when_IO
        @verb_s = "outputting"
        @pay_IO = @pay_x ; @pay_x = @pay_pn = nil
        :_procede_
      end

      def cannot_resolve_IO_infile_is_not_file ev
        emit_error_string "was #{ ev.ftype } not file - #{ @flexfile }"
        :not_file
      end

      def cannot_resolve_IO_infile_not_found ev
        emit_error_string "#{ ev.message }"
        :not_found
      end

      def cannot_resolve_IO_outfile_does_not_appear_generated_string ev
        emit_error_string "won't overwrite, does not appear generated - #{
          }#{ @pay_pn }"
        :modified
      end

      def cannot_resolve_IO_outfile_exists_and_force_is_not_present ev
        emit_error_string(
          "exists, won't overwrite without force: #{ ev.to_path }" )
        :exists
      end

      def IO_resolved_when_outfile_empty ev
        emit_info_line "(overwriting empty file: #{ ev.to_path })"
        send :IO_resolved_when_overwriting_non_empty_file, ev
      end

      def IO_resolved_when_overwriting_non_empty_file ev
        @verb_s = 'overwriting'
        :_procede_
      end

      def IO_resolved_when_outfile_not_exist ev
        @verb_s = 'creating'
        :_procede_
      end

      def resolve_endpoint_symbol_when_IO_resolved
        _outstream = resolve_any_outstream
        _outstream_moniker = resolve_some_outstream_moniker
        Translate__[
          :be_verbose, @be_verbose,
          :do_clear_files, @do_clear_files,
          :do_show_sexp_only, @do_show_sexp_only,
          :do_use_FS_parser, @do_use_FS_parser,
          :emit_info_line_p, @emit_info_line_p,
          :emit_info_string_p, @emit_info_string_p,
          :endpoint_is_FS_parser, @endpoint_is_FS_parser,
          :FS_parser_dir, @FS_parser_dir,
          :instream, @flexfile.open( 'r' ),
          :instream_moniker, @flexfile.to_path,
          :outstream, _outstream,
          :outstream_moniker, _outstream_moniker,
          :pp_IO_for_show_sexp, @pp_IO_for_show_sexp,
          :verb_s, @verb_s,
          :wrap_in_grammar_s, @wrap_in_grammar_s ]
      end

      def resolve_any_outstream
        if is_nonstandard_endpoint
          :_no_outstream_
        else
          send :"rslv_any_outstream_when_#{ @pay_i }"
        end
      end
      def rslv_any_outstream_when_IO
        @pay_IO
      end
      def rslv_any_outstream_when_path
        @pay_pn.open WRITEMODE_
      end

      def resolve_some_outstream_moniker
        send :"rslv_some_outstream_moniker_when_#{ @pay_i }"
      end
      def rslv_some_outstream_moniker_when_path
        @pay_pn.to_path
      end
      def rslv_some_outstream_moniker_when_IO
        PAYSTREAM__
      end
      PAYSTREAM__ = "«paystream»".freeze  # :+#guillemets

      def is_nonstandard_endpoint
        @do_show_sexp_only || @endpoint_is_FS_parser
      end
    end

    class Resolve_IO__  # :+#tributary-agent

      Lib_::Funcy_globful[ self ]

      Lib_::API_lib[].simple_monadic_iambic_writers self,
        :force_is_present, :infile, :listener, :out_pn

      def initialize * x_a
        absorb_iambic_fully x_a ; nil
      end
      def execute
        @infile_stat = @infile.stat
        when_infile_exist
      rescue ::Errno::ENOENT => e
        when_infile_not_exist e
      end
    private
      def when_infile_not_exist e
        call_digraph_listeners :no, :infile_not_found do e end
      end
      def when_infile_exist
        if FILE_FTYPE_ == @infile_stat.ftype
          when_infile_is_file
        else
          call_digraph_listeners :no, :infile_is_not_file do @infile_stat end
        end
      end
      def when_infile_is_file
        @outfile_stat = @out_pn.stat
        when_outfile_exist
      rescue ::Errno::ENOENT
        when_outfile_not_exist
      end
      def when_outfile_not_exist
        call_digraph_listeners :yes, :when_outfile_not_exist do @out_pn end
      end
      def when_outfile_exist
        if FILE_FTYPE_ == @outfile_stat.ftype
          when_outfile_is_file
        else
          call_digraph_listeners :no, :outfile_is_not_file do @outfile_stat end
        end
      end
      def when_outfile_is_file
        if @outfile_stat.size.zero?
          call_digraph_listeners :yes, :when_outfile_empty do @out_pn end
        else
          when_outfile_nonzero_length
        end
      end
      def when_outfile_nonzero_length
        if @force_is_present
          when_force
        else
          call_digraph_listeners :no, :outfile_exists_and_force_is_not_present do @out_pn end
        end
      end
      def when_force
        @out_pn.open( 'r' ) do |fh| @first_line = fh.gets end
        if AUTOGENERATED_RX =~ @first_line
          call_digraph_listeners :yes, :when_overwriting_non_empty_file do @out_pn end
        else
          call_digraph_listeners :no, :outfile_does_not_appear_generated do @first_line end
        end
      end
      def call_digraph_listeners * i_a, &p
        @listener.call_any_listener( * i_a, & p )
      end
    end

    CEASE__ = false ; PROCEDE__ = true
  end

  Yes_No_Listener_ = -> listener, yes_i, no_i do
    map_h = { yes: yes_i, no: no_i }
    Proc_As_Listener_.new do |* i_a, & p|
      i_a[ 0 ] = map_h.fetch i_a.first
      listener.send :"#{ i_a * '_' }", p.call
    end
  end

  Proc_As_Listener_ = Callback_::Listener::Proc_As_Listener

  Assert_open_stream__ = -> param do
    ivar = param.ivar ; par_i = param.param_i
    -> do
      x = @x_a.shift
      x && ! x.closed? or raise ::ArgumentError, "for '#{ par_i }' #{
        }need open stream, had #{ Lib_::Strange[ x ] }"
      instance_variable_set ivar, x ; nil
    end
  end

  Class_as_function__ = -> p do  # #storypoint-415
    the_class = Callback_.memoize p
    -> * x_a do
      the_class[].new( x_a ).endpoint_symbol
    end
  end

  Translate__ = Class_as_function__[ -> do class Translate____

    Iambics_[ self, :params,
      :be_verbose,
      :do_clear_files, %i( optional ),
      :do_show_sexp_only, %i( optional ),
      :do_use_FS_parser, %i( optional ),
      :emit_info_line_p,
      :emit_info_string_p,
      :endpoint_is_FS_parser, %i( optional ),
      :FS_parser_dir, %i( optional ),
      :instream,  [ :write_with, Assert_open_stream__ ],
      :instream_moniker,
      :outstream, %i( has_custom_writer ),
      :outstream_moniker,
      :pp_IO_for_show_sexp,
      :verb_s,
      :wrap_in_grammar_s, %i( optional ) ]

    def initialize x_a
      initialize_with_iambic x_a
      super()
    end

    def endpoint_symbol
      @be_verbose and is_conventional_endpoint and emit_info_string say_v_phrase
      @do_use_FS_parser and es = any_endpoint_with_FS_parser
      es || endpoint_symbol_from_read_and_translate_file
    end

  private

    def is_conventional_endpoint
      ! ( @do_show_sexp_only || @endpoint_is_FS_parser )
    end

    def outstream=
      param = self.class.fetch_parameter :outstream
      if is_conventional_endpoint
        _p = Assert_open_stream__[ param ]
        instance_exec( & _p )
      else
        _outstream = @x_a.shift
        :_no_outstream_ == _outstream or raise ::ArgumentError,
          "pass no #{ param.param_i } when 'do_show_sexp_only'"
        @outstream = _outstream  # still it must pass arity check
      end ; nil
    end

    # ~ we comport with [#hl-154] control-flow method-naming idioms

    def say_v_phrase
      "#{ @verb_s } #{ @outstream_moniker } with #{ @instream_moniker }"
    end

    def any_endpoint_with_FS_parser
      @FS_parser_dir ||= resolve_some_FS_parser_dir
      es = any_endpoint_with_FS_parser_dir
      es || any_endpoint_from_resolve_and_use_generated_files
    end

    def resolve_some_FS_parser_dir
      ::Pathname.new Lib_::Stdlib_tmpdir[].tmpdir
    end

    def any_endpoint_with_FS_parser_dir
      es = any_endpoint_from_get_FS_parser_dir_stat
      es || any_endpoint_with_FS_parser_dir_stat
    end

    def any_endpoint_from_get_FS_parser_dir_stat
      @stat = @FS_parser_dir.stat ; nil
    rescue ::Errno::ENOENT => e
      endpoint_when_parser_dir_not_exist e
    end

    def endpoint_when_parser_dir_not_exist e
      emit_error_string e.message
      :parser_dir_not_exist
    end

    def any_endpoint_with_FS_parser_dir_stat
      DIR_FTYPE_ != @stat.ftype and
        endpoint_when_parser_dir_not_dir
    end

    def endpoint_when_parser_dir_not_dir
      emit_error_string say_parser_dir_is_not_dir
      :parser_dir_is_not_dir
    end

    def say_parser_dir_is_not_dir
      "parser dir was #{ @stat.ftype } - #{ @FS_parser_dir }"
    end

    def any_endpoint_from_resolve_and_use_generated_files
      @grammar_pathname = @FS_parser_dir.join 'flex-to-treetop.treetop'
      @compiled_grammar_pathname = @FS_parser_dir.join 'flex-to-treetop.rb'
      @do_clear_files and clear_generated_files
      es = any_endpoint_from_resolve_compiled_grammar_file
      es || any_endpoint_from_attempt_to_use_generated_files
    end

    def clear_generated_files
      fu = bld_file_utils
      [ @grammar_pathname, @compiled_grammar_pathname ].each do |pn|
        pn.exist? or next
        fu.rm pn.to_path
      end ; nil
    end
    def bld_file_utils
      Lib_::System[].filesystem.file_utils_controller.new do |msg|
        emit_info_line "(futils:) #{ msg }" ; nil
      end
    end

    def any_endpoint_from_resolve_compiled_grammar_file
      if @compiled_grammar_pathname.exist?
        emit_info_string say_using_compiled_grammar_pathname ; nil
      else
        any_endpoint_from_recompile
      end
    end

    def say_using_compiled_grammar_pathname
      "using: #{ @compiled_grammar_pathname.to_path }"
    end

    def any_endpoint_from_recompile
      es = any_endpoint_from_resolve_grammar_file( y = [] )
      es or any_endpoint_from_finish_recompile( y )
    end

    def any_endpoint_from_resolve_grammar_file y
      ! @grammar_pathname.exist? and any_endpoint_from_write_grammar_file y
    end

    def any_endpoint_from_write_grammar_file  y
      bytes = nil
      @grammar_pathname.open WRITEMODE_ do |fh|
        bytes = fh.write TREETOP_GRAMMAR__
      end
      y << "wrote #{ @grammar_pathname } (#{ bytes } bytes)." ; nil
    end

    def any_endpoint_from_finish_recompile y
      y << "writing #{ @compiled_grammar_pathname }."
      emit_info_string y * TERM_SEPARATOR_STRING_
      bytes = Svcs__::Treetop[]::Compiler::GrammarCompiler.
        new.compile @grammar_pathname.to_path,
          @compiled_grammar_pathname.to_path
      emit_info_string "(treetop wrote #{ bytes } bytes)" ; nil
    end

    def any_endpoint_from_attempt_to_use_generated_files
      load_grammar_subclasses_if_necessary
      if defined? FlexFileParser
        emit_error_string say_cannot_use_FS_because_ff_parser_already_loaded
        :cannot_use_FS_flex_file_parser_already_loaded
      else
        any_endpoint_from_load_and_use_generated_files
      end
    end

    def say_cannot_use_FS_because_ff_parser_already_loaded
      "cannot use FS parser, a parser class is already loaded #{
        }(maybe because you are running all the tests at once?)"
    end

    def any_endpoint_from_load_and_use_generated_files
      require get_normalized_requireable_compiled_grammar_path
      @endpoint_is_FS_parser && endpoint_when_reached_FS_parser
    end

    def load_grammar_subclasses_if_necessary
      Svcs__::CommonNode[] ; nil
    end

    def get_normalized_requireable_compiled_grammar_path
      pn_ = @compiled_grammar_pathname.absolute? ?
        @compiled_grammar_pathname : @compiled_grammar_pathname.expand_path
      pn_.sub_ext( '' ).to_path
    end

    def endpoint_when_reached_FS_parser
      emit_info_string say_reached_FS_parser_as_endpoint
      :filesystem_touched
    end

    def say_reached_FS_parser_as_endpoint
      "touched files. nothing more to do."
    end

    def endpoint_symbol_from_read_and_translate_file
      load_grammar_subclasses_if_necessary
      Translate_stream__[
        :do_show_sexp_only, @do_show_sexp_only,
        :emit_info_line_p, @emit_info_line_p,
        :emit_info_string_p, @emit_info_string_p,
        :instream, @instream,
        :outstream, @outstream,
        :pp_IO_for_show_sexp, @pp_IO_for_show_sexp,
        :wrap_in_grammar_s, @wrap_in_grammar_s ]
    end

    def emit_info_line s
      @emit_info_line_p[ s ] ; nil
    end

    def emit_info_string s
      @emit_info_string_p[ s ] ; nil
    end

    def emit_error_string s
      @emit_info_string_p[ s ] ; nil
    end

    self
  end end ]

  Translate_stream__ = Class_as_function__[ -> do

  class Translate_Stream__

    Iambics_[ self, :params,
      :do_show_sexp_only, %i( optional ),
      :emit_info_line_p,
      :emit_info_string_p,
      :instream,
      :outstream,
      :pp_IO_for_show_sexp,
      :wrap_in_grammar_s, %i( optional ) ]

    def initialize x_a
      initialize_with_iambic x_a
      super()
    end

    def endpoint_symbol
      i = endpoint_i
    ensure
      @do_show_sexp_only or @outstream.close
      @instream.closed? or fail 'sanity - instream still open?'
      i
    end

  private

    def endpoint_i
      @parser = parser_class.new
      @whole_file = @instream.read
      @instream.close
      @parser_result_x = @parser.parse @whole_file
      if @parser_result_x
        endpoint_symbol_when_parse_result
      else
        endpoint_symbol_when_no_parse_result
      end
    end

    def parser_class
      if Flex2Treetop.const_defined? :Parser___
        Flex2Treetop::Parser___
      else
        bld_and_set_parser_class
      end
    end

    def bld_and_set_parser_class
      defined? FlexFileParser or load_treetop_grammar  # #storypoint-510
      cls = Flex2Treetop.const_set :Parser___, ::Class.new( FlexFileParser )
      cls.class_exec( & ENHANCE_PARSER_CLASS_P__ )
      cls
    end

    def load_treetop_grammar
      Svcs__::Treetop[].load_from_string TREETOP_GRAMMAR__
    end

    def endpoint_symbol_when_no_parse_result
      emit_error_string say_no_parse_result
      :parse_failure
    end
    def say_no_parse_result
      @parser.failure_reason || "Got nil from parse without reason"
    end

    def endpoint_symbol_when_parse_result
      if @do_show_sexp_only
        endpoint_symbol_when_show_sexp
      else
        endpoint_symbol_when_execute_translation
      end
    end
    def endpoint_symbol_when_show_sexp
      Svcs__::PP[].pp @parser_result_x.sexp, @pp_IO_for_show_sexp
      :showed_sexp
    end
    def endpoint_symbol_when_execute_translation
      @outstream.puts autogenerated_line
      _i = @parser_result_x.sexp.translate build_translation_client
      _i || :translate_failure
    end

    def autogenerated_line
      _rx = Lib_::String_lib[].mustache_regexp
      AUTOGENNED_TEMPLATE__.gsub _rx do
        send :"resolve_any_template_value_for_#{ $1 }"
      end
    end
    AUTOGENNED_TEMPLATE__ =
      "# Autogenerated by flex2treetop on {{now}}. Edits may be lost.".freeze

    def resolve_any_template_value_for_now
      ::Time.now.strftime TIME_FORMAT__
    end

    TIME_FORMAT__ = '%Y-%m-%d %I:%M:%S%P %Z'.freeze

    def emit_error_string s
      @emit_info_string_p[ s ] ; nil
    end

    def build_translation_client
      cli = Services_for_Tranlsation_Agent__.
        new @emit_info_line_p, @wrap_in_grammar_s
      cli.builder = Svcs__::Treetop_Builder[].new @outstream
      cli.grammar_s = TREETOP_GRAMMAR__
      cli
    end
    class Services_for_Tranlsation_Agent__
      def initialize emit_info_line_p, wrap_in_g_s
        @emit_info_line_p = emit_info_line_p
        @is_case_sensitive = true
        @wrap_in_g_s = wrap_in_g_s ;
      end
      attr_reader :is_case_sensitive
      attr_accessor :builder, :grammar_s
      def case_insensitive_notify
        @is_case_sensitive = false ; nil
      end
      def translate_name x
        x  # could be used to add prefixes etc
      end
      def emit_info_line s
        @emit_info_line_p[ s ] ; nil
      end
      def wrap_in_grammar_s
        @wrap_in_g_s
      end
    end
    self
  end end ]

  class Sexpesque < ::Array
    class << self
      def add_hook whenn, &what
        @hooks ||= ::Hash.new{ |h,k| h[k] = [] }
        @hooks[whenn].push(what)
      end

      def guess_node_name
        m = to_s.match(/([^:]+)Sexp$/) and
          m[1].gsub(/([a-z])([A-Z])/){ "#{$1}_#{$2}" }.downcase.intern
      end

      def hooks_for(whenn)
        instance_variable_defined?('@hooks') ? @hooks[whenn] : []
      end

      def from_syntax_node name, node
        new(name, node).extend SyntaxNodeHaver
      end

      def traditional name, *rest
        new(name, *rest)
      end

      def hashy name, hash
        new(name, hash).extend Hashy
      end

      attr_writer :node_name

      def node_name *a
        a.any? ? (@node_name = a.first) :
        (instance_variable_defined?('@node_name') ? @node_name :
          (@node_name = guess_node_name))
      end

      def list list
        traditional(node_name, *list)
      end

      def terminal!
        add_hook(:post_init){ |me| me.stringify_terminal_syntax_node! }
      end
    end

    # all around here has been marked for confusion [#002]

    def initialize name, *rest
      super [name, *rest]
      self.class.hooks_for(:post_init).each{ |h| h.call(self) }
    end

    def stringify_terminal_syntax_node!
      self[1] = self[1].text_value
      @syntax_node = nil
      class << self
        alias_method :my_text_value, :last
      end
    end

    module SyntaxNodeHaver
      def syntax_node
        instance_variable_defined?('@syntax_node') ? @syntax_node : last
      end
    end

    module Hashy
      class << self
        def extended obj
          class << obj
            alias_method :children, :last
          end
        end
      end
    end
  end

  module Node_Module_Methods__

    def at str
      ats( str ).first
    end

    def ats path
      path = at_compile(path) if path.kind_of?(::String)
      here = path.first
      cx = (here == '*') ? elements : (elements[here] ? [elements[here]] : [])
      if path.size > 1 && cx.any?
        child_path = path[1..-1]
        cx = cx.map do |c|
          c.extend Node_Module_Methods__ unless
            c.respond_to?(:ats)
          c.ats(child_path)
        end.flatten
      end
      cx
    end
    def at_compile str
      res = []
      s = Lib_::StringScanner[].new(str)
      begin
        if s.scan(/\*/)
          res.push '*'
        elsif s.scan(/\[/)
          d = s.scan(/\d+/) or fail("expecting digit had #{s.rest.inspect}")
          s.scan(/\]/) or fail("expecting ']' had #{s.rest.inspect}")
          res.push d.to_i
        else
          fail("expecting '*' or '[' near #{s.rest.inspect}")
        end
      end until s.eos?
      res
    end
    def sexp_at str
      # (n = at(str)) ? n.sexp : nil
      n = at(str) or return nil
      n.respond_to?(:sexp) and return n.sexp
      n.text_value == '' and return nil
      fail("where is sexp for n")
    end
    def sexps_at str
      ats(str).map(&:sexp)
    end
    def composite_sexp my_name, *children
      with_names = {}
      children.each do |name|
        got = send(name)
        sexp =
          if got.respond_to?(:sexp)
            got.sexp
          else
            fail('why does "got" have no sexp')
          end
        with_names[name] = sexp
      end
      if my_name.kind_of? ::Class
        my_name.hashy(my_name.node_name, with_names)
      else
        Sexpesque.hashy(my_name, with_names)
      end
    end
    def list_sexp *foos
      foos.compact!
      foos # yeah, that's all this does
    end
    def auto_sexp
      if respond_to?(:sexp_class)
        sexp_class.from_syntax_node(sexp_class.node_name, self)
      elsif ! elements.nil? && elements.index{ |n| n.respond_to?(:sexp) }
        cx = elements.map{ |n| n.respond_to?(:sexp) ? n.sexp : n.text_value }
        ::Skylab::Flex2Treetop::AutoSexp.traditional(guess_node_name, *cx)
      else
        ::Skylab::Flex2Treetop::AutoSexp.traditional(guess_node_name, text_value)
      end
    end
    def guess_node_name
      a = singleton_class.ancestors
      modul = a.detect do |mod|
        ::Module == mod.class  # special circumstances
      end
      modul or fail "no module in ancestor chain?"
      md = modul.name.match %r([^:0-9]+(?=\d+$))
      md or raise "hack failed - failed to match against #{ modul.name.inspect}"
      md[ 0 ].gsub(/([a-z])([A-Z])/){ "#{$1}_#{$2}" }.downcase.intern
    end
    def singleton_class
      @sc ||= class << self; self end
    end
  end

  Svcs__ = ::Module.new

  Svcs__::CommonNode = Callback_.memoize do

    # all of the below "public"-looking constants must be
    # visible to the grammar when it loads

    class CommonNode < Svcs__::Treetop[]::Runtime::SyntaxNode
      include Node_Module_Methods__
    end
    module AutoNodey
      include Node_Module_Methods__
      def sexp
        auto_sexp
      end
    end
    class AutoNode < CommonNode
      include AutoNodey
    end
    CommonNode
  end

  module RuleWriter
    class Rule
      def initialize client=nil, rule_name=nil, pattern_like=nil
        @pattern_like = pattern_like
        @request_client = client ; @rule_name = rule_name
      end
      attr_reader :pattern_like, :request_client, :rule_name
      attr_writer :rule_name, :pattern_like
      def write
        _name = translate_name @rule_name
        bldr = builder
        bldr.rule_declaration _name do
          bldr.write ONE_SINGLE_SPACE__ * bldr.level
          @pattern_like.translate @request_client
          bldr.newline
        end
      end
      def translate_name *a
        @request_client.translate_name( * a )
      end
      def builder
        @request_client.builder
      end
    end
  end
  ONE_SINGLE_SPACE__ = ' '.freeze
  module RuleWriter::InstanceMethods
    def write_rule request_client
      yield( build = RuleWriter::Rule.new(request_client) )
      build.write
    end
  end
  class FileSexp < Sexpesque  # :file

    def translate client
      @builder = client.builder
      @client = client
      @grammar_s = client.wrap_in_grammar_s
      validate and translate_when_valid
    end

    def validate
      is_valid = true
      @grammar_s and ! validate_grammar_s and is_valid = false
      is_valid
    end

    def validate_grammar_s
      const_rxs = '[A-Z][_A-Za-z0-9]*'
      /\A#{ const_rxs }(?:::#{ const_rxs })*\z/ =~ @grammar_s or begin
        @client.emit_info_line say_invalid_grammar_namespace
        CEASE__
      end
    end

    def say_invalid_grammar_namespace
      "grammar namespaces look like \"Foo::BarBaz\". #{
        }this is not a valid grammar namespace: #{ @grammar_s.inspect }"
    end

    def translate_when_valid
      @nest_a_p = [ -> do
        (( @def_a = children[ :definitions ] )).length.zero? or do_defs
        (( @rule_a = children[ :rules ] )).length.zero? or do_rules
        :translated
      end ]
      @grammar_s and add_grammar_frame
      @nest_a_p.pop.call
    end

    def do_defs
      @builder << "# from flex name definitions"
      @def_a.each do |x|
        x.translate @client
      end ; nil
    end

    def do_rules
      @builder << "# flex rules"
      @rule_a.each do |x|
        x.translate @client
      end ; nil
    end

    def add_grammar_frame
      part_a = @grammar_s.split '::'
      gname = part_a.pop
      @nest_a_p << -> do
        @builder.grammar_declaration gname, & @nest_a_p.pop
      end
      while (( const_s = part_a.pop ))
        @nest_a_p << -> do
          cnst_s = const_s
          -> do
            _x = @builder.module_declaration cnst_s, & @nest_a_p.pop
            if Progressive_Output_Adapter__ == _x.class
              :translated
            else
              :abnormal_vendor_response
            end
          end
        end.call
      end
    end
  end
  class StartDeclarationSexp < Sexpesque # :start_declaration
    def translate client
      case children[:declaration_value]
      when 'case-insensitive'
        client.case_insensitive_notify
      else
        client.builder <<
          "# declaration ignored: #{ children[:declaration_value].inspect }"
      end
    end
  end
  class ExplicitRangeSexp < Sexpesque # :explicit_range
    class << self
      def bounded min, max
        min == '0' ? new('..', max) : new(min, '..', max)
      end
      def unbounded min
        new min, '..'
      end
      def exactly int
        new int
      end
    end
    def initialize *parts
      @parts = parts
    end
    def translate client
      client.builder.write " #{ @parts.join '' }"
    end
  end
  class NameDefinitionSexp < Sexpesque # :name_definition
    include RuleWriter::InstanceMethods
    def translate client
      write_rule client do |m|
        m.rule_name = children[:name_definition_name]
        m.pattern_like = children[:name_definition_definition]
      end
    end
  end
  class RuleSexp < Sexpesque # :rule
    include RuleWriter::InstanceMethods

    # this is pure hacksville to deduce meaning from actions as they are
    # usually expressed in the w3c specs with flex files -- which is always
    # just to return the constant corresponding to the token
    def translate client
      action_string = children[:action].my_text_value
      /\A\{(.+)\}\Z/ =~ action_string and action_string = $1
      if /\Areturn ([a-zA-Z_]+);\Z/ =~ action_string
        from_constant client, $1
      elsif %r{\A/\*([a-zA-Z0-9 ]+)\*/\Z} =~ action_string
        from_constant client, $1.gsub(' ','_') # extreme hack!
      else
        client.emit_info_line(
          "notice: Can't deduce a treetop rule name from: #{
            }#{ action_string.inspect } Skipping." )
        nil
      end
    end
    def from_constant client, const
      write_rule(client) do |m|
        m.rule_name = const
        m.pattern_like = children[:pattern]
      end
    end
  end
  class PatternChoiceSexp < Sexpesque # :pattern_choice
    def translate client
      (1..(last = size-1)).each do |idx|
        self[idx].translate(client)
        client.builder.write(' / ') if idx != last
      end
    end
  end
  class PatternSequenceSexp < Sexpesque # :pattern_sequence
    def translate client
      (1..(last = size-1)).each do |idx|
        self[idx].translate(client)
        client.builder.write(' ') if idx != last
      end
    end
  end
  class PatternPartSexp < Sexpesque # :pattern_part
    def translate client
      self[1].translate(client)
      self[2] and self[2][:range].translate(client)
    end
  end
  class UseDefinitionSexp < Sexpesque # :use_definition
    def translate client
      client.builder.write client.translate_name(self[1])
    end
  end
  class LiteralCharsSexp < Sexpesque # :literal_chars
    terminal!
    def translate client
      client.builder.write self[1].inspect # careful! put lit chars in dbl "'s
    end
  end
  class CharClassSexp < Sexpesque # :char_class
    terminal! # no guarantee this will stay this way!
    def translate client
      _s = client.is_case_sensitive ? my_text_value :
        case_insensitive_hack( my_text_value )
      client.builder.write _s
    end
    def case_insensitive_hack txt
      s = ::StringScanner.new(txt)
      out = ''
      while found = s.scan_until(/[a-z]-[a-z]|[A-Z]-[A-Z]/)
        repl = (/[a-z]/ =~ s.matched) ? s.matched.upcase : s.matched.downcase
        s.scan(/#{repl}/) # whether or not it's there scan over it. careful!
        out.concat("#{found}#{repl}")
      end
      "#{out}#{s.rest}"
    end
  end
  class HexSexp < Sexpesque # :hex
    terminal!
    def translate client
      client.builder.write "OHAI_HEX_SEXP"
    end
  end
  class OctalSexp < Sexpesque # :octal
    terminal!
    def translate client
      client.builder.write "OHAI_OCTAL_SEXP"
    end
  end
  class AsciiNullSexp < Sexpesque # :ascii_null
    terminal!
    def translate client
      client.builder.write "OHAI_NULL_SEXP"
    end
  end
  class BackslashOtherSexp < Sexpesque # :backslash_other
    terminal!
    def translate client
      # byte per byte output the thing exactly as it is, but wrapped in quotes
      client.builder.write "\"#{my_text_value}\""
    end
  end
  class ActionSexp < Sexpesque # :action
    terminal! # these are hacked, not used conventionally
  end
  class AutoSexp < Sexpesque
    def translate client
      self[1..size-1].each do |c|
        if c.respond_to?(:translate)
          c.translate(client)
        else
          client.builder.write c
        end
      end
    end
  end

  class Progressive_Output_Adapter__
    def initialize out
      @out = out
    end
    attr_reader :out
    def << *a
      @out.write( * a )
      self
    end
  end

  Svcs__::Treetop_Builder = Callback_.memoize do

  class Treetop_Builder__ < Svcs__::Treetop[]::Compiler::RubyBuilder
    def initialize outstream
      super() # nathan sobo reasonably sets @ruby to a ::String here
      @ruby = Progressive_Output_Adapter__.new outstream
      # but then we hack it to this
    end
    def rule_declaration name, &block
      self << "rule #{name}"
      indented(&block)
      self << "end"
    end
    def grammar_declaration(name, &block)
      self << "grammar #{name}"
      indented(&block)
      self << "end"
      :translated
    end
    def write *a
      @ruby.<<(*a)
    end
    self
  end
  end

  module Svcs__
    o = Callback_.memoize
    PP = o[ -> do require 'pp' ; ::PP end ]
    Treetop = o[ -> do require 'treetop' ; ::Treetop end ]
  end

  AUTOGENERATED_RX = /autogenerated by flex2treetop/i  # (was [#008])
  CEASE__ = false ; PROCEDE__ = true
  DIR_FTYPE_ = 'directory'.freeze
  FILE_FTYPE_ = 'file'.freeze
  WRITEMODE_ = 'w'.freeze
  TERM_SEPARATOR_STRING_ = ' '.freeze

  ENHANCE_PARSER_CLASS_P__ = -> do
    # CompiledParser#failure_reason overridden for less context
    def failure_reason
      return nil unless (tf = terminal_failures) && tf.size > 0
      "Expected " +
        ( tf.size == 1 ?
          tf[0].expected_string.inspect :
          "one of #{tf.map{|f| f.expected_string.inspect}.uniq*', '}"
        ) + " at line #{failure_line}, column #{failure_column} " +
        "(byte #{failure_index+1}) after#{my_input_excerpt}"
    end

    def num_lines_ctx; 4 end

    def my_input_excerpt
      num = num_lines_ctx
      slicey = input[index...failure_index]
      all_lines = slicey.split("\n", -1)
      lines = all_lines.slice(-1 * [all_lines.size, num].min, all_lines.size)
      nums = failure_line.downto(
        [1, failure_line - num + 1].max).to_a.reverse
      w = nums.last.to_s.size # greatest line no as string, how wide?
      ":\n" + nums.zip(lines).map do |no, line|
        ("%#{w}i" % no) + ": #{line}"
      end.join("\n")
    end
  end

  Flex2Treetop = self
end

Skylab::Flex2Treetop::TREETOP_GRAMMAR__ = <<'GRAMMAR'
# The 'pattern' rule below is a subset of the grammar grammar described at
#   http://flex.sourceforge.net/manual/Patterns.html.
#   Note that not all constructs are supported, only those necessary
#   to parse the target flex input files for this project.

module Skylab
module Flex2Treetop
grammar FlexFile
  rule file
    definitions spacey* '%%' spacey* rules spacey*  <CommonNode>
    { def sexp; composite_sexp FileSexp, :definitions, :rules end }
  end
  rule definitions
    spacey*  ( definition_declaration (decl_sep definition_declaration)*  )?
    <CommonNode> {
      def sexp
        list_sexp(sexp_at('[1][0]'), * sexps_at('[1][1]*[1]'))
      end
    }
  end
  rule definition_declaration
    name_definition / start_declaration
  end
  rule name_definition
    name_definition_name [ \t]+ name_definition_definition
    <CommonNode> {
      def sexp
        composite_sexp(
          NameDefinitionSexp, :name_definition_name,
            :name_definition_definition
        )
      end
    }
  end
  rule name_definition_name
    [A-Za-z_] [-a-zA-Z0-9_]* {
      def sexp
        text_value
      end
    }
  end
  rule name_definition_definition
    pattern
  end
  rule start_declaration
    '%' 'option' [ \t]+ 'case-insensitive'
     <CommonNode> {
      def sexp
        StartDeclarationSexp.hashy( :start_declaration,
          :declaration_type  => 'option',
          :declaration_value => 'case-insensitive'
        )
      end
    }
  end
  rule rules
    rool (decl_sep rool)* <CommonNode> {
      def sexp
        list_sexp(sexp_at('[0]'), *sexps_at('[1]*[1]'))
      end
    }
  end
  rule rool
    pattern [ \t]+ action <CommonNode> {
      def sexp
        composite_sexp(RuleSexp, :pattern, :action)
      end
    }
  end
  rule pattern
    pattern_part pattern_part* ( '|' pattern )* <CommonNode> {
      def sexp
        seq = list_sexp(sexp_at('[0]'), * sexps_at('[1]*'))
        choice = sexps_at('[2]*[1]')
        seq_or_pat = seq.size == 1 ? seq.first : PatternSequenceSexp.list(seq)
        if choice.any?
          PatternChoiceSexp.list( [seq_or_pat] + choice )
        else
          seq_or_pat
        end
      end
    }
  end
  rule pattern_part
    ( character_class / string / use_definition / backslashes /
        dot / literal_chars / parenthesized_group ) range?
    <CommonNode> {
      def sexp
        els = [sexp_at('[0]')]
        range = sexp_at('[1]') and els.push(:range => range)
        PatternPartSexp.traditional(:pattern_part, *els)
      end
    }
  end
  rule parenthesized_group
    '(' pattern ')' <AutoNode> { }
  end
  rule character_class
    '[' ( '\]' / !']' . )* ']' <AutoNode> {
      def sexp_class; CharClassSexp end
    }
  end
  rule string
    '"' (!'"' . / '\"')* '"' <AutoNode> { }
  end
  rule use_definition
    '{' name_definition_name '}' <CommonNode> {
      def sexp
        UseDefinitionSexp.traditional(:use_definition, elements[1].text_value)
      end
    }
  end
  rule backslashes
    hex / octal / null / backslash_other
  end
  rule hex
    '\\x' [0-9A-Za-z]+ <AutoNode> { def sexp_class; HexSexp end }
  end
  rule octal
    '\\' [1-9] [0-9]* <AutoNode> { def sexp_class; OctalSexp end }
  end
  rule null
    '\\0' <AutoNode> { def sexp_class; AsciiNullSexp end }
  end
  rule backslash_other
    '\\' [^ \t\n\r\f] <AutoNode> { def sexp_class; BackslashOtherSexp end }
  end
  rule action
    [^\n]+ <AutoNode> { def sexp_class; ActionSexp end }
  end
  rule dot
    '.' <AutoNode> { }
  end
  rule literal_chars
    [^\\|/\[\](){} \t\n\r\f'"]+ <AutoNode> {def sexp_class; LiteralCharsSexp end }
  end
  rule range
    shorthand_range / explicit_range
  end
  rule shorthand_range
    ( '*' / '+' / '?' ) <AutoNodey> { }
  end
  rule explicit_range
    '{' [0-9]+ ( ',' [0-9]* )? '}' <CommonNode> {
      def sexp
        if elements[2].elements.nil?
          ExplicitRangeSexp.exactly(elements[1].text_value)
        elsif "," == elements[2].text_value
          ExplicitRangeSexp.unbounded(elements[1].text_value)
        else
          ExplicitRangeSexp.bounded(elements[1].text_value,
            elements[2].elements[1].text_value
          )
        end
      end
    }
  end
  rule comment
    '/*' ( [^*] / '*' !'/' )* '*/' <AutoNode> {
      def sexp_class; CommentSexp end
    }
  end
  rule spacey
    comment / [ \t\n\f\r]
  end
  rule decl_sep
    ( [ \t] / comment )* newline spacey*
  end
  # http://en.wikipedia.org/wiki/Newline (near OSX)
  rule newline
    "\n" / "\r\n"
  end
end
end
end
GRAMMAR
