module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Line_Stream_via_Expression_Emission  # and [see #here]

      class << self
        def via_magnetic_parameter_store ps
          new( ps ).execute
        end
        private :new
      end  # >>

      def initialize ps  # #here

        @channel = ps.channel
        @emission_proc = ps.emission_proc
        @expression_agent = ps.expression_agent
        @_ps = ps
      end

      def execute

        __establish_trilean
        __to_line_stream
      end

      def __to_line_stream

        # (we want all N lines otherwise we would use [#ba-030] "N lines")

        a = []
        _y = ::Enumerator::Yielder.new do |s|
          a << Plus_newline_if_necessary_[ s ]
        end

        @expression_agent.calculate _y, & @emission_proc

        Common_::Stream.via_nonsparse_array a
      end

      def __establish_trilean
        if ! @_ps.magnetic_value_is_known :trilean
          Magnetics_::Trilean_via_Channel.into_via_magnetic_parameter_store @_ps
        end
        NIL_
      end
    end
  end
end
# #history: broke out of "emission via expression"
