module Skylab::SubTree

  class API::Actions::My_Tree

    class Expression_Agent_

      def calculate blk
        instance_exec( & blk )
      end

    private

      # fun = Headless::NLP::EN::Minitesimal::FUN

      Headless::SubClient::EN_FUN.each do |m, p|
        define_method m, &p
      end

      def par i
        "<#{ Hak_lbl_[ i ] }>"
      end
      Hak_lbl_ = Face::API::Normalizer_::Hack_label_

    end

    EXPRESSION_AGENT_ = Expression_Agent_.new
  end
end
