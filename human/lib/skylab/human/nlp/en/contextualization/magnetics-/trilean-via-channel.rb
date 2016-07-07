module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::Trilean_via_Channel ; class << self

      def into_via_magnetic_parameter_store ps
        send CHANNEL___.fetch( ps.channel.fetch( 0 ) ), ps
        NIL_
      end

      CHANNEL___ = {
        info: :__info,
        error: :__error,
      }

      def __error ps
        ps.trilean = false
      end

      def __info ps
        ps.trilean = nil
      end
    end ; end
  end
end
# #history: broke out "string array via [..]" (before that was in "transition")
