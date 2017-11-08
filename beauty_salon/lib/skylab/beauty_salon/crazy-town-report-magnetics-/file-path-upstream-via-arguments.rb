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

      attr_writer(
        :batch_mode,
        :files,
        :files_file,
        :filesystem,
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
        pa = _there_can_only_be_one
        if pa
          if require_sym == pa.name_symbol
            if _curate_is_valid pa
              pa.value
            end
          else
            _error :argument_error do |y|
              y << "when you employ #{ prim because_sym }, #{
               }you must employ #{ prim require_sym }, #{
                }not #{ prim pa.name_symbol }"
            end
          end
        end
      end

      def __execute_normally
        pa = _there_can_only_be_one
        if pa
          if _curate_is_valid pa
            _m = RESOLUTION_METHOD_NAME_VIA_MODE_SYMBOL___.fetch pa.name_symbol
            send _m, pa.value
          end
        end
      end

      # -- validate value

      def _curate_is_valid pa
        k = pa.name_symbol
        m = VALIDATION_METHOD_NAME_VIA_MODE_SYMBOL__.fetch k
        if m
          send m, pa.value
        else
          ACHIEVED_
        end
      end

      VALIDATION_METHOD_NAME_VIA_MODE_SYMBOL__ = {
        files: :__validate_files,
        files_file: nil,
        corpus_step: nil,
      }

      def __validate_files files
        if files.length.zero?
          self._README__xx__  # all our UI adapations make this impossible to happen at the moment..
        else
          ACHIEVED_
        end
      end

      # -- there can only be one

      RESOLUTION_METHOD_NAME_VIA_MODE_SYMBOL___ = {
        files: :__resolve_file_path_upstream_via_files,
        files_file: :__resolve_file_path_upstream_via_files_file,
        corpus_step: :__resolve_file_path_upstream_via_corpus_step,
      }

      def _there_can_only_be_one

        batch_mode = remove_instance_variable :@batch_mode
        files_file = remove_instance_variable :@files_file
        files = remove_instance_variable :@files

        @_named_listeners = nil  # only one guy uses this

        sym_a = []

        if batch_mode
          x = batch_mode
          sym_a.push :corpus_step
        end

        if files_file
          x = files_file
          sym_a.push :files_file
        end

        if files
          x = files
          sym_a.push :files
        end

        case 1 <=> sym_a.length
        when  0 ; Common_::Pair.via_value_and_name_symbol x, sym_a.fetch( 0 )
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

        case sym
        when :files_file ; "--files-file"
        when :files ; "<files>"
        when :corpus_step ; "--corpus-step"
        else ; never end
      end

      def __resolve_file_path_upstream_via_corpus_step head_s

        sct = Home_::CrazyTownReportMagnetics_::FilePathUpstream_via_CorpusStep.call_by do |o|

          o.head_string = head_s
          o.filesystem = @filesystem
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

      def __resolve_file_path_upstream_via_files_file files_file
        if DASH_ == files_file
          _etc_via_IO $stdin  # NOTE [br] is unusable. #todo
        else
          _etc_via_IO @filesystem.open files_file  # ..
        end
      end

      def __resolve_file_path_upstream_via_files files  # #testpoint

        if files.length.zero?

          # (currently (as far as we know) our UI adaptions don't even allow
          # the expression of a zero-length list. like, the way you engage
          # the expression of a list is by expressing one or more of its
          # elements. but it's certainly not safe to assume this.)

          self._COVER_ME__readme__

        else  # elsif @do_expand_directories_into_files  <- imagine this, per #here2
          __resolve_file_path_upstream_via_files_while_expanding_directories files
        end
      end

      def __resolve_file_path_upstream_via_files_while_expanding_directories files

        # hand-written flat-map

        descended = main = p = nil
        dir = nil

        st = Stream_[ files ]

        main = -> do
          path = st.gets
          path || break
          if @filesystem.directory? path
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
    # -
  end
end
# #broke-out at #History-1
