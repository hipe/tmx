module Skylab::Tabular

  class Models::FieldObserver

    # -

      def initialize p, x_a

        @_scn = Common_::Polymorphic_Stream.via_array x_a
        @name_symbol = @_scn.gets_one
        begin
          send PARAMETERS___.fetch @_scn.current_token
        end until @_scn.no_unparsed_exists
        remove_instance_variable :@_scn

        @__invocation_definition_proc_ = p
        freeze
      end

      PARAMETERS___ = {
        observe_input_at_offset: :__at_observe_field,
      }

      def __at_observe_field
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

        foi_box = Common_::Box.new
        p_a = []

        keys.each do |k|

          field_observer_definition = h.fetch k

          # calling below is what begins the table-specific observiation

          oi = ObservationInvocation___.new field_observer_definition do |o|
            field_observer_definition.__invocation_definition_proc_.call(
              ObservationDSL___.new o )
          end

          p_a.push oi.__see_typified_mixed_by_

          foi_box.add k, oi
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

        @field_observer_invocation_box = foi_box

        NIL
      end

      def close_all_observation
        # the only way this will work is in cooperation with :#spot-1
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

    EMPTY_A_ = []

    # ==
  end
end
# #born during unification to replace ancient architecture that did similar
