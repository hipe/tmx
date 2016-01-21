module Skylab::Autonomous_Component_System

  module Operation

    class Parsing_Session_

      class << self

        def call_via_parsing_session o
          via_parsing_session( o ).execute
        end

        def via_parsing_session o
          new.___init_via_parsing_session o
        end

        private :new
      end  # >>

      def ___init_via_parsing_session o
        @ACS = o.ACS
        @argument_stream = o.argument_stream
        @pp_ = o.pp_
        self
      end

      # -- for sub-clients

      attr_reader(
        :ACS,
        :argument_stream,
        :pp_,
      )
    end

    Here_ = self
  end
end
