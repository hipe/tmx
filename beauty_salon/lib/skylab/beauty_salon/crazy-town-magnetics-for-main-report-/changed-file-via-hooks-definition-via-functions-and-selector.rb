module Skylab::BeautySalon

  class CrazyTownMagneticsForMainReport_::
      FileChanges_via_HooksDefinition_via_Functions_and_Selector < Common_::MagneticBySimpleModel

    # -

      attr_writer(
        :code_selector,
        :replacement_function,
        :listener,
      )

      def execute
        self
      end

      def flush_definition__ y, oo

        # NOTE - this is all stub code - as apporiate by the selector ..

        oo.before_each_file do |potential_sexp|

          _fc = FileChanges___.new potential_sexp.path

          CrazyTownMagneticsForMainReport_::DiffLineStream_via_FileChanges.call_by do |o|
            o.line_yielder = y
            o.file_changes = _fc
            o.listener = @listener
          end
        end
        NIL
      end

      def __money

        _sexp = remove_instance_variable :@__sexp

        CrazyTownMagnetics_::TriggerEvents_via_Sexp_and_Hooks.call_by do |o|
          o.sexp = _sexp
          o.code_selector = @code_selector
          o.replacement_function = @replacement_function
          o.listener = @listener
        end
      end
    # -

    # ==

    class FileChanges___

      def initialize path
        @path = path
      end

      def to_diff_body_line_stream__

        _big_string = <<-O
          @@ -1,5 +1,5 @@
           module Xx
             def yy
          -    foo.shall resemble :hi
          +    expect( foo ).to resemble :hi
             end
           end
        O
        r = 10..-1
        scn = Home_.lib_.basic::String::LineStream_via_String[ _big_string ]
        Common_.stream do
          line = scn.gets
          if line
            line[ r ]
          end
        end
      end

      attr_reader(
        :path,
      )
    end

    # ==
    # ==
  end
end
# #born.
