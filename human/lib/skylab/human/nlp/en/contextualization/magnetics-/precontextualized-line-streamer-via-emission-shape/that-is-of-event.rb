module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::Precontextualized_Line_Stream_via_Emission_that_Is_Event ; class << self

      def via_magnetic_parameter_store ps

        # flush all raw lines early to make life easier (see sibling).

        lines = []

        _y = ::Enumerator::Yielder.new do |s|
          lines.push Plus_newline_if_necessary_[ s ]
        end

        ev = ps.event

        ps.expression_agent.calculate _y, ev, & ev.message_proc

        Common_::Stream.via_nonsparse_array lines
      end

      alias_method :[], :via_magnetic_parameter_store
    end ; end
  end
end
# #history: broke out of "expression via emission"
