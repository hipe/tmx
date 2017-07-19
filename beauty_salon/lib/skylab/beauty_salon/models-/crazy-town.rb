module Skylab::BeautySalon

  # NOTE - this file is just GLUE for the legacy [br] app code to
  # our modern techniques..

  Require_brazen_LEGACY_[]

  class Models_::CrazyTown < Brazen_::Action

    # -

      Brazen_::Modelesque.entity self

      edit_entity_class(

        :required, :property, :files_file,
        :required, :property, :code_selector,
        :required, :property, :replacement_function,

        :branch_description, -> y do

          _big_string =  <<-O.gsub %r(^ {12}), EMPTY_S_
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

          scn = Home_.lib_.basic::String::LineStream_via_String[ _big_string ]
          while (( s = scn.gets ))
            y << s
          end
          NIL
        end,
      )

      def produce_result
        # via_properties_init_ivars nah.
        p = -> do
          p = -> { NOTHING_ }
          "one line"
        end

        _hi = Common_.stream do
          p[]
        end
        _hi
      end
    # -
  end
end
# #born.
