module Skylab::BeautySalon

  class CrazyTownReportMagnetics_::FilePathUpstream_via_Arguments < Common_::MagneticBySimpleModel

    # -

      attr_writer(
        :batch_mode,
        :files,
        :files_file,
        :filesystem,
        :listener,
      )

      def execute

        batch_mode = remove_instance_variable :@batch_mode
        files_file = remove_instance_variable :@files_file
        files = remove_instance_variable :@files

        @_named_listeners = nil  # only one guy uses this

        sym_a = []

        if batch_mode
          m = :__resolve_file_path_upstream_via_corpus_step
          x = batch_mode
          sym_a.push :corpus_step
        end

        if files_file
          m = :__resolve_file_path_upstream_via_files_file
          x = files_file
          sym_a.push :files_file
        end

        if files
          files.length.zero? and self._README__xx_  # um...
          m = :__resolve_file_path_upstream_via_files
          x = files
          sym_a.push :files
        end

        case 1 <=> sym_a.length
        when  0 ; send m, x
        when -1 ; __when_too_many sym_a
        when  1 ; __when_none
        else    ; never
        end
      end

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
        _error do |y, me|
          y << "must have one of #{ Common_::Oxford_or[ me._map_etc me.__these ] }"
        end
      end

      def __when_too_many sym_a
        _error do |y, me|
          _adv = 2 == sym_a.length ? "both" : "all of"  # there's a thing for this but meh
          y << "can't have #{ _adv } #{ Common_::Oxford_and[ me._map_etc sym_a ] }"
        end
      end

      def _error
        me = self
        @listener.call :error, :expression do |y|
          yield y, me
        end
        UNABLE_
      end

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

        # hand-written map-expand

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
