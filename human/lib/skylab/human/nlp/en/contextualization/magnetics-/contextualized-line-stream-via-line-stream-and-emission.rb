module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Contextualized_Line_Stream_via_Line_Stream_and_Emission

      class << self
        def via_magnetic_parameter_store ps
          new( ps ).execute
        end
        private :new
      end  # >>

      def initialize ps

        @_parameter_store = ps
        @line_stream = ps.line_stream
        self
      end

      def execute

        stmr = Home_::Sexp::Expression_Sessions::List_through_Eventing::Simple.begin

        stmr.on_first = -> s do

          o = Magnetics_::Contextualized_Line_via_Line_and_Emission.begin

          ps = @_parameter_store
          o.line = s
          o.trilean = ps.trilean
          o.event = ps.event
          o.parameter_store = ps
          o.execute
        end

        stmr.on_subsequent = IDENTITY_

        stmr.to_stream_around @line_stream
      end
    end
  end
end
# #history: broke out of "expression via emission"
