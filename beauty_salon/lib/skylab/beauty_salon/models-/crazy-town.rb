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
        :property, :file_file,


        :parameter_arity, :zero_or_more,
        :description, -> y do
          y << "a code file to make a diff against"
        end,
        :property, :file,


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
        if __resolve_file_path_upstream
          __money_town
        end
      end

      def __money_town

        _hi = Home_::CrazyTownMagnetics_::DiffLineStream_via_Arguments.call_by do |o|

          o.file_path_upstream = remove_instance_variable :@_file_path_upstream

          o.code_selector_string = remove_instance_variable :@code_selector

          o.replacement_function_string = remove_instance_variable :@replacement_function

          o.report = remove_instance_variable :@report

          o.filesystem = @_filesystem

          o.listener = @listener
        end

        _hi
      end

      def __resolve_file_path_upstream

        # NOTE - we anticipate switching over to modern techniques soon
        # but for now BE CAREFUL - WE COULD CLOBBER IVARS

        h = remove_instance_variable( :@argument_box ).h_

        @code_selector = h.fetch :code_selector

        @replacement_function = h.fetch :replacement_function

        @report = h[ :report ]

        @_filesystem = ::File

        @listener = remove_instance_variable :@on_event_selectively  # modern way now

        files = h[ :file ]
        files && files.length.zero? && never  # when we change frameworks..

        file_file = h[ :file_file ]

        if files
          if file_file
            __explain_that_you_cant_have_both
          else
            @_file_path_upstream = Stream_[ files ] ; ACHIEVED_
          end
        elsif file_file
          if DASH_ == file_file
            @file_path_upstream = $stdin  # NOTE [br] is unusable. #todo
            ACHIEVED_
          else
            @_file_path_upstream = @_filesystem.open file_file  # ..
            ACHIEVED_
          end
        else
          __explain_must_have_one
        end
      end

      def __explain_that_you_cant_have_both
        _same "can't have both", "and"
      end

      def __explain_must_have_one
        _same "must have", "or"
      end

      def _same head, join
        @listener.call :error, :expression do |y|
          y << "#{ head } <file-file> #{ join } <file>"
        end
        UNABLE_
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
