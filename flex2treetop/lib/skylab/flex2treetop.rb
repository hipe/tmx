require 'skylab/brazen'

module Skylab::Flex2Treetop  # see [#008] the narrative

  def self.describe_into_under y, _
    y << "attempts to convert a FLEX grammar into a treetop grammar"
  end

  Common_ = ::Skylab::Common

  Autoloader_ = Common_::Autoloader

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  lazily :CLI do
    ::Class.new Brazen_::CLI
  end

  def self.translate * x_a, & x_p

    x_a.unshift :translate

    _k = application_kernel_
    bc = _k.bound_call_via_mutable_iambic x_a, & x_p
    if bc
      bc.receiver.send bc.method_name, * bc.args, & bc.block
    else
      bc
    end
  end

  module API

    class << self

      def call * x_a, & p
        bc = Home_.application_kernel_.bound_call_via_mutable_iambic x_a, & p
        bc and bc.receiver.send bc.method_name, * bc.args
      end

      def expression_agent_instance  # for direct calls to API
        Brazen_::API.expression_agent_instance
      end
    end  # >>
  end

  class << self

    def action_base_class  # #hook-out for [br] for using procs as actions (if ever)
      Action__
    end

    define_method :application_kernel_, ( Common_.memoize do
      Brazen_::Kernel.new Home_
    end )

    def lib_
      @lib ||= Common_.produce_library_shell_via_library_and_app_modules Lib_, self
    end

    def sidesystem_path_
      @___ssp ||= ::File.expand_path '../../..', dir_path
    end
  end  # >>

  Brazen_ = ::Skylab::Brazen

  class Action__ < Brazen_::ActionToolkit

    Brazen_::Modelesque.entity self

  end

  module Models_

    module Application

      Actions = ::Module.new

      class Actions::Ping < Action__

        @is_promoted = true

        edit_entity_class :property, :arg_1

        def produce_result

          arg_1 = @argument_box[ :arg_1 ]

          maybe_send_event :info, :expression, :ping do | y |

            if arg_1
              y << "helo:(#{ arg_1 })"
            else
              y << "hello from #{ app_name_string }."
            end
            :_xyzzy_
          end

          if arg_1
            :_cheeky_monkey_
          else
            :hello_from_flex2treetop
          end
        end
      end

      class Actions::Version < Action__

        @is_promoted = true

        edit_entity_class(

          :branch_description, -> y do
            y << "output the #{ app_name_string } version"
          end,

          :flag, :property, :bare,
        )

        def produce_result

          if @argument_box[ :bare ]
            "#{ VERSION }"
          else
            "#{ @kernel.app_name_string }: #{ VERSION }"
          end
        end
      end
    end

    class Test  # :+#frontier a parent-less model class

      Actions = ::Module.new

      Actions::List = -> act_pxy do

        _path = ::File.join Home_.sidesystem_path_, 'test/fixture-files'

        path_a = ::Dir.glob( "#{ _path }/*.flex", ::File::FNM_PATHNAME )

        path_a = Home_.lib_.system.maybe_sort_filesystem_paths path_a
        # (necessary for Ubuntu #history-B.1)

        path = '[ other gems ]'

        ADDITIONAL_RECOMMENDED_VISUAL_TEST_FILES___.each do | universe_file |
          path_a.push ::File.join( path, universe_file )
        end

        test = Test_.new nil

        Common_::Stream.via_nonsparse_array( path_a ).map_by do |path_|  # Stream_

          test.new path_
        end
      end

      def initialize path
        @path = path
      end

      def new x
        dup.__init x
      end

      def __init x
        @path = x ; self
      end

      def express_into_under y, expag
        y << @path
      end

      def basename_string
        ::File.basename @path
      end

      Test_ = self
    end

    module Translation

      Modalities = ::Module.new
      module Modalities::CLI
        Actions = ::Module.new
        class Actions::Translate < Brazen_::CLI::Action_Adapter

          def init_properties  # :+[#br-042] will change

            bp = @bound.formal_properties
            fp = bp.to_mutable_box_like_proxy

            fp.remove :resources

            @back_properties = bp
            @front_properties = fp

            NIL_
          end

          def prepare_backstream_call x_a

            x_a.push :resources, @resources

            ACHIEVED_
          end
        end
      end

      Actions = ::Module.new

      class Actions::Translate < Action__

        @is_promoted = true

        edit_entity_class(

          :flag, :property, :case_sensitive,

          :description, -> y do
            y << "show sexp of parsed flex file."
            y << "circumvent normal output. (devel)"
          end,
          :flag, :property, :show_sexp_only,


          :description, -> y do
            y << "nest treetop output in this grammar declaration"
            y << "(e.g. \"Mod1::Mod2::Grammar\")."
          end,
          :property, :wrap_in_grammar,


          :description, -> y do
            y << '[write, ]read flex treetop grammar'
            y << '[from ,] to the filesystem as opposed to in memory. (devel)'
          end,
          :flag, :property, :use_FS_parser,


          :description, -> y do
             y << 'force a rewrite of the parser file (when FS)'
           end,
          :flag, :property, :clear_generated_files,


          :description, -> y do
            y << "will use this dir else system tmpdir (when FS)"
          end,
          :property, :FS_parser_dir,


          :description, -> y do
            y << "do nothing else after writing the syntax (when FS)"
          end,
          :flag, :property, :endpoint_is_FS_parser,


          :description, -> y do
            y << "necessary for overwriting some files"
          end,
          :flag, :property, :force,


          :flag, :property, :verbose,


          :required, :property, :resources,

          :required, :property, :flex_file,

          :required, :property, :output_path
        )

        def produce_result

          ok = __resolve_resources
          ok &&= __resolve_upstream
          ok &&= __resolve_downstream
          ok && __result_via_upstream_and_downstream
        end

        def __resolve_resources

          @resources = @argument_box.fetch :resources
          @resources && ACHIEVED_
        end

        def __resolve_upstream

          qualified_knownness_of_path = qualified_knownness :flex_file
          path = qualified_knownness_of_path.value

          if DASH_ == path
            qualified_knownness_of_path = qualified_knownness_of_path.to_unknown
          end

          kn = LIB_.system_lib::Filesystem::Normalizations::Upstream_IO.via(
            :qualified_knownness_of_path, qualified_knownness_of_path,
            :stdin, @resources.sin,
            :filesystem, LIB_.system.filesystem,
            & handle_event_selectively )

          if kn
            @upstream_ID = Home_.lib_.basic::Pathname::ByteStreamReference.new kn.value, path
            ACHIEVED_
          else
            kn
          end
        end

        def __resolve_downstream

          h = @argument_box.h_
          if h[ :show_sexp_only ] || h[ :endpoint_is_FS_parser ]

            @downstream_ID = :__DOWNSTREAM_NOT_USED__
            @verb_s = 'skipping'
            ACHIEVED_
          else
            __resolve_normal_downstream
          end
        end

        def __resolve_normal_downstream

          qualified_knownness_of_path = qualified_knownness :output_path
          path = qualified_knownness_of_path.value

          if DASH_ == path
            qualified_knownness_of_path = qualified_knownness_of_path.to_unknown
          end

          kn = LIB_.system_lib::Filesystem::Normalizations::Downstream_IO.via(

            :qualified_knownness_of_path, qualified_knownness_of_path,
            :stdout, @resources.sout,
            :force_arg, qualified_knownness( :force ),
            :filesystem, LIB_.system.filesystem,

          ) do | * i_a, & ev_p |

            if :info == i_a.first
              @verb_s = send :"__verb_given__#{ i_a.last }__"
            end

            handle_event_selectively[ * i_a, & ev_p ]
          end

          if kn
            @verb_s ||= 'output'
            @downstream_ID = Home_.lib_.basic::Pathname::ByteStreamReference.new kn.value, path
            ACHIEVED_
          else
            kn
          end
        end

        def __verb_given__before_probably_creating_new_file__
          CREATE___
        end
        def __verb_given__before_editing_existing_file__
          OVERWRITE__
        end
        CREATE___ = 'create'.freeze
        OVERWRITE__ = 'overwrite'.freeze

        def __result_via_upstream_and_downstream

          h = @argument_box.h_

          Translate___.call(
              :be_verbose, ( h[ :verbose ] || false ),
              :do_clear_files, h[ :clear_generated_files ],
              :do_show_sexp_only, h[ :show_sexp_only ],
              :do_use_FS_parser, h[ :use_FS_parser ],
              :endpoint_is_FS_parser, h[ :endpoint_is_FS_parser ],
              :FS_parser_dir, h[ :FS_parser_dir ],
              :downstream_ID, @downstream_ID,
              :filesystem, ::File,  # the real one is used, no mocking yet
              :resources, @resources,
              :upstream_ID, @upstream_ID,
              :verb_s, @verb_s,
              :wrap_in_grammar_s, h[ :wrap_in_grammar ],
              & handle_event_selectively )

        end
      end
    end
  end

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc
    vendor = Autoloader_.build_require_stdlib_proc

    # = sidesys[ :Brazen ]  # for [sl]

    IO = -> do
      System[]::IO
    end

    PP = -> do
      require 'pp' ; ::PP
    end

    Stdlib_tmpdir = Common_.memoize do
      require 'tmpdir'
      ::Dir
    end

    Strange = -> x do
      Basic[]::String.via_mixed x
    end

    String_lib = -> do
      Basic[]::String
    end

    System = -> do
      System_lib[].services
    end

    Basic = sidesys[ :Basic ]
    Fields = sidesys[ :Fields ]
    Option_parser = -> { require 'optparse' ; ::OptionParser }
    String_scanner = -> { require 'strscan' ; ::StringScanner }
    System_lib = sidesys[ :System ]
    Treetop = vendor[ :Treetop ]
  end

  LIB_ = lib_

  Home_ = self

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  Deferred_actor__ = -> p do  # why deferred? [#here.B]

    cls_p = Common_::Memoize[ & p ]

    -> * x_a, & em_p do

      _cls = cls_p.call

      sess = _cls.via_iambic x_a, & em_p

      if sess
        sess.procede_until_endpoint_
      else
        self._K
      end
    end
  end

