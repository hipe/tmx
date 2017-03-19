module Skylab::Fields

  module CommonMetaAssociations::Enum

    class Build_extra_value_event  # 1x

      # (a session interface to build an event so..)

      class << self

        def _call x, x_a, nf
          o = new
          o.invalid_value = x
          o.valid_collection = x_a
          o.property_name = nf
          o.execute
        end

        alias_method :[], :_call
        alias_method :call, :_call
      end  # >>

      def initialize
        @adjective = INVALID___
        @event_name_symbol = :invalid_property_value
        @exception_class_by = -> { Home_::ArgumentError }
        @predicate_string = nil
        @valid_value_mapper_from = nil
      end

      INVALID___ = 'invalid'

      attr_writer(
        :adjective,
        :invalid_value,
        :valid_collection,
        :predicate_string,
        :property_name,
        :event_name_symbol,
        :exception_class_by,
        :valid_value_mapper_from,
      )

      def execute

        _ = Here_::Extra_Value_Event.inline_with__EXPERIMENTAL__(
          @event_name_symbol,
          :x, @invalid_value,
          :predicate_string, @predicate_string,
          :property_name, @property_name,
          :enum_value_argument_scannerable, @valid_collection,
          :valid_value_mapper_from, @valid_value_mapper_from,
          :adjective, @adjective,
          :exception_class_by, @exception_class_by,
        )
        _
      end
    end
  end
end
