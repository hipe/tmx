module Skylab::DocTest

  module OutputAdapters_::Quickie

    class ViewControllers_::ExampleNode  # #[#026]

      TEMPLATE_FILE__ = '_eg-simple.tmpl'

      def initialize para, cx
        @_common = para
        @_choices = cx
      end

      def to_line_stream
        ok = __resolve_body_line_stream
        ok &&= __resolve_description_bytes
        ok && __assemble_template_and_etc
      end

      def __resolve_body_line_stream  # (based off model)

        _line_object_stream = @_common.to_code_run_line_object_stream

        _ = _line_object_stream.expand_by do |li|

          if li.has_magic_copula
            li.to_common_paraphernalia_given( @_choices ).to_line_stream
          else
            li.to_line_stream
          end
        end

        @_body_line_stream = _
        ACHIEVED_
      end

      def __resolve_description_bytes  # (based off model)

        o = @_common.begin_description_string_session

        o.use_last_nonblank_line!

        if o.found
          o.remove_any_trailing_colons_or_commas!
          # o.remove_any_leading_so_and_or_then!  when nec
          o.remove_any_leading_it!
          # o.uncontract_any_leading_its!  when nec
          o.escape_as_platform_string!
        end

        if ! o.found || o.is_blank
          UNABLE_
        else
          @_description_bytes = o.finish
          ACHIEVED_
        end
      end

      def __assemble_template_and_etc  # (based off model)

        t = @_choices.load_template_for TEMPLATE_FILE__

        t.set_simple_template_variable(
          remove_instance_variable( :@_description_bytes ),
          :description_bytes,
        )

        t.set_multiline_template_variable(
          remove_instance_variable( :@_body_line_stream ),
          :example_body,
        )

        t.flush_to_line_stream
      end
    end
  end
end
