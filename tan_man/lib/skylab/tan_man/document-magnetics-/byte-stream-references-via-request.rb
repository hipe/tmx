module Skylab::TanMan

  class DocumentMagnetics_::ByteStreamReferences_via_Request < Common_::MagneticBySimpleModel

    # [#026.B] explains how IO is manifested in our association modeling system.

    # given one or both "throughput directions" (input and/or output), solve
    # a single qualified actual parameter for each direction. if exactly one
    # cannot be resolved for each direction unambiguously, fail expressively

    # oh, also, this thing with "hereput"

    # -

      def will_solve_for * input_hereput_output
        @_number_of_directions = input_hereput_output.length
        @_solve_for_these_symbols = input_hereput_output
        NIL
      end

      def will_enforce_minimum
        @_do_enforce_minimum  = :__TRUE
      end

      def will_NOT_enforce_minimum
        @_do_enforce_minimum = :__FALSE
      end

      attr_writer(
        :qualified_knownness_box,
        :listener,
      )

      # --

      def execute

        __classify_each_association_under_the_directions_it_solves_for

        __for_each_direction do
          __resolve_at_most_one_bytestream_reference_for_this_direction
        end

        __flush_final_result
      end

      # -- D

      def __flush_final_result

        _a = remove_instance_variable :@__final_QKs
        _q_a = remove_instance_variable :@qualifieds_via_direction_offset
        if @_ok
          MyResult___.new _a, _q_a
        else
          self._COVER_ME__xx__
        end
      end

      MyResult___ = ::Struct.new(
        :byte_stream_reference_qualified_knownness_array,
        :qualifieds_via_direction_offset,
      )

      # -- C

      def __resolve_at_most_one_bytestream_reference_for_this_direction

        if __resolve_exactly_one_qualified_value_for_this_direction

          __resolve_bytestream_reference_via_current_qualified_value
        end
        NIL
      end

      def __resolve_bytestream_reference_via_current_qualified_value

        qkn = remove_instance_variable :@_current_qualified_value

        ref = Mags_[]::
          ByteStreamReference_via_QualifiedKnownness_and_ThroughputDirection.call(
            qkn, @_current_direction_symbol )

        if ref
          @__final_QKs[ @_current_direction_offset ] = qkn.new_with_value ref
        else
          @_ok = false  # assume emitted
        end
        NIL
      end

      # -- B

      def __resolve_exactly_one_qualified_value_for_this_direction

        do_enforce_minimum = send @_do_enforce_minimum  # #hi.

        qkn_a = @qualifieds_via_direction_offset.fetch @_current_direction_offset
        if qkn_a
          use_qkn_a = nil
          qkn_a.each do |qkn|
            qkn.is_effectively_trueish || next
            ( use_qkn_a ||= [] ).push qkn
          end
        end

        if use_qkn_a
          case 1 <=> use_qkn_a.length
          when 0  # length of 1
            @_current_qualified_value = use_qkn_a.fetch 0
            YES_

          when -1  # length of many
            __tiebreak use_qkn_a

          else ; no
          end
        elsif do_enforce_minimum
          __when_zero_for_this_direction
        else
          NO_  # hi.
        end
      end

      def __for_each_direction

        @_ok = true  # (sneak this in here)
        @__final_QKs = ::Array.new @_number_of_directions  # (acutally 3x)

        @_solve_for_these_symbols.each_with_index do |sym, d|
          @_current_direction_symbol = sym
          @_current_direction_offset = d
          yield
          # @_ok || break  # (we don't have to short circuit here but we choose to.)
        end
        NIL
      end

      def __when_zero_for_this_direction
        Emit_via_NonOneScenario.call_by do |o|
          o.parameter_symbols_via_direction = nil
          o.direction_symbol = @_current_direction_symbol
          o.listener = @listener
        end
        @_ok = false ; NO_
      end

      # -- A

      def __classify_each_association_under_the_directions_it_solves_for

        # for each qualified knownness in the box (whether it has a
        # provided value or not), index it under each direction it can solve
        # for..

        a = ::Array.new @_number_of_directions

        @qualified_knownness_box.each_value do |qkn|

          asc = qkn.association
          tc = asc._throughput_characteristics_
          tc || next

          @_solve_for_these_symbols.each_with_index do |direction_sym, d|
            tc[ direction_sym ] || next
            ( a[ d ] ||= [] ).push qkn
          end
        end
        @qualifieds_via_direction_offset = a.freeze
        NIL
      end

      def __TRUE
        TRUE
      end

      def __FALSE
        FALSE
      end

    # -

    # ==

    class Emit_via_NonOneScenario < Common_::MagneticBySimpleModel

      def direction_symbol= sym
        # (this is kept as-is to hide the fact that internally we represent them the same)
        self.direction_symbols = [ sym ] ; sym
      end

      attr_writer(
        :direction_symbols,
        :listener,
        :parameter_symbols_via_direction,
      )

      def execute
        @listener.call :error, :non_one_IO do
          __build_event
        end
      end

      def __build_event
        me = self
        Common_::Event.inline_not_OK_with(
          :non_one_IO,
          :direction_symbols, @direction_symbols,
          :parameter_symbols_via_direction, @parameter_symbols_via_direction,

        ) do |y, _o|
          me.__express_into_under y, self
        end
      end

      def __express_into_under y, expag
        @_current_expression_agent = expag
        @_current_line_yielder = y
        __express
      end

      def __express
        if 1 == @direction_symbols.length
          @direction_symbol = @direction_symbols[ 0 ]
          __express_for_one_direction
        else
          __express_for_multiple_directions
        end
      end

      # ~

      def __express_for_multiple_directions

        __express_what_is_missing_for_multiple_directions_as_a_line
        __express_what_can_be_used_to_supply_the_missing_directions_as_a_line
      end

      def __express_what_can_be_used_to_supply_the_missing_directions_as_a_line

        h = {}
        @direction_symbols.each do |sym|
          @parameter_symbols_via_direction.fetch( sym ).each do |sym_|
            h[ sym_ ] = true
          end
        end
        buffer = "use "
        @_current_expression_agent.calculate do
          simple_inflection do
            oxford_join buffer, Scanner_[ h.keys ], ' and/or ' do |sym|
              prim sym
            end
          end
        end
        @_current_line_yielder << buffer
      end

      def __express_what_is_missing_for_multiple_directions_as_a_line

        buffer = "missing required "
        _these = Scanner_[ @direction_symbols ]
        @_current_expression_agent.calculate do
          simple_inflection do
            oxford_join buffer, _these do |sym|
              sym.id2name  # this works just because they're each one word
            end
          end
        end
        buffer << "-related arguments"
        @_current_line_yielder << buffer
      end

      # ~

      def __express_for_one_direction

        self._CHANGED__near_use_of_this_method_called_array__

        @_current_line_yielder << "needed exactly 1 #{ @direction_symbol }#{
          }-related argument, had #{ _array.length }#{ __say_extra_for_one_direction }"
      end

      def __say_extra_for_one_direction
        if _array.length.nonzero?
          __say_extra_when_several
        end
      end

      def __say_extra_when_several

        buffer = " (" ; me = self

        @_current_expression_agent.simple_inflection do

          _scn = No_deps_[]::Scanner_via_Array.new me._array do |qkn|
            prim qkn.association.name_symbol
          end

          oxford_join buffer, _scn, ', '
        end
        buffer << ")"
      end

      def _array
        @array_of_qualifieds_that_provide_such_a_value
      end
    end

    # ==

    ByteStreamClass_via_Direction = -> do

      these = {
        input: :UpstreamReference,
        hereput: :UpstreamReference,  # meh this is :#microtheme1
        output: :DownstreamReference,
      }

      -> direction_sym do
        _const = these.fetch direction_sym
        Home_.lib_.basic::ByteStream.const_get _const, false
      end
    end.call

    NO_ = false
    YES_ = true

    # ==
    # ==
  end
end
# #history: broke out of what is currently "common associations" and rewritten
