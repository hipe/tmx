# frozen_string_literal: true

module Skylab::BeautySalon

  module Models_::CrazyTown

    def self.describe_into_under y, expag
      Describe_into_under___[ y, expag ]
    end

    # == EXPERIMENT: the remainder of this file is narrative

    Actions = Lazy_.call do

      Require_user_interface_libs_[]  # because test

      ob = ::Skylab::Zerk::ArgumentScanner::FeatureBranch_via_AutoloaderizedModule.define do |o|
        o.module = Home_::CrazyTownReports_
        o.sub_branch_const = :Actions
      end

      MTk_::ModelCentricFeatureBranch::FeatureBranch_via_Definition.define do |o|

        o.lookup_softly_by do |k|
          ref = ob.lookup_softly k
          if ref
            Report__.new ref
          end
        end

        o.SYMBOLISH_REFERENCE_SCANNER_BY do  # [pl]

          ob.to_symbolish_reference_scanner.map_by do |k|

            Report__.new ob.dereference k
          end
        end
      end
    end

    class Report__

      def initialize ref
        @dereference_loadable_reference = :__dereference_loadable_reference_initially
        @_ = ref
      end

      def dereference_loadable_reference
        send @dereference_loadable_reference
      end

      def __dereference_loadable_reference_initially
        @dereference_loadable_reference = :__dereference_loadable_reference_subsequently
        _real_class = @_.dereference_loadable_reference
        @__use_this_proxy = ReportAsActionClass___.new _real_class
        send @dereference_loadable_reference
      end

      def __dereference_loadable_reference_subsequently
        @__use_this_proxy
      end

      def sub_branch_const
        @_.sub_branch_const
      end

      def intern
        @_.intern
      end
    end

    class ReportAsActionClass___  # BAD / meh

      def initialize rc
        @report_class = rc
      end

      # -- mock the class

      def respond_to? m
        case m
        when :describe_into_under ; true
        when :const_get ; true  # yikes for this commit
        else no
        end
      end

      def const_get c, _=nil
        case c
        when :Modalities ; nil  # ..
        when :Actions ; nil
        else ; no
        end
      end

      # -- UI time

      def describe_into_under y, expag
        @report_class.describe_into_under y, expag
      end

      # -- construct time

      def allocate
        ReportAsActionInstance___.new @report_class
      end
    end

    class ReportAsActionInstance___  # #testpoint

      def initialize rc

        h = {}
        @_fetch_delete = -> sym do
          x = h.fetch sym
          h.delete sym
          x
        end
        @_params = h

        @_associations_ = {}  # YIKES
        @report_class = rc
      end

      def send m, & p
        case m
        when :initialize ; __initialize( & p )
        else no
        end
      end

      def __initialize  # #testpoint

        idx = Home_::CrazyTownReportMagnetics_::Index_via_ReportClass.new @report_class

        @_involves_path_upstream = idx.involves_path_upstream

        @__add_these_formals = idx.add_these_formals or no
        @__does_need_named_listeners = idx.does_need_named_listeners
        @__does_need_listener = idx.does_need_listener

        @_takes_code_selector = idx.takes_code_selector
        @_takes_replacement_function = idx.takes_replacement_function

        @_user_resources = yield
        @_named_listeners = nil
        NIL
      end

      def respond_to? m
        case m
        when :to_bound_call_of_operator ; false
        when :definition ; true
        when :_simplified_read_, :_simplified_write_
          # (while #open [#fi-015]]
          true
        when :describe_into_under ; true
        else ; no
        end
      end

      def instance_variable_defined? ivar
        case ivar
        when :@_associations_ ; true
        else ; no
        end
      end

      def describe_into_under y, expag
        @report_class.describe_into_under y, expag
      end

      def definition
        _a = remove_instance_variable :@__add_these_formals
        [
          :properties, _a,
        ]
      end

      def _argument_scanner_narrator_
        @_user_resources.argument_scanner_narrator
      end

      def _listener_
        @_user_resources.listener
      end

      def _simplified_read_ sym
        NIL
      end

      def _simplified_write_ x, sym
        # (meh)
        h = @_params
        if h.key? sym
          x0 = h.fetch sym
          ::Array.try_convert x0 or fail
          x0.concat x
        else
          h[ sym ] = x
        end
        NIL
      end

      def execute
        if @_involves_path_upstream
          if __has_fixed_string_macro
            ok = __prepare_when_fixed_string_macro
            ok &&= _resolve_file_path_upstream_resources_via_file_path_upstream
          else
            ok = __require_these_two_things_late
            ok &&= _resolve_file_path_upstream_resources
          end
          if ok
            _money_town
          end
        else
          _money_town
        end
      end

      # --

      def __prepare_when_fixed_string_macro

        Home_::CrazyTownReportMagnetics_::PrepareAction_via_MacroString.call_by do |o|

          o.takes_these(
            remove_instance_variable( :@_takes_replacement_function ),
            remove_instance_variable( :@_takes_code_selector ),
          )

          o.receive_file_path_process = method :__receive_file_path_process
          o.writable_parameters_hash = @_params
          o.macro_string = remove_instance_variable :@__macro_string
          o.file_path_upstream_via_arguments = method :_file_path_upstream_via_arguments
          o.user_resources = @_user_resources
          o.listener = _listener_
        end
      end

      def __receive_file_path_process pcs  # ..

        p = -> do
          s = pcs.gets_one_stdout_line
          if s
            s
          else
            pcs.was_OK  # hi. did
            p = nil ; NOTHING_
          end
        end

        @_file_path_upstream = Common_.stream do
          p[]
        end

        NIL
      end

      def __has_fixed_string_macro
        _store :@__macro_string, @_params.delete( :macro )
      end

      # ~

      def __require_these_two_things_late
        miss = []
        _require_this_thing miss, :@_takes_code_selector, :code_selector
        _require_this_thing miss, :@_takes_replacement_function, :replacement_function
        if miss.length.zero?
          ACHIEVED_
        else
          _listener.call :error, :expression, :argument_error do |y|
            y << "missing requiried #{ s 'parameter' } #{ _ }"
          end
          UNABLE_
        end
      end

      def _require_this_thing miss, ivar, sym
        if remove_instance_variable ivar
          if ! @_params[ sym ]
            miss << sym
          end
        end
      end

      # --

      def _money_town

        h = remove_instance_variable :@_params
        h.delete :help  # ick/meh

        @report_class.call_by do |o|

          h.each_pair do |k, x|
            o.send :"#{ k }=", x
          end

          if @_involves_path_upstream
            o.file_path_upstream_resources = remove_instance_variable :@__file_path_upstream_resources
          end

          if remove_instance_variable :@__does_need_named_listeners
            o.named_listeners = remove_instance_variable :@_named_listeners
          end

          if remove_instance_variable :@__does_need_listener
            o.listener = _listener
          end
        end
      end

      def _resolve_file_path_upstream_resources
        if __resolve_file_path_upstream
          _resolve_file_path_upstream_resources_via_file_path_upstream
        end
      end

      def _resolve_file_path_upstream_resources_via_file_path_upstream
        _ = Home_::CrazyTownReportMagnetics_::DocumentNodeStream_via_FilePathStream.call_by do |o|
          o.file_path_upstream = remove_instance_variable :@_file_path_upstream
          o.filesystem = @_user_resources.filesystem
          o.listener = _listener
        end
        _store :@__file_path_upstream_resources, _
      end

      def __resolve_file_path_upstream
        sct = _file_path_upstream_via_arguments
        if sct
          @_file_path_upstream = sct.file_path_upstream
          @_named_listeners = sct.named_listeners
          ACHIEVED_
        end
      end

      def _file_path_upstream_via_arguments
        fd = @_fetch_delete
        Home_::CrazyTownReportMagnetics_::FilePathUpstream_via_Arguments.call_by do |o|
          yield o if block_given?
          o.whole_word_filter = fd[ :whole_word_filter ]
          o.batch_mode = fd[ :corpus_step ]
          o.files = fd[ :file ]
          o.files_file = fd[ :files_file ]
          o.user_resources = @_user_resources
          o.listener = _listener
        end
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      def __appropriate_grammar_symbol_feature_branch

        # (used by one normalization here.)

        # to [#007.B] support multiple ruby language versions, this
        # would have to change from being hard-coded as it is here:

        Home_::CrazyTownMagnetics_::StructuredNode_via_Node.structured_nodes_as_feature_branch
      end

      def _listener
        @_user_resources.listener
      end
    end

    # -

    wrap_thing = nil

    Shared_properties = Lazy_.call do  # 1x

      _defn_a = [

        :property, :code_selector,
        :description, -> y do
          y << %q(example: "send( method_name == 'cha_cha' )")
        end,
        :normalize_by, -> qkn, & p do

          _fb = __appropriate_grammar_symbol_feature_branch

          wrap_thing.call qkn do
            Home_::CrazyTownMagnetics_::Selector_via_String.call_by do |o|
              o.string = qkn.value
              o.grammar_symbols_feature_branch = _fb
              o.listener = p
            end
          end
        end,


        :property,
        :replacement_function,
        :description, -> y do
          y << "for example 'file:my-func.rb'"
          y << "in this file, define Skylab::BeautySalon::CrazyTownFunctions::MyFunc"
        end,
        :normalize_by, -> qkn, & p do
          wrap_thing.call qkn do
            Home_::CrazyTownMagnetics_::ReplacementFunction_via_String.call_by do |o|
              o.string = qkn.value
              o.listener = p
            end
          end
        end,


        :property, :report,
        :description, -> y do
          y << "this is a DEBUGGING feature: debug various specific aspects"
          y << "of the behavior by running one of several \"reports\"."
          y << "see the list of reports by passing a report named \"list\"."
          y << "see help on any one report by passing \"help:fizz-buzz\"."
          y << "note that while the required arguments must be provided; for"
          y << "some reports they won't be processed."
          y << "(note that if we cared, we would break this out into more endpoints.)"
        end,


        :glob,
        :property, :file,
        :description, -> y do
          y << "a code file (or directory!) to make a diff against"
        end,


        :property, :files_file,
        :description, -> y do
          _big_string = <<-O
            instead of using `<file> [<file> [..]]` off the command line,
            each line of FILE is used exactly as if it was passed as a
            <file> argument.

            this technique cannot be used in conjunction with passing
            actual file arguments. conversely if you don't use this
            technique you must pass actual file arguments.

            this option exists both for convenience (if you have a long
            list of files in a file) and to avoid hitting shell input
            buffer limits on unimaginably huge lists of files..

            one day we will support '-' to mean STDIN, but that day is
            not today.
          O
          Stream_big_string_into_[ y, _big_string ]
        end,


        :property, :corpus_step,
        # :argument_moniker, 'CORPUS_HEAD',
        :description, -> y do
          y << 'STEP (bad name #todo) (for example "foo-nani") implies "foo-nani.d"'
          y << 'and "foo-nani.order.list" in the current directory.'
          y << 'the former is a directory of files and the latter is a'
          y << 'list of the basenames of those files in the order in which'
          y << 'to traverse the files of filenames. each such file is treated'
          y << 'as if it were passed to \'--files-file\' but additionally'
          y << 'a mechanism is engaged such that if an exception is raised'
          y << 'during traversal and parsing of the corpus, the path of the'
          y << 'file you were on is written to disk so that you will continue'
          y << 'from this point when you invoke traversal with this option'
          y << 'subsequently.'
        end,


        :property, :macro,
        :description, -> y do
          y << 'the macro EXPERIMENT - these are typically exposures of'
          y << 'replacement operations that are streamlined so that they'
          y << 'require no code to be provided by the user.'
          y << 'at writing there is only one macro - that for method names.'
        end,


        :property, :whole_word_filter,
        :description, -> y do
          y << "the tree(s) of files represented by the one or more #{ prim :file }"
          y << 'values will be narrowed down to only those files that contain'
          y << 'the argument string under a fixed-string, whole-word match'
          y << 'with `grep`.'
          y << nil
          y << 'this is a convenience optimization that allows you to run'
          y << 'your replacement function against a "large" (more than one'
          y << 'or two files) tree without requiring the system to expend'
          y << 'the considerable effort of having to parse the whole file and'
          y << 'crawl it only to find out it doesn\'t contain the target feature.'
          y << nil
          y << '  - do NOT use this unless this crude pattern would match'
          y << '    all of your target files. (at writing we\'ve only covered'
          y << '    selecting on method name, a category of selection that'
          y << '    should always avail itself to this optimization.)'
          y << nil
          y << '  - it\'s OK if this crude pattern matches a set of files'
          y << '    larger than your target set. (if your crude pattern always'
          y << '    matched the set of features exactly, then you won\'t need'
          y << '    this tool at all!)'
          y << nil
          y << "  - if you're using a #{ prim :macro } and this optimization"
          y << '    could apply, the macro should already be written employing'
          y << '    this optimization internally.'
        end,

        # REMINDER: doo-hahs you add to the above may need to be added to #spot1.1
      ]

      _scn = Scanner_[ _defn_a ]
      _st = MTk_::EntityKillerParameter.grammatical_injection.STREAM_VIA_TOKEN_SCANNER _scn
      h = {}
      _st.each do |asc|
        h[ asc.name_symbol ] = asc
      end
      h.freeze
    end

    wrap_thing = -> qkn, & p do
      if qkn.is_known_known
        x = p[]
        if x
          qkn.new_with_value x
        end
      else
        qkn  # #coverpoint4.2
      end
    end

    # ==

      Describe_into_under___ = -> y, _expag do

          _big_string =  <<-O
            this is a ROUGH prototype for a long deferred dream.
            this is the second line of description.

            #todo something is broken in [br] so the remainder of this help
            screen never appears anywhere. erase this line when this is fixed.
            #open [#050] the above - close it and cover help screen when this is covered

            (can be relative to PWD) to a ruby code file.
            (yes eventually we would want to perhaps take each filename
            as arguments, or read filenames from STDIN.)
          O

          Stream_big_string_into_[ y, _big_string ]
      end

    # ==

    Stream_big_string_into_ = -> y, big_string do
      # assume at least one line. because OCD, stream each line line by line
      # #open [#024] this will get simpler
      scn = Basic_[]::String::LineStream_via_String[ big_string ]
      line = scn.gets
      rx = /\A#{ ::Regexp.escape %r(\A[ ]+).match( line )[ 0 ] }/
      begin
        line.gsub! rx, EMPTY_S_
        y << line
        line = scn.gets
      end while line
      y
    end

    # ==

    CUSTOM_ITEMS_SECTION_LABEL_VIA_TYPE_SYMBOL = -> sym do
      if :operator == sym
        "reports"
      end
    end

    # ==

    Modalities = nil

    # ==
    # ==
  end
end
# :#History-1: break out "file path upstream via arguments"
# #born.
