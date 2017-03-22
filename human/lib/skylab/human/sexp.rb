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

        st = Common_::Scanner.via_array sx
        _const = Const_via_tokens_special_[ st ]
        _cls = Expression_Sessions.const_get _const, false
        _cls.expression_via_sexp_stream_ st
      end
    end  # >>

    # ==

    # :weezy_deezy_through_skeezy => :Weezy_Deezy_through_Skeezy

    cache = ::Hash.new do |h, k|

      s = k.id2name

      if s.include? UNDERSCORE_
        const = Const_via_Tokens_._via_token_array s.split UNDERSCORE_
      else
        const = Ucfirst__[ s ].intern
      end

      h[ k ] = const
      const
    end

    Const_via_tokens_special_ = -> st do  # 1x

      a = [ cache[ st.gets_one ] ]

      if st.unparsed_exists && :through == st.head_as_is
        a.push st.gets_one
        a.push cache[ st.gets_one ]
      end

      a.join UNDERSCORE_
    end

    # ==

    class Const_via_Tokens_

      # being that these are considered "magnetics", this parser should move
      # to the post-contemporaneous [ta]. at writing we tried to leverage
      # that one, but the syntax was different enough that this was warranted.

      class << self

        def via_head head
          _via_token_array head.split DASH_
        end

        def _via_token_array s_a
          _st = Common_::Scanner.via_array s_a
          new( _st ).execute
        end
      end  # >>

      def initialize st
        @_result_pieces = []
        @_stream = st
      end

      def execute
        if __token_is_head_keyword
          _joiney_joiney
        else
          _joiney_joiney
        end
        __finish
      end

      def __finish
        @_result_pieces.join( UNDERSCORE_ ).intern
      end

      def _joiney_joiney

        _one_business_part
        until @_stream.no_unparsed_exists
          __one_keyword
          _one_business_part
        end
        NIL
      end

      def __one_keyword
        _is_keyword || fail
        @_result_pieces.push @_stream.gets_one
        NIL
      end

      def _one_business_part

        @_business_buffer = ""

        __must_not_be_keyword
        _accept_business_token
        until @_stream.no_unparsed_exists || _is_keyword
          _accept_business_token
        end

        @_result_pieces.push @_business_buffer

        NIL
      end

      def __must_not_be_keyword
        _is_keyword && fail
      end

      def _accept_business_token
        _s = @_stream.gets_one
        @_business_buffer.concat Ucfirst__[ _s ]
        NIL
      end

      def _is_keyword
        KW___[ @_stream.head_as_is ]
      end

      KW___ = {
        'and' => true,
        'of' => true,
        'through' => true,
      }

      def __token_is_head_keyword
        if THE_ONLY_HEAD_KEYWORD___ == @_stream.head_as_is
          @_stream.advance_one
          @_result_pieces.push 'When'
          ACHIEVED_
        end
      end

      THE_ONLY_HEAD_KEYWORD___ = 'when'
    end

    # ==

    Ucfirst__ = -> s do
      "#{ s[ 0, 1 ].upcase }#{ s[ 1 .. -1 ] }"
    end

    # ==

    class Idea_Argument_Adapter_

      undef_method :to_s

      def initialize & edit_p
        # (hi.)
        instance_exec( & edit_p )
      end
    end

    # ==

    Autoloader_[ Expression_Sessions = ::Module.new ]
    DASH_ = '-'
    Here_ = self
  end
end
