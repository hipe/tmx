module Skylab::Tabular

  class Models::FieldObserver

    # -

      def initialize p, x_a, dereference_common_implementation

        @_user_provided_block = p
        @_scn = Common_::Polymorphic_Stream.via_array x_a
        @_dereference_common_implementation = dereference_common_implementation

        @name_symbol = @_scn.gets_one

        begin
          send PARAMETERS___.fetch @_scn.current_token
        end until @_scn.no_unparsed_exists

        remove_instance_variable :@_dereference_common_implementation
        remove_instance_variable :@_scn

        _p = remove_instance_variable :@_user_provided_block
        _p ||= remove_instance_variable :@__proc_for_block_from_common_etc
        @__invocation_definition_proc_ = _p

        freeze
      end

      PARAMETERS___ = {
        do_this: :__at_do_this,
        for_input_at_offset: :__at_input_offset,
      }

      def __at_do_this
        @_scn.advance_one
        _const = @_scn.current_token
        _block = @_dereference_common_implementation[ _const ]
        if @_user_provided_block
          self._COVER_ME__you_cant_pass_a_block_and_indicate_a_common_implementation__  # #todo
        end
        @__proc_for_block_from_common_etc = _block
        @_scn.advance_one
      end

      def __at_input_offset
        @_scn.advance_one
        @input_tuple_offset = @_scn.gets_one ; nil
      end

      attr_reader(
        :input_tuple_offset,
        :__invocation_definition_proc_,
        :name_symbol,
      )
    # -

    # ==

    class Collection

      def initialize

        @_box = Common_::Box.new
        @_keys_via_input_tuple_offset = []
      end

      def << fo
        @_box.add fo.name_symbol, fo
        ( ( @_keys_via_input_tuple_offset ||= [] )[ fo.input_tuple_offset ] ||= [] ).push fo.name_symbol
        self
      end

      def at_index_subtract_N_items d, n
        @_keys_via_input_tuple_offset[ d, n ] = EMPTY_A_
        NIL
      end

      def freeze
        @_box.freeze
        @_keys_via_input_tuple_offset.freeze
        super
      end

      def build_controller
        FieldObserversController___.new @_keys_via_input_tuple_offset, @_box
      end
    end

    # ==

    class FieldObserversController___

      def initialize keys_via_input_tuple_offset, box

        @field_observers_array = []
        @field_observer_invocation_box = Common_::Box.new

        h = box.h_
        keys_via_input_tuple_offset.length.times do |d|

          keys = keys_via_input_tuple_offset.fetch d
          keys || next

          __populate_observers_for_column keys, h, d
        end

        @field_observer_invocation_box.freeze
        @field_observation_is_on = true
      end

      def __populate_observers_for_column keys, h, col_d

        p_a = []

        keys.each do |k|

          field_observer_definition = h.fetch k

          # calling below is what begins the table-specific observiation

          oi = ObservationInvocation___.new field_observer_definition do |o|
            field_observer_definition.__invocation_definition_proc_.call(
              ObservationDSL___.new o )
          end

          p_a.push oi.__see_typified_mixed_by_

          @field_observer_invocation_box.add k, oi
        end

        _this_proc = if 1 == keys.length
          p_a.fetch 0
        else
          -> typi do
            p_a.each do |p|
              p[ typi ]
            end
            NIL
          end
        end

        @field_observers_array[ col_d ] = _this_proc

        NIL
      end

      def close_all_observation

        # the only way this will work is if where the array of observers
        # is read, it is always read passively and read anew on each row :#spot-1

        @field_observers_array.clear
        @field_observers_array.freeze
        @field_observation_is_on = false
        freeze
        NIL
      end

      def read_observer sym

        _guy = @field_observer_invocation_box.fetch sym
        _guy.__read_
      end

      attr_reader(
        :field_observation_is_on,
        :field_observer_invocation_box,
        :field_observers_array,
      )
    end

    # ==

    class ObservationDSL___

      def initialize oi
        @_observation_invocation = oi
      end

      def on_typified_mixed & p
        @_observation_invocation.__write_see_typified_mixed_by_ p ; nil
      end

      def read_observer_by & p
        @_observation_invocation.__write_retrieve_by_ p ; nil
      end
    end

    # ==

    class ObservationInvocation___

      def initialize obs_def
        @_observation_definition = obs_def
        yield self
        freeze
      end

      def __write_see_typified_mixed_by_ p
        @__see_typified_mixed_by_ = p
      end

      def __write_retrieve_by_ p
        @__retrieve_by = p
      end

      def __read_
        @__retrieve_by.call
      end

      attr_reader(
        :__see_typified_mixed_by_,
      )
    end

    # ==
  end
end
# #born during unification to replace ancient architecture that did similar
