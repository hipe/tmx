# frozen_string_literal: true

module Skylab::BeautySalon

  module Models_::CrazyTown

    def self.describe_into_under y, expag
      Describe_into_under___[ y, expag ]
    end

    # == EXPERIMENT: the remainder of this file is narrative

    Actions = Lazy_.call do

      Require_user_interface_libs_[]  # because test

      ob = ::Skylab::Zerk::ArgumentScanner::OperatorBranch_via_AutoloaderizedModule.define do |o|
        o.module = Home_::CrazyTownReports_
        o.sub_branch_const = :Actions
      end

      MTk_::ModelCentricOperatorBranch::OperatorBranch_via_Definition.define do |o|

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

    class ReportAsActionInstance___

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

      def __initialize

        idx = Home_::CrazyTownReportMagnetics_::Index_via_ReportClass.new @report_class

        @add_these_formals = idx.add_these_formals or no
        @does_need_listener = idx.does_need_listener
        @does_need_named_listeners = idx.does_need_named_listeners
        @has_file_things = idx.has_file_things

        @_user_resources = yield
        @_named_listeners = nil
        NIL
      end

      def respond_to? m  # not necessary, just safeguard
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
        _a = remove_instance_variable :@add_these_formals
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
        if @has_file_things
          if __file_things
            _money_town
          end
        else
          _money_town
        end
      end

      def _money_town

        h = remove_instance_variable :@_params
        h.delete :help  # ick/meh

        _WOW = @report_class.call_by do |o|

          h.each_pair do |k, x|
            o.send :"#{ k }=", x
          end
          if @has_file_things
            o.file_path_upstream_resources = remove_instance_variable :@__file_path_upstream_resources
          end
          if @does_need_named_listeners
            o.named_listeners = remove_instance_variable :@_named_listeners
          end
          if @does_need_listener
            o.listener = _listener
          end
        end
        _WOW  # hi. #todo
      end

      def __file_things
        if __first_file_thing
          __second_file_thing
        end
      end

      def __second_file_thing
        _ = Home_::CrazyTownReportMagnetics_::DocumentNodeStream_via_FilePathStream.call_by do |o|
          o.file_path_upstream = remove_instance_variable :@__file_path_upstream
          o.filesystem = _filesystem
          o.listener = _listener
        end
        _store :@__file_path_upstream_resources, _
      end

      def __first_file_thing
        fd = @_fetch_delete
        sct = Home_::CrazyTownReportMagnetics_::FilePathUpstream_via_Arguments.call_by do |o|
          o.batch_mode = fd[ :corpus_step ]
          o.files = fd[ :file ]
          o.files_file = fd[ :files_file ]
          o.filesystem = _filesystem
          o.listener = _listener
        end
        if sct
          @__file_path_upstream = sct.file_path_upstream
          @_named_listeners = sct.named_listeners
          ACHIEVED_
        end
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      def _filesystem
        @_user_resources.filesystem
      end

      def _listener
        @_user_resources.listener
      end
    end

    # -

    wrap_thing = nil

    Shared_properties = Lazy_.call do  # 1x

      _defn_a = [

        :required,
        :property, :code_selector,
        :description, -> y do
          y << "«description coming soon»"
        end,
        :normalize_by, -> qkn, & p do
          wrap_thing.call qkn do
            Home_::CrazyTownMagnetics_::Selector_via_String.call_by do |o|
              o.string = qkn.value
              o.listener = p
            end
          end
        end,


        :required,
        :property,
        :replacement_function,
        :description, -> y do
          y << "«description coming soon»"
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
          y << "a code file to make a diff against"
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
        ::Kernel._OKAY
      end
    end

    # ==

      Describe_into_under___ = -> y, _expag do

          _big_string =  <<-O
            this is a ROUGH prototype for a long deferred dream.
            this is the second line of description.

            #todo something is broken in [br] so the remainder of this help
            screen never appears anywhere. erase this line when this is fixed.
            #open [#023] the above - close it and cover help screen when this is covered

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
