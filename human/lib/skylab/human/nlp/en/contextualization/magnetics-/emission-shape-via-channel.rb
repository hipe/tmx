module Skylab::Human

  class NLP::EN::Contextualization

      # (this is near a solution for #[#co-046] emission handling pattern)

    module Magnetics_::Emission_Shape_via_Channel ; class << self

      def via_magnetic_parameter_store ps

        if :expression == ps.channel[1]  # #[#br-023]. [sli] has 1-item channels
          :Is_Of_Expression
        else
          :Is_Of_Event
        end
      end
      alias_method :[], :via_magnetic_parameter_store
    end ; end
  end
end
# #history: broke out of "expression via emission"
