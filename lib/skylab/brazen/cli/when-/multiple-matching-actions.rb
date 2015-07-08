module Skylab::Brazen

  class CLI

    class When_::Multiple_Matching_Actions < As_Bound_Call_

      def initialize adapter_a, token, help_renderer

        @a = adapter_a
        @help_renderer = help_renderer
        @token = token
      end

      def produce_result

        hr = @help_renderer

        _ev = Home_::Property.build_ambiguous_property_event(
          @a, @token, :action )

        _ev.express_into_under hr.y, hr.expression_agent

        hr.output_invite_to_general_help

        GENERIC_ERROR
      end
    end
  end
end

