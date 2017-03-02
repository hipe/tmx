module Skylab::Fields

  module Attributes

    class Normalization::JUNE_2015

      # sadly, the two main other implementations of this (in [co] and [br])
      # were not flexible enough to accomodate this kind of thing ..

      # this accommodates neither soft event handling nor "value collection
      # adapters" although it was written with those in mind for if-ever
      # we need them.

      attr_writer(
        :value_models,
        :value_collection,
      )

      def iambic= x_a
        @upstream = Common_::Scanner.via_array x_a
        x_a
      end

      def execute

        kp = KEEP_PARSING_
        mz = @value_models
        st = @upstream

        while st.unparsed_exists
          kp = __parse_via_association mz.fetch st.gets_one
          kp or break
        end

        if st.unparsed_exists
          self._EASY
        end

        kp && normalize
      end

      def __parse_via_association mo  # compare to [#br-047.1] (method)

        case mo.argument_arity

        when :one
          _write_via_association_ @upstream.gets_one, mo

        when :zero
          _write_via_association_ true, mo

        when :zero_or_more

          # (the onus is on the front client to do this right)

          _write_via_association_ @upstream.gets_one, mo

        else
          raise ::NameError, "no: '#{ mo.argument_arity }'"
        end
      end

      def _write_via_association_ x, mo

        k = mo.name_symbol

        @value_collection.set k, x  # etc

        KEEP_PARSING_
      end

      def normalize  # compare to [#br-047.2] (method)

        ::Kernel._GONE__wasnt_covered__037_G__
        Here_::Normalization::OCTOBER_08_2014::Stream.call(
          self,
          @value_models.to_value_stream,
        )
      end

      def _read_knownness_ prp

        had = true
        x = @value_collection.fetch prp.name_symbol do
          had = false
        end

        if had
          Common_::Known_Known[ x ]
        else
          Common_::KNOWN_UNKNOWN
        end
      end

      def _receive_missing_required_associations_ mo_a  # compare to etc

        _ev = Home_.lib_.fields::Events::Missing.for_attributes mo_a

        raise _ev.to_exception
      end
    end
  end
end
