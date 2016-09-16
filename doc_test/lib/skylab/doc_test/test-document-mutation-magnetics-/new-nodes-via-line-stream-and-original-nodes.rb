module Skylab::DocTest

  class TestDocumentMutationMagnetics_::NewNodes_via_LineStream_and_OriginalNodes

        # following the general design tenet of [#017] (but in a manner that
        # is experimental) we prefer to use "any" "formatting" in the test
        # document (i.e "target") over "any" "formatting" that is in the
        # asset (i.e "source") document where:
        #
        # by "formatting" we mean the any runs of one or more blank lines
        # variously at the "head" and "tail" of the "constituent" lines.
        # (here by "constituent" lines we mean body lines, i.e not the first
        # (beginning) line and not the last (ending) line.
        #
        # that is to say, if for example the user seems to like having one
        # blank line before and/or one blank line after the main code lines
        # in a test (in the test document), we will use that formatting
        # (indeed those very "same" lines) in the output document; regardless
        # of how blank lines are used at the head and/or tail of the
        # counterpart lines in the asset document "example" runs.
        #
        # (however if the node in the test document seems like it is a stub
        # example because it has exactly zero body lines, then we will use
        # any leading and/or trailing blank lines in the asset document!
        # wait, no it won't. because the syntax doesn't pick up such spacing..)

        class << self
          alias_method :begin, :new
          undef_method :new
        end  # >>

        attr_writer(
          :do_replace_constituent_lines,
          :line_stream,
          :original_nodes,
        )

        def finish

          __init

          __from_the_back_pop_off_those_nodes_that_you_intend_to_reuse

          __from_the_front_shift_off_those_nodes_that_you_intend_to_reuse

          if __there_is_any_nonblank_content_in_the_original_example
            __use_the_two_blankruns_of_the_original
          else
            __do_not_use_the_two_blankruns_of_the_original
          end

          __build_final_assembly
        end

        def __build_final_assembly

          beginline_node = remove_instance_variable :@_beginline_node

          a = []
          a.push beginline_node
          yes = remove_instance_variable :@_use_blankruns_of_original
          if yes
            a_ = remove_instance_variable :@_head_blank_run
            if a_
              a.concat a_
            end
          end

          st = remove_instance_variable :@line_stream
          s = st.gets

          _margin = beginline_node.get_margin
          if @do_replace_constituent_lines
            margin_ = "  #{ _margin }"  # hardcoded #indent ick/meh
          else
            margin_ = _margin
          end

          begin
            _li = if BLANK_RX_ =~ s
              ErsatzParser::Line.new s, :blank_line
            else
              ErsatzParser::Line.new "#{ margin_ }#{ s }", :nonblank_line
            end
            a.push _li
            s = st.gets
          end while s

          if yes
            a_ = remove_instance_variable :@_tail_blank_run
            if a_
              a.concat a_
            end
          end
          a.push remove_instance_variable :@_endline_node
          a
        end

        def __there_is_any_nonblank_content_in_the_original_example
          @_has_current_forward_node || @_has_current_reverse_node
        end

        def __use_the_two_blankruns_of_the_original

          # if we're using the "formatting" in the original then we don't
          # want that of the replacement. (hypothetically we cannot end up
          # with no lines here because code runs axiomatically must have
          # at least one nonblank.) amusingly we do the same overall
          # algoithm we do "complicatedly" at the end of the document
          # but more simply.

          @_use_blankruns_of_original = true

          st = remove_instance_variable :@line_stream

          unless @do_replace_constituent_lines
            st.gets  # disregard the opener
          end

          s = st.gets
          begin
            if BLANK_RX_ =~ s
              s = st.gets
              redo
            end
          end while nil

          a = []
          begin
            a.push s
            s = st.gets
          end while s

          unless @do_replace_constituent_lines
            a.pop  # disregard the closer
          end

          while BLANK_RX_ =~ a.last
            a.pop
          end

          @line_stream = Common_::Stream.via_nonsparse_array a
          _clear_scanners
        end

        def __do_not_use_the_two_blankruns_of_the_original
          @_use_blankruns_of_original = false
          remove_instance_variable :@_head_blank_run
          remove_instance_variable :@_tail_blank_run
          _clear_scanners
        end

        def _clear_scanners
          remove_instance_variable :@_current_forward_node
          remove_instance_variable :@_current_reverse_node
          remove_instance_variable :@_advance_forward_scanner
          remove_instance_variable :@_has_current_forward_node
          remove_instance_variable :@_has_current_reverse_node
          NIL_
        end

        def __from_the_front_shift_off_those_nodes_that_you_intend_to_reuse

          @__init_forward_scanner[]
          @_beginline_node = @_current_forward_node
          @_advance_forward_scanner[]
          a = nil
          while @_has_current_forward_node && @_current_forward_node.is_blank_line
            ( a ||= [] ).push @_current_forward_node
            @_advance_forward_scanner[]
          end
          @_head_blank_run = a ; nil
        end

        def __from_the_back_pop_off_those_nodes_that_you_intend_to_reuse
          @_endline_node = @_current_reverse_node
          @_advance_reverse_scanner[]
          a = nil
          while @_has_current_reverse_node && @_current_reverse_node.is_blank_line
            ( a ||= [] ).push @_current_reverse_node
            @_advance_reverse_scanner[]
          end
          @_tail_blank_run = a ; nil
        end

        def __init  # eew / meh

          current_reverse_node_index = @original_nodes.length
          final_reverse_node_index = 1

          @_advance_reverse_scanner = -> do
            if final_reverse_node_index == current_reverse_node_index
              @_current_reverse_node = nil
              @_has_current_reverse_node = false
            else
              current_reverse_node_index -= 1
              @_current_reverse_node = @original_nodes.fetch current_reverse_node_index ; nil
            end
          end
          @_current_reverse_node = nil
          @_has_current_reverse_node = true

          @_advance_reverse_scanner[]

          # --

          @__init_forward_scanner = -> do

            remove_instance_variable :@_advance_reverse_scanner
            remove_instance_variable :@__init_forward_scanner

            @_current_forward_node = @original_nodes.fetch 0
            current_forward_node_index = 0
            @_has_current_forward_node = true

            my_last = current_reverse_node_index - 1
            @_advance_forward_scanner = -> do
              if my_last == current_forward_node_index
                @_current_forward_node = nil
                @_has_current_forward_node = false
              else
                current_forward_node_index += 1
                @_current_forward_node = @original_nodes.fetch current_forward_node_index ; nil
              end
            end
          end
        end
  end
end
