module Skylab::DocTest

  module OutputAdapters_::Quickie

    class ViewControllers_::ExampleNode  # #[#026]

      TEMPLATE_FILE___ = '_eg-simple.tmpl'

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

        # (this became the worst thing ever when we tried to add stripping
        # trailing blank lines to it. before it was pretty straightforward.
        # see tombstone.)

        lo_st = @_common.to_code_run_line_object_stream

        # "cbl": cached blank lines EEW. "lo": line object

        cbl = nil ; lo = nil ; main_p = nil ; p = nil

        transition_to_cbl = -> do
          ::Kernel._K_probably_fine
          st = Common_::Stream.via_nonsparse_array cbl ; cbl = nil
          p = -> do
            lo_ = st.gets
            if lo_
              lo_.get_content_line
            else
              p = main_p
              p[]
            end
          end
        end

        transition_to_eek = -> do  # allow the code run line that has the
          # magic copula to expand to take up more than one line, all the
          # while streaming.

          st = lo.to_common_paraphernalia_given( @_choices ).to_line_stream
          lo = nil
          p = -> do
            s = st.gets
            if s
              s
            else
              p = main_p
              p[]
            end
          end
        end

        main_p = -> do
          begin
            lo ||= lo_st.gets
            if ! lo
              # NOTE whether or not there is a CBL, finish
              p = nil
              x = lo
              break
            end
            if lo.is_blank_line
              (cbl ||= []).push lo ; lo = nil
              redo
            end
            if cbl
              transition_to_cbl[]
              x = p[]
              break
            end
            if lo.has_magic_copula
              transition_to_eek[]
              x = p[]
              break
            end
            x = lo.get_content_line ; lo = nil
            break
          end while nil
          x
        end
        p = main_p

        @_body_line_stream = Common_.stream do
          p[]
        end
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

        t = @_choices.load_template_for TEMPLATE_FILE___

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
# #tombstone: straightforward version left behind to trim trailing blanks
