module Skylab::TanMan

  class DocumentMagnetics_::ByteStreamReference_via_Request < Common_::MagneticBySimpleModel

    # (#spot1.1 is probably required reading to understand this.)

    # given one or both "throughput directions" (input and/or output), solve
    # a single qualified actual parameter for each direction. if exactly one
    # cannot be resolved for each direction unambiguously, fail expressively

    # -

      def initialize
        @__mutex_for_will_solve_for = nil
        super
      end

      def will_solve_for sym
        remove_instance_variable :@__mutex_for_will_solve_for
        @_number_of_directions = 1
        @_solve_for_these_symbols = [ sym ]
        NIL
      end

      attr_writer(
        :qualified_knownness_box,
        :listener,
      )

      # --

      def execute

        __classify_each_association_under_the_directions_it_solves_for

        __for_each_direction do
          __resolve_exactly_one_bytestream_reference_for_this_direction
        end

        __flush_final_result
      end

      # -- D

      def __flush_final_result

        a = remove_instance_variable :@_final_byte_stream_references
        if 1 == @_number_of_directions
          a.fetch 0
        else
          ::Kernel._OKAY
        end
      end

      # -- C

      def __resolve_exactly_one_bytestream_reference_for_this_direction

        if __resolve_exactly_one_qualified_value_for_this_direction
          __resolve_bytestream_reference_via_current_qualified_value
        end
        NIL
      end

      def __resolve_bytestream_reference_via_current_qualified_value

        _qkn = remove_instance_variable :@__current_qualified_value

        _class = ByteStreamClass_via_Direction[ @_current_direction_symbol ]

        id = _class.via_qualified_knownnesses [ _qkn ], & @listener  #  ??

        if id
          @_final_byte_stream_references[ @_current_direction_offset ] = id
        else
          @_ok = false  # assume emitted
        end
        NIL
      end

      # -- B

      def __resolve_exactly_one_qualified_value_for_this_direction
        a = @__name_symbols_via_direction_offset.fetch @_current_direction_offset
        if a
          if 1 == @_number_of_directions
            @__current_qualified_value =
              @qualified_knownness_box.fetch a.fetch 0
          else
            self._SEE_NOTES__have_fun__
          end
        else
          __when_zero_for_this_direction
        end
        @_ok
      end

      def __for_each_direction

        @_ok = true  # (sneak this in here)
        @_final_byte_stream_references = ::Array.new @_number_of_directions

        @_solve_for_these_symbols.each_with_index do |sym, d|
          @_current_direction_symbol = sym
          @_current_direction_offset = d
          yield
          @_ok || break  # (we don't have to short circuit here but we choose to.)
        end
        NIL
      end

      def __when_zero_for_this_direction
        Emit_via_NonOneScenario__.call_by do |o|
          o.array_of_qualifieds_that_provide_such_a_value = EMPTY_A_
          o.direction_symbol = @_current_direction_symbol
          o.listener = @listener
        end
        @_ok = false ; nil
      end

      # -- A

      def __classify_each_association_under_the_directions_it_solves_for

        a = ::Array.new @_number_of_directions

        __each_qualified_knownness do |qkn|

          asc = qkn.association
          tc = asc._throughput_characteristics_
          tc || next
          @_solve_for_these_symbols.each_with_index do |direction_sym, d|
            tc[ direction_sym ] || next
            ( a[ d ] ||= [] ).push asc.name_symbol
          end
        end
        @__name_symbols_via_direction_offset = a.freeze
        NIL
      end

      def __each_qualified_knownness
        @qualified_knownness_box.each_value do |qkn|
          yield qkn
        end
      end
    # -

    # ==

    class Emit_via_NonOneScenario__ < Common_::MagneticBySimpleModel

      attr_writer(
        :array_of_qualifieds_that_provide_such_a_value,
        :direction_symbol,
        :listener,
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
          :direction_symbol, @direction_symbol,
          :array_of_qualifieds_that_provide_such_a_value,
            @array_of_qualifieds_that_provide_such_a_value

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
        @_current_line_yielder << "needed exactly 1 #{ @direction_symbol }#{
          }-related argument, had #{ _array.length }#{ __say_extra }"
      end

      def __say_extra
        if _array.length.zero?
          __say_extra_when_none
        else
          __say_extra_when_several
        end
      end

      def __say_extra_when_none
        self._SEE_NOTES__there_is_a_special_dootily_hah
      end

      def __say_extra_when_several

        buffer = " (" ; me = self

        @_current_expression_agent.simple_inflection do

          _scn = No_deps_[]::Scanner_via_Array me._array do |qkn|
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
        output: :DownstreamReference,
      }

      -> direction_sym do
        _const = these.fetch direction_sym
        Home_.lib_.basic::ByteStream.const_get _const, false
      end
    end.call

    # ==

    No_deps_ = Lazy_.call do
      require 'no-dependencies-zerk'
      ::NoDependenciesZerk
    end

    # ==
    # ==
  end
end
# #history: broke out of what is currently "common associations" and rewritten
