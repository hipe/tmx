module Skylab::Autonomous_Component_System

  module For_Serialization  # notes in [#003]

    # -
      # today this stands as a the #frontier and demonstration of realizing
      # intent-specific customizations

      when_cust = nil
      To_stream = -> cust_x, acs do

        o = Home_::Reflection::To_node_stream_via_inference.new acs

        o.on_operation = MONADIC_EMPTINESS_  # operation nodes don't get serialized

        st = o.execute

        if cust_x
          when_cust[ cust_x, st ]
        else
          st.map_by do |no|
            no.qualified_knownness
          end
        end
      end

      when_cust = -> cust_x, st do

        _sm = cust_x[ Home_::Intent::Streamer.new( st ) ]

        _sm.to_qualified_knownness_stream
      end
    # -
  end
end
