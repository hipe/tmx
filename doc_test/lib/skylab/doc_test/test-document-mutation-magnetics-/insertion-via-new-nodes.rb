module Skylab::DocTest

  module TestDocumentMutationMagnetics_::Insertion_via_NewNodes

    # (ALL of this is in service of the "ersatz parser" mutator methods only.)

    # these are attempts at making higher-level "edit macros" that
    # try to infer formatting to use (mainly insertion of blank lines)
    # agnostic of the particular solution.

    Prepend_before_some_existing = -> no, nodes do

      _idx = Index__.of nodes do |o|
        o.__record_between_first_and_second_node_of_interest
      end

      o = Rewrite__.new _idx, nodes
      o.write_nodes_before_the_reference_node
      o.write_new_node_of_interest no
      o.write_separating_blank_line_run
      o.write_from_the_reference_node_to_end
      o.finish
    end

    Insert_after = -> after_this_noi, no, nodes do

      _idx = Index__.of nodes do |o|
        o.__will_search_for_this after_this_noi
      end

      o = Rewrite__.new _idx, nodes
      o.write_nodes_through_the_reference_node
      o.write_separating_blank_line_run
      o.write_new_node no

      if o.nodes_exist_after_the_reference_node

            # assume there was already some separating blank lines ahead
            # of this remaining content; so we don't write our own.

        o.write_nodes_after_the_reference_node_to_the_end
      end

      o.finish
    end

    Hack_insert_first_content = -> no, nodes do

      _idx = Index__.of nodes do |o|
        o.__set_reference_node_to_be_the_penultimate_node
      end

      o = Rewrite__.new _idx, nodes
      o.write_nodes_through_the_reference_node
      o.write_blank_line_if_necessary
      o.write_new_node no
      o.write_nodes_after_the_reference_node_to_the_end
      o.finish
    end

    Begin_insert_into_empty = -> nodes do
      _idx = Index__.of nodes
      Rewrite__.new _idx, nodes
    end

    class Rewrite__

          def initialize idx, nodes
            @index = idx
            @reference_index = nil
            @original_nodes = nodes
            @result_nodes = []
          end

      def write_nodes_through_the_reference_node
            ( @index.reference_index + 1 ).times do |d|
              @result_nodes.push @original_nodes.fetch d
            end
      end

      def write_nodes_before_the_reference_node
            @index.reference_index.times do |d|
              @result_nodes.push @original_nodes.fetch d
            end
      end

      def write_from_beginning_through_penultimate
        @reference_index = @original_nodes.length - 1
        @reference_index.times do |d|
          @result_nodes.push @original_nodes.fetch d
        end
        NIL
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

      def write_new_node no

        if Paraphernalia_::Is_node_of_interest[ no ]
          write_new_node_of_interest no
        else
          __create_and_push_freeform_branch_frame_for no
        end
      end

      def write_new_node_of_interest no

        _st = no.to_line_stream

        __write_node_of_interest(
          no.paraphernalia_category_symbol,
          no.identifying_string,
          _st,
        )
        NIL
      end

      def __write_node_of_interest sym, is, st  # is=identifying string; st=line stream

        bf = ErsatzParser::FreeformBranchFrame.via_four(
          is, sym, st, __get_margin )

        if bf
          @result_nodes.push bf
        end
        NIL
      end

      def __create_and_push_freeform_branch_frame_for no

        _id_x = no.TOUCH_EXPERIMENTAL_UNIQUE_IDENTIFIER
        _sym = no.paraphernalia_category_symbol
        _st = no.to_line_stream

        # --  # eek see #spot-6
        d = @index.reference_index
        d || fail
        node = @original_nodes.fetch d
        if node.is_branch
          margin = node.nodes.first.get_margin
        elsif BLANK_RX_ =~ node.line_string
          margin = node.line_string
          margin.chop!
          @result_nodes.pop  # eek don't use the line meant to show indent
        else
          margin = node.get_margin
        end
        # --

        bf = ErsatzParser::FreeformBranchFrame.via_four(
          _id_x, _sym, _st, margin )

        if bf
          @result_nodes.push bf
        end
        NIL
      end

      def __get_margin

        d = @index.reference_index
        if d
          node = @original_nodes.fetch d
          if node.is_branch
            node.nodes.first.get_margin
          else
            node.get_margin
          end
        else
              "#{ @original_nodes.fetch( 0 ).get_margin }  "  # manual #indent #ick
        end
      end

      def nodes_exist_after_the_reference_node
            @index.reference_index < @original_nodes.length - 1
      end

      def write_nodes_after_the_reference_node_to_the_end
            ( @index.reference_index + 1 ... @original_nodes.length ).each do |d|
              @result_nodes.push @original_nodes.fetch d
            end
      end

      def write_from_the_reference_node_to_end
            _eek = @reference_index || @index.reference_index
            ( _eek ... @original_nodes.length ).each do |d|
              @result_nodes.push @original_nodes.fetch d
            end
        NIL
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

      class << self
        def of nodes
          o = BuildIndex___.new nodes
          yield o if block_given?
          o.execute
        end
      end  # >>

      def initialize _, __
        @reference_index = _
        @separating_blank_lines_array = __
      end

      attr_reader(
        :reference_index,
        :separating_blank_lines_array,
      )
    end

    class BuildIndex___

      def initialize nodes
        @nodes = nodes

        @_stop = false
        @_on_before = :_ignore
        @_on_blank_line = :_ignore
        @_on_context = :_ignore
        @_on_module = :_ignore
        @_on_nonblank_line = :_ignore
        @reference_index = nil
      end

      def __set_reference_node_to_be_the_penultimate_node
        len = @nodes.length
        1 < len || fail
        @reference_index = len - 2
        @_stop = true
        NIL
      end

      def __record_between_first_and_second_node_of_interest
        @_on_context = :_on_first_node_of_interest
        @_on_example = :_on_first_node_of_interest
      end

      def _on_first_node_of_interest

        @reference_index = @_current_node_index
        @_blank_lines_array = []
        @_on_blank_line = :_record_this_blank_line
        @_on_nonblank_line = :_stop_recording_blank_lines
        @_on_context = :_stop_recording_blank_lines
        @_on_example = :_stop_recording_blank_lines
      end

      def __will_search_for_this after_this

        if Paraphernalia_::Is_node_of_interest[ after_this ]
          @_find_me = after_this.identifying_string
        else
          @_find_me = after_this.EXPERIMENTAL_UNIQUE_IDENTIFIER
        end

        @_blank_lines_array = []
        @_on_blank_line = :_record_this_blank_line
        @_on_nonblank_line = :__this_special_thing
        @_on_context = :_is_this_the_node_of_interest
        @_on_example = :_is_this_the_node_of_interest
        @_on_shared_setup = :_is_this_the_node_of_interest
      end

          # --

      def execute
        @separating_blank_lines_array = nil
        __do_index
        Index__.new @reference_index, @separating_blank_lines_array
      end

      def __do_index

        ( 1 ... @nodes.length-1 ).each do |d|
          @_stop && break
          @_current_node_index = d
          @_current_node = @nodes.fetch d
          send instance_variable_get IVARS___.fetch @_current_node.category_symbol
        end
        NIL
      end

          def _record_this_blank_line
            @_blank_lines_array.push remove_instance_variable :@_current_node
          end

      def _is_this_the_node_of_interest

        if @_find_me == @_current_node.mixed_identifying_key
          @reference_index = @_current_node_index
          _stop_recording_blank_lines
        else
          @_blank_lines_array.clear
        end
        NIL
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
        before: :@_on_before,
        blank_line: :@_on_blank_line,
        const_definition_shared_setup: :@_on_shared_setup,
        context_node: :@_on_context,
        example_node: :@_on_example,
        module: :@_on_module,
        nonblank_line: :@_on_nonblank_line,
        shared_subject_shared_setup: :@_on_shared_setup,
      }
    end

        # ==

        Blank_line_ = Lazy_.call do
          Line_.new NEWLINE_, :blank_line
        end

        Line_ = ErsatzParser::Line
  end
end