Translate___ = Deferred_actor__[ -> do class Translate____

    Attributes_actor_.call( self,
      be_verbose: nil,
      do_clear_files: :optional,
      do_show_sexp_only: :optional,
      do_use_FS_parser: :optional,
      downstream_ID: nil,
      endpoint_is_FS_parser: :optional,
      filesystem: nil,
      FS_parser_dir: :optional,
      resources: nil,
      upstream_ID: nil,
      verb_s: nil,
      wrap_in_grammar_s: :optional,
    )

    def initialize & p
      @listener = p
    end

    def procede_until_endpoint_

      if @be_verbose && __is_conventional_endpoint
        __express_doing
      end

      if @do_use_FS_parser
        x = __use_FS_parser
      end

      x || __translate_stream
    end

    def __is_conventional_endpoint
      ! ( @do_show_sexp_only || @endpoint_is_FS_parser )
    end

    def __express_doing

      dn_ID = @downstream_ID ; up_ID = @upstream_ID ; verb_s = @verb_s

      @listener.call :info, :express, :doing do | y |

        _dn_s = dn_ID.description_under self
        _up_s = up_ID.description_under self

        y << "#{ verb_s } #{ _dn_s } against #{ _up_s }"
      end
      NIL_
    end

    def __translate_stream

      _load_grammar_subclasses_if_necessary

      _byte_downstream = if @do_show_sexp_only
        :__BYTE_DOWNSTREAM_NOT_USED__
      else
        @downstream_ID.to_minimal_yielder_for_receiving_lines
      end

      Translate_stream___.call(
        :byte_upstream, @upstream_ID.to_minimal_line_stream,
        :byte_downstream, _byte_downstream,
        :do_show_sexp_only, @do_show_sexp_only,
        :resources, @resources,
        :wrap_in_grammar_s, @wrap_in_grammar_s,
        & @listener )
    end

    # ~ we comport with [#bs-031] control-flow method-naming idioms

    def __use_FS_parser

      @FS_parser_dir ||= LIB_.stdlib_tmpdir_path

      x = __resolve_parser_dir_stat
      x ||= __via_parser_dir_stat
      x || __resolve_and_use_generated_files
    end

    def __resolve_parser_dir_stat

      @stat = @filesystem.stat @FS_parser_dir
      NIL_

    rescue ::Errno::ENOENT => e

      __when_enoent e
    end

    def __when_enoent e

      @listener.call :error, :expression, :enoent do | y |
        y << e.message
      end

      :parser_dir_not_exist
    end

    def __via_parser_dir_stat

      if DIR_FTYPE___ != @stat.ftype

        __when_parser_dir_is_not_dir
      end
    end

    def __when_parser_dir_is_not_dir

      path = @FS_parser_dir ; stat = @stat

      @listener.call :error, :expression, :not_dir do | y |
        y << "parser dir was #{ stat.ftype } - #{ pth path }"
      end

      :parser_dir_is_not_dir
    end

    DIR_FTYPE___ = LIB_.system_lib::Filesystem::DIRECTORY_FTYPE

    def __resolve_and_use_generated_files

      @grammar_path = ::File.join @FS_parser_dir, 'flex-to-treetop.treetop'
      @compiled_grammar_path = ::File.join @FS_parser_dir, 'flex-to-treetop.rb'

      if @do_clear_files
        __clear_generated_files
      end

      _x = __resolve_compiled_grammar_file
      _x || __attempt_to_use_generated_files
    end

    def __clear_generated_files

      fu = __build_file_utils
      [ @grammar_path, @compiled_grammar_path ].each do | path |

        @filesystem.exist?( path ) or next
        fu.rm path
      end

      NIL_
    end

    def __build_file_utils

      LIB_.system.filesystem.file_utils_controller.new_via do | msg |
        receive_info_line_ "(futils:) #{ msg }" ; nil
      end
    end

    def __resolve_compiled_grammar_file

      if @filesystem.exist? @compiled_grammar_path

        path = @compiled_grammar_path

        @listener.call :info, :expression, :using do | y |
          y << "using: #{ path }"
        end

        NIL_
      else

        __recompile
      end
    end

    def __recompile

      _x = __resolve_grammar_file
      _x or __finish_recompile
    end

    def __resolve_grammar_file

      if not @filesystem.exist? @grammar_path

        __write_grammar_file
      end
    end

    def __write_grammar_file

      bytes = @filesystem.open @grammar_path, WRITE_MODE_ do | fh |

        fh.write TREETOP_GRAMMAR__
      end

      path = @grammar_path

      @listener.call :info, :expression, :wrote_grammar do | y |
        y << "wrote #{ path } (#{ bytes } bytes)."
      end

      NIL_
    end

    def __finish_recompile

      path = @compiled_grammar_path

      @listener.call :info, :expression, :writing_compiled do | y |
        y << "writing #{ path } .."
      end

      bytes = LIB_.treetop::Compiler::GrammarCompiler.
        new.compile @grammar_path, @compiled_grammar_path

      @listener.call :info, :expression, :wrote_compiled do | y |
        y << " done (treetop wrote #{ bytes } bytes)."
      end

      NIL_
    end

    def __attempt_to_use_generated_files

      _load_grammar_subclasses_if_necessary

      if defined? FlexFileParser

        __when_flexfile_parser_already_loaded
      else

        __load_and_use_generated_files
      end
    end

    def __when_flexfile_parser_already_loaded

      @listener.call :error, :expression, :ff_parser_already do | y |
        y << "cannot use FS parser, a parser class is already loaded #{
          }(maybe because you are running all the tests at once?)"
      end

      :cannot_use_FS_flex_file_parser_already_loaded
    end

    def __load_and_use_generated_files

      require __get_normalized_requireable_compiled_grammar_path

      if @endpoint_is_FS_parser
        __when_reached_FS_parser
      end
    end

    def _load_grammar_subclasses_if_necessary

      Common_node___[]
      NIL_
    end

    def __get_normalized_requireable_compiled_grammar_path

      path = @compiled_grammar_path

      if ::File::SEPARATOR != path[ 0 ]
        path = @filesystem.expand_path path
      end

      s = ::File.extname path
      if s.length.nonzero?
        path = path[ 0 ... - s.length ]
      end

      path
    end

    def __when_reached_FS_parser

      @listener.call :info, :expression, :touched do | y |
        y << "touched files. nothing more to do."
      end

      :filesystem_touched
    end

    self
  end end ]

  Translate_stream___ = Deferred_actor__[ -> do

  class Translate_Stream____

    Attributes_actor_.call( self,
      byte_downstream: nil,
      byte_upstream: nil,
      do_show_sexp_only: :optional,
      wrap_in_grammar_s: :optional,
      resources: nil,
    )

    def initialize & p
      @listener = p
    end

    def procede_until_endpoint_

      x = __procede_to_endpoint

    ensure

      if ! @do_show_sexp_only
        @byte_downstream.close
      end

      x
    end

    def __procede_to_endpoint

      @parser = __parser_class.new

      @whole_file = @byte_upstream.read
      @byte_upstream.close

      @parser_result_x = @parser.parse @whole_file

      if @parser_result_x

        __via_parser_result
      else

        __when_NO_parser_result
      end
    end

    def __parser_class

      if Home_.const_defined? :Parser___
        Home_::Parser___
      else
        __build_and_set_parser_class
      end
    end

    def __build_and_set_parser_class

      if ! defined? FlexFileParser

        # if the parser class is defined at this point then it must be because
        # the parser was already loaded from a file (the debugging feature).

        __load_treetop_grammar
      end

      cls = Home_.const_set :Parser___, ::Class.new( FlexFileParser )
      cls.class_exec( & Enhance_parser_class__ )
      cls
    end

    def __load_treetop_grammar

      LIB_.treetop.load_from_string TREETOP_GRAMMAR__
    end

    def __when_NO_parser_result

      s = parser.failure_reason  # (not our name)

      @listener.call :error, :expression, :no_parser_result do | y |
        y << ( s || "Got nil from parse without reason" )
      end

      :parse_failure
    end

    def __via_parser_result

      if @do_show_sexp_only

        __show_sexp
      else

        __translate
      end
    end

    def __show_sexp

      LIB_.PP.pp @parser_result_x.sexp, @resources.serr

      :showed_sexp
    end

    def __translate

      @byte_downstream.puts __autogenerated_line

      sess = __start_translation_session

      x = @parser_result_x.sexp._translate_into sess
      if x
        x
      else
        :translate_failure
      end
    end

    def __autogenerated_line

      _rx = LIB_.basic::String.mustache_regexp

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

    def __start_translation_session

      sess = Translation_Session___.new

      sess.listener =  @listener

      sess.wrap_in_grammar_s = @wrap_in_grammar_s

      sess.builder = Sessions__::Treetop_builder[].new @byte_downstream

      sess.grammar_s = TREETOP_GRAMMAR__

      sess
    end

    class Translation_Session___

      # this is the "client" that myriad syntactic structures translate into

      attr_reader(
        :is_case_sensitive,
      )

      attr_accessor(
        :builder,
        :grammar_s,
        :listener,
        :wrap_in_grammar_s,
      )

      def initialize
        @_current_rule_name = nil
        @_rule_separator = -> do

          @_rule_separator = -> do
            @builder.newline
            NIL_
          end
          NIL_
        end
      end

      def receive_case_insensitive
        @is_case_sensitive = true
        NIL_
      end

      def __add_rule_for_flushing
        rule = Models__Rule.new
        yield rule
        if @_current_rule_name
          if @_current_rule_name == rule.rule_name
            if @_current_rule.is_atom
              @_current_rule = @_current_rule.to_list_alongside rule
            else
              @_current_rule.add rule
            end
          else

            @_rule_separator[]
            @_current_rule.write_rule_into self
            @_current_rule = rule
            @_current_rule_name = rule.rule_name
          end
        else
          @_current_rule = rule
          @_current_rule_name = rule.rule_name
        end
        NIL_
      end

      def __write_rule_now
        rule = Models__Rule.new
        yield rule
        @_rule_separator[]
        rule.write_rule_into self
      end

      def __receive_finish_rules

        if @_current_rule
          @_rule_separator[]
          @_current_rule.write_rule_into self  # result is IO
        end

        :translated
      end


      define_method :suffixate, -> do  # read [#here.A]

        suffix = "__of_lexer__"

        -> s do
          "#{ s }#{ suffix }"
        end
      end.call

      def maybe_receive_event * i_a, & x_p

        @listener.call( * i_a, & x_p )
        NIL_
      end
    end

    class Models__Rule

      attr_accessor(
        :rule_name,
        :pattern_like,
      )

      def initialize
      end

      def write_rule_into ctx

        o = ctx.builder

        o.rule_declaration @rule_name do
          o.write SPACE_ * o.level
          @pattern_like._translate_into ctx
          o.newline
        end
      end

      def is_atom
        true
      end

      def to_list_alongside rule
        Models__Rule_Alternation.new rule, self
      end
    end

    class Models__Rule_Alternation

      def initialize two, one
        @_a = [ one, two ]
      end

      def add x
        @_a.push x
        NIL_
      end

      def write_rule_into ctx

        o = ctx.builder

        o.rule_declaration @_a.first.rule_name do

          o.write SPACE_ * o.level

          @_a.first.pattern_like._translate_into ctx

          @_a[ 1 .. -1 ].each do | rule |

            o.write ALTERNATION_ITEM_SEPARATOR___
            rule.pattern_like._translate_into ctx
          end

          o.newline
        end
      end

      def is_atom
        false
      end

      ALTERNATION_ITEM_SEPARATOR___ = ' / '
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
    end  # >>

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
      s = LIB_.string_scanner.new(str)
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
        Home_::AutoSexp.traditional(guess_node_name, *cx)
      else
        Home_::AutoSexp.traditional(guess_node_name, text_value)
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

  Common_node___ = Common_.memoize do

    # all of the below "public"-looking constants must be
    # visible to the grammar when it loads

    class CommonNode < LIB_.treetop::Runtime::SyntaxNode
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

  class FileSexp < Sexpesque  # :file

    def _translate_into client
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

      if /\A#{ const_rxs }(?:::#{ const_rxs })*\z/ =~ @grammar_s

        ACHIEVED_
      else

        g_s = @grammar_s

        @client.maybe_receive_event :error, :expression, :invalid_NS do | y |

          y << "grammar namespaces look like \"Foo::BarBaz\". #{
            }this is not a valid grammar namespace: #{ g_s.inspect }"
        end

        UNABLE_
      end
    end

    def translate_when_valid

      @_nest_p_a = [ -> do

        a = children[ :definitions ]
        if a.length.nonzero?
          @def_a = a
          do_defs
        end

        a = children[ :rules ]
        if a.length.nonzero?
          @rule_a = a
          do_rules
        end

        __finish_rules
      end ]

      @grammar_s and add_grammar_frame

      @_nest_p_a.pop.call
    end

    def do_defs

      @builder.newline
      @builder << "# from flex name definitions"
      @builder.newline

      @def_a.each do | o |
        o._translate_into @client
      end
      NIL_
    end

    def do_rules

      @builder.newline

      @builder << "# flex rules"

      @rule_a.each do |x|
        x._translate_into @client
      end
      NIL_
    end

    def add_grammar_frame

      part_a = @grammar_s.split '::'

      gname = part_a.pop

      @_nest_p_a.push -> do
        _p = @_nest_p_a.pop
        @builder.grammar_declaration gname, & _p
      end

      begin

        const_s = part_a.pop
        const_s or break
        @_nest_p_a.push -> do
          cnst_s = const_s
          -> do
            _p = @_nest_p_a.pop
            _x = @builder.module_declaration cnst_s, & _p
            if Progressive_Output_Adapter__ == _x.class
              :translated
            else
              :abnormal_vendor_response
            end
          end
        end.call
        redo
      end while nil
    end

    def __finish_rules
      @client.__receive_finish_rules
    end
  end

  class StartDeclarationSexp < Sexpesque # :start_declaration

    def _translate_into sess

      x = children[ :declaration_value ]

      case x

      when 'case-insensitive'
        sess.receive_case_insensitive

      else
        sess.builder << "# declaration ignored: #{ x.inspect }"
      end

      NIL_
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

    def _translate_into client
      client.builder.write " #{ @parts.join '' }"
    end
  end

  class NameDefinitionSexp < Sexpesque # :name_definition

    def _translate_into ctx

      ctx.__write_rule_now do | o |

        o.rule_name = ctx.suffixate children[ :name_definition_name ]

        o.pattern_like = children[ :name_definition_definition ]
      end
    end
  end

  class RuleSexp < Sexpesque # :rule

    def _translate_into client

      action_string = children[:action].my_text_value

      if SURROUNDED_BY_CURLIES___ =~ action_string
        action_string = $~[ :content ]
      end

      if RETURN_STATEMENT___ =~ action_string
        from_constant client, $~[ :rest ]

      elsif C_STYLE_COMMENT___ =~ action_string
        from_constant client, $~[ :content ].gsub( SPACE_, UNDERSCORE_ )

      else

        client.maybe_receive_event :info, :expression, :cant_deduce_rule do |y|
          y << "notice: Won't deduce a treetop rule name from: #{
            }#{ action_string.inspect } Skipping."
        end

        NIL_
      end
    end

    RETURN_STATEMENT___ = /\Areturn [[:space:]]+ (?<rest> [a-zA-Z_]+) ; \Z/x

    SURROUNDED_BY_CURLIES___ =
      /\A \{ [[:space:]]* (?<content> .* [^[:space:]] ) [[:space:]] * \} \Z/x

    C_STYLE_COMMENT___ = %r{\A
      /\*
      [[:space:]]*
      (?<content> [a-zA-Z][a-zA-Z0-9]* (?: [[:space:]]+ [a-zA-Z0-9]+ )* )
      [[:space:]]*
      \*/
    \Z}x

    def from_constant ctx, const

      ctx.__add_rule_for_flushing do | o |

        o.rule_name = const  # no suffixating here

        o.pattern_like = children[ :pattern ]
      end
    end
  end

  class PatternChoiceSexp < Sexpesque # :pattern_choice

    def _translate_into client
      (1..(last = size-1)).each do |idx|
        self[idx]._translate_into client
        client.builder.write(' / ') if idx != last
      end
    end
  end

  class PatternSequenceSexp < Sexpesque # :pattern_sequence

    def _translate_into client
      (1..(last = size-1)).each do |idx|
        self[idx]._translate_into client
        if last != idx
          client.builder.write SPACE_
        end
      end
    end
  end

  class PatternPartSexp < Sexpesque # :pattern_part

    def _translate_into client
      self[1]._translate_into client
      self[2] and self[2][:range]._translate_into client
    end
  end

  class UseDefinitionSexp < Sexpesque # :use_definition

    def _translate_into client
      client.builder.write client.suffixate self[ 1 ]
    end
  end

  class LiteralCharsSexp < Sexpesque # :literal_chars

    terminal!

    def _translate_into client
      client.builder.write self[1].inspect # careful! put lit chars in dbl "'s
    end
  end

  class CharClassSexp < Sexpesque # :char_class

    terminal! # no guarantee this will stay this way!

    def _translate_into client
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
    def _translate_into client
      client.builder.write "OHAI_HEX_SEXP"
    end
  end

  class OctalSexp < Sexpesque # :octal
    terminal!
    def _translate_into client
      client.builder.write "OHAI_OCTAL_SEXP"
    end
  end

  class AsciiNullSexp < Sexpesque # :ascii_null
    terminal!
    def _translate_into client
      client.builder.write "OHAI_NULL_SEXP"
    end
  end

  class BackslashOtherSexp < Sexpesque # :backslash_other
    terminal!
    def _translate_into client
      # byte per byte output the thing exactly as it is, but wrapped in quotes
      client.builder.write "\"#{my_text_value}\""
    end
  end

  class ActionSexp < Sexpesque # :action
    terminal! # these are hacked, not used conventionally
  end

  class AutoSexp < Sexpesque
    def _translate_into client
      self[1..size-1].each do |c|
        if c.respond_to? :_translate_into
          c._translate_into client
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

  Sessions__ = ::Module.new

  Sessions__::Treetop_builder = Common_.memoize do

  class Treetop_Builder____ < LIB_.treetop::Compiler::RubyBuilder

    def initialize byte_downstream
      super() # nathan sobo reasonably sets @ruby to a ::String here
      @ruby = Progressive_Output_Adapter__.new byte_downstream
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

  Enhance_parser_class__ = -> do  # (if you edit this heavily, move it up)
    # CompiledParser#failure_reason overridden for less context

    def failure_reason  # (not our name)

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

  # ~ constants

  ADDITIONAL_RECOMMENDED_VISUAL_TEST_FILES___ = %w(
    css-convert/css/parser/tokens.flex
  )

  AUTOGENERATED_RX = /autogenerated by flex2treetop/i  # (was [#008])
  ACHIEVED_ = true
  DASH_ = '-'
  KEEP_PARSING_ = true
  NIL_ = nil
  READ_MODE_ = ::File::RDONLY | ::File::CREAT
  SPACE_ = ' '.freeze
  UNABLE_ = false
  UNDERSCORE_ = '_'
  VERSION = '0.0.3'
  WRITE_MODE_ = ::File::WRONLY | ::File::CREAT

  TREETOP_GRAMMAR__ = <<'GRAMMAR'
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
end
# #history-B.1: Target Ubuntu not OS X
# :+#tombstone: #!storypoint-210 explained how methodic actor may have been born here
