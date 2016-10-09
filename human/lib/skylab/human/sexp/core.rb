module Skylab::Human

  module Sexp

    class << self

      def express * sx
        expression_session_via_sexp sx
      end

      def expression_session_for * sx
        expression_session_via_sexp sx
      end

      def expression_session_via_sexp sx

        st = Common_::Polymorphic_Stream.via_array sx
        _const = Parse_expression_session_name[ st ]
        _cls = Expression_Sessions.const_get _const, false
        _cls.expression_via_sexp_stream_ st
      end
    end  # >>

    # --

    # :weezy_deezy_through_skeezy => :Weezy_Deezy_through_Skeezy

    ucfirst = -> s do
      "#{ s[ 0, 1 ].upcase }#{ s[ 1 .. -1 ] }"
    end

    prep = { 'of' => true, 'through' => true }

    cache = ::Hash.new do |h, k|

      s = k.id2name

      x = if s.include? UNDERSCORE_

        s.split( UNDERSCORE_ ).map do |s_|
          prep[ s_ ] ? s_ : ucfirst[ s_ ]
        end.join( EMPTY_S_ ).intern

      else
        ucfirst[ s ].intern
      end

      h[ k ] = x
      x
    end

    Parse_expression_session_name = -> st do

      a = [ cache[ st.gets_one ] ]

      if st.unparsed_exists && :through == st.current_token
        a.push st.gets_one
        a.push cache[ st.gets_one ]
      end

      a.join UNDERSCORE_
    end

    # --

    class Idea_Argument_Adapter_

      undef_method :to_s

      def initialize & edit_p
        # (hi.)
        instance_exec( & edit_p )
      end
    end

    Autoloader_[ Expression_Sessions = ::Module.new ]
    Here_ = self
  end
end
