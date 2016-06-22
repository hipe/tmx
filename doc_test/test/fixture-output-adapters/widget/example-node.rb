module Skylab::DocTest

  module TestSupport::FixtureOutputAdapters::Widget

    class ExampleNode

      # this is our first attempt at a model implementation of a particular
      # paraphernalia, exploring a would-be spec for that at [#026].

      # in this implementation, rather than go deeply into an [ac] "ACS"
      # pattern where the two main components here get their own classes
      # (and templates!) etc, we just cram a lot of the work into this file
      # under the justification that this is a good sized SLOC.

      TEMPLATE_FILE___ = 'eg.templa'

      def initialize para, cx
        @_choices = cx
        @_common = para
      end

      def to_line_stream
        ok = __resolve_body_line_stream
        ok &&= __resolve_description_method_name
        ok && __assemble_template_and_etc
      end

      def __resolve_body_line_stream

        _ = @_common.to_code_run_line_object_stream.map_by do |li|

          if li.has_magic_copula
            li.to_common_paraphernalia_given( @_choices ).to_line
          else
            li.get_content_line
          end
        end

        @_body_line_stream = _
        ACHIEVED_
      end

      def __resolve_description_method_name

        o = @_common.begin_description_string_session

        o.use_last_nonblank_line!

        if o.found
          o.remove_any_trailing_colons_or_commas!
          o.remove_any_leading_it!
          o.convert_to_snake_case!
        end

        if ! o.found || o.is_blank
          UNABLE_
        else
          @_test_case_method_name = "test_case_#{ o.finish }"
          ACHIEVED_
        end
      end

      def __assemble_template_and_etc

        t = @_choices.load_template_for TEMPLATE_FILE___

        t.set_simple_template_variable(
          remove_instance_variable( :@_test_case_method_name ),
          :test_case_method_name,
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
