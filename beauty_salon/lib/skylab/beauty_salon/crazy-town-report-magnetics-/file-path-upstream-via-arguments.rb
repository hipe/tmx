module Skylab::BeautySalon

  class CrazyTownReportMagnetics_::FilePathUpstream_via_Arguments < Common_::MagneticBySimpleModel

    # -
      # a central (locally) higher-level concern of the machinery in front
      # of reports is that of resolving the stream of paths to pass to the
      # report.
      #
      # to adapt to a variety of real-world use cases, there is a variety of
      # ways ("N") in which the stream of paths can be expressed. examples
      # (didactic, not authoritative) include: "one-by-one, where each path
      # might be a directory so flat-map those", and  "use this 'files file'
      # as a list of paths."
      #
      # each of these N ways to specify a stream of paths typically (if not
      # always) has its own parameter (presumably exposed by the UI somehow).
      # to date these parameters are not "composable"; that is, it makes no
      # sense to use them in combination with one another, but rather you
      # must specify the paths in exactly *one* of the N ways (not more, not
      # zero).
      #
      # so these formal parameters are "mutually exclusive". we furthermore
      # allow conditionally the curation of "conditional requirement" of
      # only one of the parameters (explained below). so the subject
      # effectively exposes two execution modes:
      #
      #   1. curate that exactly *one* of the N ways is engaged (mutual
      #      exclusivity plus requirement). if zero or if more than one,
      #      fail with appropriately detailed expression.
      #
      #   2. additionally there is this more nuanced mode: do (1) and also
      #      curate that the engaged mode is a particular one
      #      ("conditional requirement"). this is a bit of a regression, as
      #      if to say "even though there are these N ways, really you are
      #      only allowed to use this one way among them."  this is a bit of
      #      an ad-hoc earmark for a feature.

      def initialize
        # @do_expand_directories_into_files = true  <- imagine as option, near #here2
        @_conditional_requirement = nil
        super
      end

      def have_conditional_requirement__ because_sym, require_sym
        @_conditional_requirement = [ because_sym, require_sym ] ; nil
      end

      def files= x
        # (improve the name here. @paths makes more sense, etc.)
        @paths = x
      end

      attr_writer(
        :whole_word_filter,
        :batch_mode,
        :files_file,
        :user_resources,
        :listener,
      )

      def execute
        cr = remove_instance_variable :@_conditional_requirement
        if cr
          __execute_when_conditional_requirement( * cr )
        else
          __execute_normally
        end
      end

      def __execute_when_conditional_requirement because_sym, require_sym
        if _there_can_only_be_one
          sym = @_behavior.symbol
          if require_sym == sym
            if _curate_is_valid
              instance_variable_get @_behavior.ivar
            end
          else
            _error :argument_error do |y|
              y << "when you employ #{ prim because_sym }, #{
               }you must employ #{ prim require_sym }, #{
                }not #{ prim sym }"
            end
          end
        end
      end

      def __execute_normally
        if _there_can_only_be_one
          if _curate_is_valid
            send @_behavior.resolution_method_name
          end
        end
      end

      # -- validate value

      def _curate_is_valid
        if __curate_is_valid_generically
          __curate_is_valid_specifically
        end
      end

      def __curate_is_valid_specifically
        m = @_behavior.validation_method_name
        if m
          send m
        else
          ACHIEVED_
        end
      end

      def __validate_paths
        if @paths.length.zero?
          self._README__xx__  # all our UI adapations make this impossible to happen at the moment..
        else
          ACHIEVED_
        end
      end

      def __curate_is_valid_generically  # for now, __curate_whole_word_filter_OK
        if @whole_word_filter
          if @_behavior.whole_word_filter_is_allowed
            ACHIEVED_
          else
            __whine_about_how_whole_word_filter_is_not_allowed
          end
        else
          ACHIEVED_
        end
      end

      def __whine_about_how_whole_word_filter_is_not_allowed
        mo = @_behavior
        _error :argument_error do |y|
          y << "you cannot emply #{ prim :whole_word_filter } in #{
           }conjunction with #{ prim mo.name_symbol }."
          y << "it can only be used with one or more #{ prim :file } values."
        end
      end

      # -- there can only be one

      def _there_can_only_be_one

        sym_a = []
        last_active_mode_functions = nil

        visit = -> mf do
          ivar = mf.ivar
          if instance_variable_get ivar
            sym_a.push mf.symbol
            last_active_mode_functions = mf
          else
            remove_instance_variable ivar
          end
        end

        visit[ MODE_FUNCTIONS_FOR_CORPUS_STEP___ ]
        visit[ MODE_FUNCTIONS_FOR_FILES_FILE___ ]
        visit[ MODE_FUNCTIONS_FOR_PATHS___ ]

        @_named_listeners = nil  # only one guy uses this

        case 1 <=> sym_a.length
        when  0 ; @_behavior = last_active_mode_functions ; true
        when -1 ; __when_too_many sym_a
        when  1 ; __when_none
        else    ; never
        end
      end

      # --

      def _finish
        Result___.new(
          remove_instance_variable( :@_file_path_upstream ),
          remove_instance_variable( :@_named_listeners ),
        )
      end

      Result___ = ::Struct.new(
        :file_path_upstream,
        :named_listeners,
      )

      def __when_none
        _error :argument_error do |y, me|
          y << "must have one of #{ Common_::Oxford_or[ me._map_etc me.__these ] }"
        end
      end

      def __when_too_many sym_a
        _error :argument_error do |y, me|
          _adv = 2 == sym_a.length ? "both" : "all of"  # there's a thing for this but meh
          y << "can't have #{ _adv } #{ Common_::Oxford_and[ me._map_etc sym_a ] }"
        end
      end

      define_method :_error, DEFINITION_FOR_THE_METHOD_CALLED_EXPRESS_ERROR_

      def _map_etc sym_a
        sym_a.map( & method( :__moniker_via_sym ) )
      end

      def __these  # (duplicates ##here1)
        %i( files_file files corpus_step )
      end

      def __moniker_via_sym sym

        # (this is impure) (duplicates ##here1)
        # #todo eventually a complete [ze] should obviate this

        case sym
        when :files_file ; "--files-file"
        when :files ; "<files>"
        when :corpus_step ; "--corpus-step"
        else ; never end
      end

      def __resolve_file_path_upstream_via_corpus_step

        sct = Home_::CrazyTownReportMagnetics_::FilePathUpstream_via_CorpusStep.call_by do |o|

          o.head_string = @corpus_step
          o.filesystem = _filesystem
          o.listener = @listener
        end

        sct and __receive_these sct
      end

      def __receive_these sct

        o = NamedListeners___.new ; begin
          o.on_error_once = sct.save_corpus_step
        end

        @_named_listeners = o.freeze
        @_file_path_upstream = sct._path_stream
        _finish
      end

      NamedListeners___ = ::Struct.new(
        :on_error_once,
      )

      def __resolve_file_path_upstream_via_files_file
        files_file = remove_instance_variable :@files_file
        if DASH_ == files_file
          _etc_via_IO $stdin  # NOTE [br] is unusable. #todo
        else
          _etc_via_IO _filesystem.open files_file  # ..
        end
      end

      def __resolve_file_path_upstream_via_paths

        if @paths.length.zero?

          # (currently (as far as we know) our UI adaptions don't even allow
          # the expression of a zero-length list. like, the way you engage
          # the expression of a list is by expressing one or more of its
          # elements. but it's certainly not safe to assume this.)

          self._COVER_ME__readme__

        elsif @whole_word_filter

          __resolve_file_path_upstream_when_whole_word_filter

        else  # elsif @do_expand_directories_into_files  <- imagine this, per #here2
          __resolve_file_path_upstream_via_paths_while_expanding_directories
        end
      end

      def __resolve_file_path_upstream_when_whole_word_filter

        pcs = Home_::CrazyTownReportMagnetics_::FilePathUpstream_via_WholeWord.call_by do |o|

          o.have_dirs remove_instance_variable :@paths

          o.set_whole_word_match_fixed_string remove_instance_variable :@whole_word_filter

          o.employ_common_defaults_ @user_resources

          o.listener = @listener
        end

        if pcs
          @_file_path_upstream = Common_.stream do
            pcs.gets_one_stdout_line
          end
          _finish
        end
      end

      def __resolve_file_path_upstream_via_paths_while_expanding_directories

        # hand-written flat-map

        descended = main = p = nil
        dir = nil

        st = Stream_[ remove_instance_variable :@paths ]

        main = -> do
          path = st.gets
          path || break
          if _filesystem.directory? path
            dir = path
            p = descended
            p[]
          else
            path
          end
        end

        _PATTERN = "*#{ Autoloader_::EXTNAME }"
        _TYPE_FILE = %w(-type f)

        descended = -> do
          _use_dir = dir ; dir = nil
          use_st = Home_.lib_.system_lib::Find.with(
            :path, _use_dir,
            :filename, _PATTERN,
            :freeform_query_infix_words, _TYPE_FILE,
            & @listener
          ).to_path_stream
          p = -> do
            path = use_st.gets
            if path
              path
            else
              p = main
              p[]
            end
          end
          p[]
        end

        p = main
        @_file_path_upstream = Common_.stream do
          p[]
        end
        _finish
      end

      def _etc_via_IO io
        # wrap the IO so it has all the other stream stuff
        @_file_path_upstream = Common_.stream do
          line = io.gets
          if line  # not covered, a line as-is is not a path
            line.chomp!
            line
          end
        end
        _finish
      end

      def _filesystem
        @user_resources.filesystem
      end
    # -

    # ==

    module MODE_FUNCTIONS_FOR_CORPUS_STEP___ ; class << self

      def whole_word_filter_is_allowed ; false end

      def resolution_method_name
        :__resolve_file_path_upstream_via_corpus_step
      end

      def validation_method_name
        NOTHING_
      end

      def ivar
        :@batch_mode  # NOTE not @corpus_step
      end

      def symbol
        :corpus_step
      end
    end ; end

    module MODE_FUNCTIONS_FOR_FILES_FILE___ ; class << self

      def whole_word_filter_is_allowed ; false end

      def resolution_method_name
        :__resolve_file_path_upstream_via_files_file
      end

      def validation_method_name
        NOTHING_
      end

      def ivar
        :@files_file
      end

      def symbol
        :files_file
      end
    end ; end

    module MODE_FUNCTIONS_FOR_PATHS___ ; class << self

      def whole_word_filter_is_allowed ; true end

      def resolution_method_name
        :__resolve_file_path_upstream_via_paths
      end

      def validation_method_name
        :__validate_paths
      end

      def ivar
        :@paths
      end

      def symbol
        :files  # NOTE - we use the UI name (files not paths)
      end
    end ; end

    # ==
    # ==
  end
end
# #broke-out at #History-1
