module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::Line_Stream_via_Expression_Proc_and_Channel

      # (this is near a solution for #[#co-046] emission handling pattern)
      # (side-effect is to resolve a trilean (shh))

      class << self

        def via_magnetic_parameter_store ps

          if :expression == ps.channel[ 1 ]  # #[#br-023]. [sli] has 1-item channels

            ps.write_magnetic_value NOTHING_, :event
            Magnetics_::Line_Stream_via_Expression_Emission.via_magnetic_parameter_store ps
          else
            Magnetics_::Line_Stream_via_Event.via_magnetic_parameter_store ps
          end
        end
      end
    end
  end
end
# #history: broke out of "expression via emission"
