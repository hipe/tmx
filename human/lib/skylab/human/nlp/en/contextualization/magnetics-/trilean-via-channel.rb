module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::Trilean_via_Channel ; class << self

      def via_magnetic_parameter_store ps

        # (the client could have set the trilean explicitly, which overrides this)

        if ps._magnetic_value_is_known_ :trilean
          ps.trilean
        else
          __via_channel ps.channel
        end
      end

      alias_method :[], :via_magnetic_parameter_store

      def __via_channel channel
        VALUES___.fetch channel.fetch 0
      end

      VALUES___ = {
        error: false,
        info: nil,
        success: true,  #c15n-testpoint-1
      }
    end ; end
  end
end
# #history: broke out "string array via [..]" (before that was in "transition")
