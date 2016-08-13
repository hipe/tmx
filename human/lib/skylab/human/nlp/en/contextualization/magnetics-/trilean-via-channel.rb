module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::Trilean_via_Channel ; class << self

      def into_via_magnetic_parameter_store ps

        ps.trilean = call ps.channel
        NIL_
      end

      def call channel
        VALUES___.fetch channel.fetch 0
      end
      alias_method :[], :call

      VALUES___ = {
        error: false,
        info: nil,
      }
    end ; end
  end
end
# #history: broke out "string array via [..]" (before that was in "transition")
