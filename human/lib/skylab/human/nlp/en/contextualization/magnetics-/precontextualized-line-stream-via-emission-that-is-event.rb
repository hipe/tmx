module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Line_Stream_via_Event

      class << self
        def via_magnetic_parameter_store ps
          new( ps ).execute
        end
        private :new
      end  # >>

      def initialize ps
        @emission_proc = ps.emission_proc
        @expression_agent = ps.expression_agent
        @_parameter_store = ps
      end

      def execute

        wrapped_event = @emission_proc.call
        ev = wrapped_event.to_event

        lines = []
        _y = ::Enumerator::Yielder.new do |s|
          lines.push Plus_newline_if_necessary_[ s ]
        end

        @expression_agent.calculate _y, ev, & ev.message_proc

        if ev.has_member :ok
          _trilean_x = ev.ok
        end

        @_parameter_store.write_magnetic_value _trilean_x, :trilean
        @_parameter_store.write_magnetic_value wrapped_event, :event

        Common_::Stream.via_nonsparse_array lines
      end
    end
  end
end
# #history: broke out of "expression via emission"
