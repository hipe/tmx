module Skylab::Arc

  module Magnetics_::PersistablePrimitiveNameValuePairStream_via_Choices_and_FeatureBranch

    # notes in [#003]

    class << self

      # today this stands as a the #frontier and demonstration of realizing
      # intent-specific customizations

      def via_customization_and_ACS cust_x, acs
        _rw = Home_::Magnetics::FeatureBranch_via_ACS.for_componentesque acs
        via_customization_and_rw_ cust_x, _rw
      end

      def via_customization_and_rw_ customization_x, rw

        o = rw.to_non_operation_node_reference_streamer

        if customization_x
          ___when_customizations customization_x, o
        else

          _st = o.execute

          _st.map_by do |no|
            no.to_qualified_knownness
          end
        end
      end

      def ___when_customizations cust_x, str

        _str_ = Home_::Magnetics_::IntentStreamer_via_NodeReferenceStreamer.via_streamer__ str

        _str3_ = cust_x[ _str_ ]

        _str3_.to_qualified_knownness_stream
      end
    end  # >>
  end
end
