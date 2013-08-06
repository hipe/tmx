module Skylab::SubTree

  class API::Actions::My_Tree

    class Expression_Agent_

      alias_method :calculate, :instance_exec

    private

      Headless::SubClient::EN_FUN.each do |m, p|
        define_method m, &p
      end

      def par i
        "<#{ Hak_lbl_[ i ] }>"
      end
      Hak_lbl_ = Face::API::Normalizer_::Hack_label

    end

    EXPRESSION_AGENT_ = Expression_Agent_.new
  end
end
