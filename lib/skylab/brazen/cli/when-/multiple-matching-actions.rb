module Skylab::Brazen

  class CLI

    class When_::Multiple_Matching_Actions < As_Bound_Call_

      def initialize adapter_a, token, help_renderer

        @a = adapter_a
        @help_renderer = help_renderer
        @token = token
      end

      def produce_result

        o = @help_renderer

        a = @a ; token = @token

        o.express do

          _s_a = a.map do | adapter |
            ick adapter.name.as_slug
          end

          "ambiguous action #{ ick token } - did you mean #{ or_ _s_a }?"
        end

        o.output_invite_to_general_help

        GENERIC_ERROR_
      end
    end
  end
end

