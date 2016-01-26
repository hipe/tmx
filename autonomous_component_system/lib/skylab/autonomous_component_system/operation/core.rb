module Skylab::Autonomous_Component_System

  module Operation

    class Parsing_Session_

      class << self

        def call_via_parsing_session o
          via_parsing_session( o ).execute
        end

        def via_parsing_session o
          new.init_via_parsing_session_ o
        end

        private :new
      end  # >>

      def init_via_parsing_session_ o, & pp

        @ACS = o.ACS
        @argument_stream = o.argument_stream

        @pp_ = if pp
         pp
        else
          o.pp_
        end

        self
      end

      # -- for sub-clients

      attr_reader(
        :ACS,
        :argument_stream,
        :pp_,
      )
    end

    Request_for_Deliverable_ = -> * a { a }

    Here_ = self
  end
end
