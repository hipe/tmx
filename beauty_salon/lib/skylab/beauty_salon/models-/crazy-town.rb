module Skylab::BeautySalon

  # NOTE - this file is just GLUE for the legacy [br] app code to
  # our modern techniques..

  Require_brazen_LEGACY_[]

  class Models_::CrazyTown < Brazen_::Action

    # -

      Brazen_::Modelesque.entity self

      edit_entity_class(

        :description, -> y do
          y << "«description coming soon»"
        end,
        :required, :property, :code_selector,


        :description, -> y do
          y << "«description coming soon»"
        end,
        :required, :property, :replacement_function,


        :parameter_arity, :zero_or_one,
        :description, -> y do
          y << "this is a DEBUGGING feature: debug various specific aspects"
          y << "of the behavior by running one of several \"reports\"."
          y << "see the list of reports by passing a report named \"list\"."
          y << "see help on any one report by passing \"help:fizz-buzz\"."
          y << "note that while the required arguments must be provided; for"
          y << "some reports they won't be processed."
          y << "(note that if we cared, we would break this out into more endpoints.)"
        end,
        :property, :report,


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
        :property, :files_file,


        :parameter_arity, :zero_or_more,
        :description, -> y do
          y << "a code file to make a diff against"
        end,
        :property, :file,


        :argument_arity, :zero,
        :parameter_arity, :zero_or_one,
        :description, -> y do
          y << 'this is a thing ding for mc wing ding'
        end,
        :property, :corpus_step,


        :branch_description, -> y do

          _big_string =  <<-O
            this is a ROUGH prototype for a long deferred dream.
            <files-file> is a file each of whose line is a path

            #todo something is broken in [br] so the remainder of this help
            screen never appears anywhere. erase this line when this is fixed.

            (can be relative to PWD) to a ruby code file.
            (yes eventually we would want to perhaps take each filename
            as arguments, or read filenames from STDIN.)

            <code-selector> is a TODO

            <replacement-function> is TODO

            currently the only output (to STDOUT) is a patchfile! woo??
          O

          Stream_big_string_into_[ y, _big_string ]
          NIL
        end,
      )

      def produce_result

        if __resolve_arguments
          __money_town
        end
      end

      def __money_town

        _hi = Home_::CrazyTownMagnetics_::Result_via_ReportName_and_Arguments.call_by do |o|

          o.report_name = remove_instance_variable :@report

          o.file_path_upstream = remove_instance_variable :@_file_path_upstream

          o.code_selector_string = remove_instance_variable :@code_selector

          o.replacement_function_string = remove_instance_variable :@replacement_function

          o.on_error_once = @_on_error_once

          o.filesystem = @_filesystem

          o.listener = @listener
        end

        _hi
      end

      def __resolve_arguments

        # NOTE - we anticipate switching over to modern techniques soon
        # but for now BE CAREFUL - WE COULD CLOBBER IVARS

        h = remove_instance_variable( :@argument_box ).h_

        @code_selector = h.fetch :code_selector

        @replacement_function = h.fetch :replacement_function

        @report = h[ :report ]

        @_filesystem = ::File

        @listener = remove_instance_variable :@on_event_selectively  # modern way now

        __resolve_file_path_upstream h[ :corpus_step ], h[ :files_file ], h[ :file ]  # duplicated :#here1
      end

      def __resolve_file_path_upstream batch_mode, files_file, files

        @_on_error_once = nil  # only one guy uses this

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
          files.length.zero? && never  # when we change frameworks this might change
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

      def __resolve_file_path_upstream_via_corpus_step _

        sct = Home_::CrazyTownMagneticsForMainReport_::PathStream_via_CorpusStep.call_by do |o|

          o.filesystem = @_filesystem
          o.listener = @listener
        end

        if sct
          @_file_path_upstream = sct.path_stream
          @_on_error_once = sct.save_corpus_step
          ACHIEVED_
        end
      end

      def __resolve_file_path_upstream_via_files_file files_file
        if DASH_ == files_file
          _etc_via_IO $stdin  # NOTE [br] is unusable. #todo
        else
          _etc_via_IO @_filesystem.open files_file  # ..
        end
      end

      def __resolve_file_path_upstream_via_files files
        @_file_path_upstream = Stream_[ files ]
        ACHIEVED_
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
        ACHIEVED_
      end
    # -

    # ==

    Stream_big_string_into_ = -> y, big_string do
      # assume at least one line. because OCD, stream each line line by line
      #
      scn = Home_.lib_.basic::String::LineStream_via_String[ big_string ]
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
    # ==
  end
end
# #born.
