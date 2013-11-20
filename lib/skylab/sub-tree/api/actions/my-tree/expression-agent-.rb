module Skylab::SubTree

  class API::Actions::My_Tree

    class Expression_Agent__

      alias_method :calculate, :instance_exec

    private

      Headless::SubClient::EN_FUN[ self, :private, %i( and_ both ) ]

      def par i
        "<#{ Hak_lbl__[ i ] }>"
      end
      Hak_lbl__ = Face::API::Normalizer_::Hack_label

    end

    EXPRESSION_AGENT_ = Expression_Agent__.new
  end
end
