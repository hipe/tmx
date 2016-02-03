module Skylab::Autonomous_Component_System

  module For_Serialization  # notes in [#003]

    module Stream ; class << self

      # today this stands as a the #frontier and demonstration of realizing
      # intent-specific customizations

      def via_customization_and_ACS cust_x, acs
        _rw = Home_::ReaderWriter.for_componentesque acs
        via_customization_and_rw_ cust_x, _rw
      end

      def via_customization_and_rw_ customization_x, rw

        o = rw.to_node_streamer

        o.on_operation = MONADIC_EMPTINESS_  # operation nodes don't get serialized

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

        _str_ = Home_::Intent::Streamer.via_streamer__ str

        _str3_ = cust_x[ _str_ ]

        _str3_.to_qualified_knownness_stream
      end
    end ; end
  end
end
