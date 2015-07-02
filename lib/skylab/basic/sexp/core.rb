module Skylab::Basic

  class Sexp < ::Array  # (apologies to zenspider)

    # (NOTE: this is *ancient* - here only to support legacies for now)

    class << self

      def members
        if const_defined? :MEMBER_I_A__, true
          self::MEMBER_I_A__
        end
      end

      def stream_via * a
        if a.length.zero?
          Sexp_::Stream
        else
          Sexp_::Stream.new( * a )
        end
      end
    end  # >>

    def members
      self.class.members
    end

    def symbol_i  # symbol as in grammar symbol
      first
    end

    def has_content  # so you don't have to unparse the whole structure
      d = 1 ; len = length
      while d < len
        x = self[ d ]
        r = if x.respond_to? :has_content
          x.has_content
        else
          x.respond_to? :ascii_only? or fail "no - #{ x.class }"
          x.length.nonzero?
        end
        r and break
        d += 1
      end
      r
    end

    def unparse
      sio = Home_.lib_.string_IO
      unparse_to sio
      sio.string
    end

    def unparse_to sio
      d = 0 ; last = length - 1
      while d < last
        x = fetch( d += 1 )
        if x.respond_to? :unparse_to
          x.unparse_to sio
        else
          sio.write x
        end
      end ; nil
    end

    def children sym, & p

      produce_scan_for( sym ).each( & p )
    end

    def child sym

      via_scan_calculate_for sym do | st |
        st.gets
      end
    end

    def rchild sym

      via_scan_calculate_for sym do | st |
        st.last
      end
    end

    def produce_scan_for sym

      Sexp_::Stream.new self, sym
    end

    def via_scan_calculate & p

      Sexp_::Stream.instance_session do | st |
        st.set_identity self
        p[ st ]
      end
    end

    def via_scan_calculate_for sym, & p

      Sexp_::Stream.instance_session do | st |
        st.set_identity self, sym
        p[ st ]
      end
    end

    Sexp_ = self
  end
end
