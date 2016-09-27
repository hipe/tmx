module Skylab::DocTest

  module OutputAdapters_::Quickie

    class ViewControllers_::ExampleNode  # #[#026]

      TEMPLATE_FILE___ = '_eg-simple.tmpl'

      class << self

        def via_two_ para, cx
          via_three_ para, NOTHING_, cx
        end

        alias_method :via_three_, :new
        undef_method :new
      end  # >>

      def initialize para, visible_shared, cx

        if visible_shared
          @_has_visible_shared_items = true
          @_visible_shared_items = visible_shared
        else
          @_has_visible_shared_items = false
        end

        @_common = para
        @_choices = cx
        __init_description_bytes
      end

      def to_branch_local_document_node_matcher

        if @_has_description_bytes

          id_s = @_identifying_string

          -> doc_node do

            id_s_ = doc_node.any_document_unique_identifying_string
            if id_s_
              id_s == id_s_  # (hi.)
            end
          end
        end
      end

      def to_line_stream & p
        dup.extend( ToLineStream___ ).__init( p ).execute
      end

      # == ON

      module ToLineStream___

        def __init p
          @_listener = p
          self
        end

      def execute
        ok = @_has_description_bytes
        ok && __init_body_line_stream
        ok && __assemble_template_and_etc
      end

      def __init_body_line_stream

        st = __body_line_stream_normally
        if @_has_visible_shared_items
          st = @_visible_shared_items.map_body_line_stream st
        end
        @__body_line_stream = st
        NIL
      end

      def __body_line_stream_normally  # (based off model)

        # (this became the worst thing ever when we tried to add stripping
        # trailing blank lines to it. before it was pretty straightforward.
        # see tombstone.)

        lo_st = @_common.to_code_run_line_object_stream

        # "cbl": cached blank lines EEW. "lo": line object

        cbl = nil ; lo = nil ; main_p = nil ; p = nil

        transition_to_cbl = -> do  # #coverpoint4-1
          st = Stream_[ cbl ] ; cbl = nil
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

            _assertion_stem = lo.to_stem_paraphernalia_given @_choices
            st = _assertion_stem.to_line_stream( & @_listener )
            # we assume the above never to fail per [#042] #note-2

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

        Common_.stream do
          p[]
        end
      end
      end

      # == OFF

      def identifying_string
        @_has_description_bytes && @_identifying_string
      end

      def __init_description_bytes

        o = @_common.begin_description_string_session

        o.use_last_nonblank_line!

        if o.found
          o.remove_any_trailing_colons_or_commas!
          # o.remove_any_leading_so_and_or_then!  when nec
          o.remove_any_leading_it!
          # o.uncontract_any_leading_its!  when nec

          @_identifying_string = o.get_current_string
            # (take a snapshot of the string as it stands now before the next line)

          o.escape_as_platform_string!
        end

        if ! o.found || o.is_blank
          @_has_description_bytes = false
        else
          @_has_description_bytes = true
          @description_bytes_ = o.finish
        end
        NIL
      end

    # == ON (again)

      module ToLineStream___
      def __assemble_template_and_etc  # (based off model)

        t = @_choices.load_template_for TEMPLATE_FILE___

        t.set_simple_template_variable(
          remove_instance_variable( :@description_bytes_ ),
          :description_bytes,
        )

        t.set_multiline_template_variable(
          remove_instance_variable( :@__body_line_stream ),
          :example_body,
        )

        t.flush_to_line_stream
      end
      end

    # == OFF (again)

      def paraphernalia_category_symbol
        :example_node
      end
    end
  end
end
# #tombstone: straightforward version left behind to trim trailing blanks
