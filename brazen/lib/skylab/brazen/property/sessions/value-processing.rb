module Skylab::Brazen

  module Property

    Sessions = ::Module.new

    class Sessions::Value_Processing

      # sadly, the two main other implementations of this (in [ca] and here)
      # were not flexible enough to accomodate this kind of thing ..

      # this accommodates neither soft event handling nor "value collection
      # adapters" although it was written with those in mind for if-ever
      # we need them.

      attr_writer(
        :value_models,
        :value_collection,
      )

      def iambic= x_a
        @upstream = Callback_::Polymorphic_Stream.via_array x_a
        x_a
      end

      def execute

        kp = KEEP_PARSING_
        mz = @value_models
        st = @upstream

        while st.unparsed_exists
          kp = receive_polymorphic_property mz.fetch st.gets_one
          kp or break
        end

        if st.unparsed_exists
          self._EASY
        end

        kp && normalize
      end

      def receive_polymorphic_property mo  # compare to [#047.A]

        case mo.argument_arity

        when :one
          set_value_of_formal_property_ @upstream.gets_one, mo

        when :zero
          set_value_of_formal_property_ true, mo

        when :zero_or_more

          # (the onus is on the front client to do this right)

          set_value_of_formal_property_ @upstream.gets_one, mo

        else
          raise ::NameError, "no: '#{ mo.argument_arity }'"
        end
      end

      def set_value_of_formal_property_ x, mo

        k = mo.name_symbol

        @value_collection.set k, x  # etc

        KEEP_PARSING_
      end

      def normalize  # compare to [#047.B]

        Home_::Normalization::Against_model_stream[
          self,
          @value_models.to_value_stream ]
      end

      def knowness_via_association_ prp

        had = true
        x = @value_collection.fetch prp.name_symbol do
          had = false
        end

        if had
          Callback_::Known_Known[ x ]
        else
          Callback_::KNOWN_UNKNOWN
        end
      end

      def receive_missing_required_properties_array mo_a  # compare to etc

        _ev = Home_::Property.build_missing_required_properties_event mo_a
        raise _ev.to_exception
      end
    end
  end
end
