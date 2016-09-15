module Skylab::DocTest

  module Models_::Document

    class ErsatzParser

      module NodeInsertion__

        Empty = -> nodes do

          idx = Index__.new nodes
          idx.work

          Motifs__.new idx, nodes
        end

        Prepend = -> eg, nodes do

          idx = Index__.new nodes
          idx.__record_between_first_and_second_example
          idx.work

          o = Motifs__.new idx, nodes
          o.write_nodes_before_the_reference_example
          o.write_new_example_node eg
          o.write_separating_blank_line_run
          o.write_from_the_reference_example_to_end
          o.finish
        end

        After = -> after_this_eg, eg, nodes do

          idx = Index__.new nodes
          idx.__will_search_for_this after_this_eg
          idx.work

          o = Motifs__.new idx, nodes
          o.write_nodes_through_the_reference_example
          o.write_separating_blank_line_run
          o.write_new_example_node eg

          if o.nodes_exist_after_the_reference_example

            # assume there was already some separating blank lines ahead
            # of this remaining content; so we don't write our own.

            o.write_nodes_after_the_reference_example_to_the_end
          end

          o.finish
        end

        class Motifs__

          def initialize idx, nodes
            @index = idx
            @reference_index = nil
            @original_nodes = nodes
            @result_nodes = []
          end

          def write_nodes_through_the_reference_example

            ( @index.reference_index + 1 ).times do |d|
              @result_nodes.push @original_nodes.fetch d
            end
          end

          def write_nodes_before_the_reference_example

            @index.reference_index.times do |d|
              @result_nodes.push @original_nodes.fetch d
            end
          end

          def write_opening_node_and_any_blank_lines

            st = Common_::Polymorphic_Stream.via_array @original_nodes
            @result_nodes.push st.gets_one
            begin
              st.no_unparsed_exists && break
              o = st.current_token
              :blank_line == o.category_symbol || break
              @result_nodes.push o
              st.advance_one
              redo
            end while nil
            @reference_index = st.current_index
          end

          def write_new_example_node eg

            margin = ___get_reference_margin
            nodes = []

            st = eg.to_line_stream

            nodes.push Line_.new( "#{ margin }#{ st.gets }", :nonblank_line )  # or..
            begin
              line = st.gets
              line or break
              _o = if BLANK_RX_ =~ line
                Line_.new line, :blank_line
              else
                Line_.new "#{ margin }#{ line }", :nonblank_line
              end
              nodes.push _o
              redo
            end while nil

            @result_nodes.push FreeformBranchFrame_.new( :example_node, eg, nodes )

            NIL_
          end

          def ___get_reference_margin

            d = @index.reference_index
            if d
              @original_nodes.fetch( d ).nodes.first.get_margin
            else
              "#{ @original_nodes.fetch( 0 ).get_margin }  "  # manual #indent #ick
            end
          end

          def nodes_exist_after_the_reference_example
            @index.reference_index < @original_nodes.length - 1
          end

          def write_nodes_after_the_reference_example_to_the_end
            ( @index.reference_index + 1 ... @original_nodes.length ).each do |d|
              @result_nodes.push @original_nodes.fetch d
            end
          end

          def write_from_the_reference_example_to_end
            _eek = @reference_index || @index.reference_index
            ( _eek ... @original_nodes.length ).each do |d|
              @result_nodes.push @original_nodes.fetch d
            end
          end

          def write_blank_line_if_necessary
            last = @result_nodes.last
            if ! last || :blank_line != last.category_symbol
              @result_nodes.push Blank_line_[]
            end
            NIL_
          end

          def write_separating_blank_line_run
            a = @index.separating_blank_lines_array
            if a
              @result_nodes.concat a
            end
            NIL
          end

          attr_writer(
            :reference_margin,
          )

          def finish
            remove_instance_variable( :@result_nodes ).freeze
          end

          attr_reader(
            :index,
          )
        end

        class Index__

          def initialize nodes
            @nodes = nodes

            @_stop = false
            @_on_blank_line = :_ignore
            @_on_module = :_ignore
            @_on_nonblank_line = :_ignore
          end

          def __record_between_first_and_second_example
            @_on_example_node = :__on_first_example_etc
          end

          def __on_first_example_etc

            @reference_index = @_current_node_index
            @_blank_lines_array = []
            @_on_blank_line = :_record_this_blank_line
            @_on_nonblank_line = :_stop_recording_blank_lines
            @_on_example_node = :_stop_recording_blank_lines
          end

          def __will_search_for_this after_this

            @_blank_lines_array = []
            @_on_blank_line = :_record_this_blank_line
            @_on_nonblank_line = :__this_special_thing
            @_find_me = after_this.identifying_string
            @_on_example_node = :__is_this_the_example_node
          end

          # --

          def work

            ( 1 ... @nodes.length-1 ).each do |d|
              @_current_node_index = d
              @_current_node = @nodes.fetch d
              send instance_variable_get IVARS___.fetch @_current_node.category_symbol
              @_stop && break
            end
            NIL_
          end

          def _record_this_blank_line
            @_blank_lines_array.push remove_instance_variable :@_current_node
          end

          def __is_this_the_example_node

            if @_find_me == @_current_node.identifying_string
              @reference_index = @_current_node_index
              _stop_recording_blank_lines
            else
              @_blank_lines_array.clear
            end
          end

          def __this_special_thing
            @_blank_lines_array.clear
          end

          def _stop_recording_blank_lines
            @separating_blank_lines_array = remove_instance_variable( :@_blank_lines_array ).freeze
            @_stop = true
          end

          def _ignore
            NOTHING_
          end

          IVARS___ = {
            blank_line: :@_on_blank_line,
            example_node: :@_on_example_node,
            module: :@_on_module,
            nonblank_line: :@_on_nonblank_line,
          }

          attr_reader(
            :reference_index,
            :separating_blank_lines_array,
          )
        end

        # ==

        Blank_line_ = Lazy_.call do
          Line_.new NEWLINE_, :blank_line
        end
      end
    end
  end
end
