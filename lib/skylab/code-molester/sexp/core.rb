module Skylab::CodeMolester

  class Sexp < ::Array  # (apologies to zenspider)

    class << self
      def members
        if const_defined? :MEMBER_I_A__, true
          self::MEMBER_I_A__
        end
      end

      def scan * a
        if a.length.zero?
          Sexp_::Scan
        else
          Sexp_::Scan.new( * a )
        end
      end
    end

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
      sio = CM_::Library_::StringIO.new
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

    def children i, & p
      produce_scan_for( i ).each( & p )
    end

    def child i
      via_scan_calculate_for i do |scn|
        scn.gets
      end
    end

    def rchild i
      via_scan_calculate_for i do |scn|
        scn.last
      end
    end

    def produce_scan_for i
      Sexp_::Scan.new self, i
    end

    def via_scan_calculate & p
      Sexp_::Scan.with_instance do |scn|
        scn.set_identity self
        p[ scn ]
      end
    end

    def via_scan_calculate_for i, & p
      Sexp_::Scan.with_instance do |scn|
        scn.set_identity self, i
        p[ scn ]
      end
    end

    Sexp_ = self
  end
end
