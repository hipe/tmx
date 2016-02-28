module Skylab::Human

  module NLP::EN::Sexp

    class << self

      def say * sexp
        express_into "", sexp
      end

      def express_into y, sexp
        _expression_session_for_sexp( sexp ).express_into y
      end

      def expression_session_for * sexp
        _expression_session_for_sexp sexp
      end

      def _expression_session_for_sexp sexp
        send sexp.first, sexp  # ..
      end

    private

      def list sexp
        Expression_Sessions::List.via_sexp__ sexp
      end
    end  # >>

    EN_ = NLP::EN
    Autoloader_[ Expression_Sessions = ::Module.new ]
    Here_ = self
  end
end
