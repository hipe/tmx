module Skylab::Human

  module NLP::EN::Sexp

    class << self

      def say * sexp
        express_into "", sexp
      end

      def express_into y, sexp
        expression_session_via_sexp( sexp ).express_into y
      end

      def expression_session_for * sexp
        expression_session_via_sexp sexp
      end

      def expression_session_via_sexp sexp

        st = Callback_::Polymorphic_Stream.via_array sexp

        if :when == st.current_token
          st.advance_one
          ___magnetic_collection.expression_session_via_sexp_stream__ st
        else
          _const = Home_::Sexp::Parse_expression_session_name[ st ]
          _cls = Expression_Sessions.const_get _const, false
          _cls.expression_via_sexp_stream_ st
        end
      end

      def ___magnetic_collection
        @___mc ||= Home_::Sexp::Expression_Collection.
          new_via_multipurpose_module__( EN_::Sexp::Expression_Sessions )
      end
    end  # >>

    EN_ = NLP::EN
    Autoloader_[ Expression_Sessions = ::Module.new ]
    Here_ = self
  end
end
