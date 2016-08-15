module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::Trilean_via_Channel ; class << self

      def via_magnetic_parameter_store ps
        __via_channel ps.channel
      end

      alias_method :[], :via_magnetic_parameter_store

      def __via_channel channel
        VALUES___.fetch channel.fetch 0
      end

      VALUES___ = {
        error: false,
        info: nil,
      }
    end ; end
  end
end
# #history: broke out "string array via [..]" (before that was in "transition")
