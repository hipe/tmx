module Skylab::FileMetrics

  module Services::Table
    # not really table - just support for table
  end

  class Services::Table::Manifold < MetaHell::Formal::Box

    # `Table::Manifold` -
    # name may change - the ordered collection of metadata
    # about each field. Manages per-field (by symbolic name) the
    # rendering of the header cel (typically in the first row)
    # and the rendering of each cel.

    attr_accessor :hdr

    def the_rest sym_a
      if @the_rest
        raise ::ArgumentError, "won't clobber existing `the_rest`"
      else
        @the_rest = sym_a
      end
      nil
    end

    def build_header_row
      @order.map(& method( :header ) )
    end

    def header sym
      fld = @hash[ sym ]
      if fld && fld.header
        fld.header
      elsif @hdr
        @hdr[ sym ]
      else
        sym
      end
    end

    def build_row node
      @order.map do |m|
        render_cel m, node[ m ]
      end
    end

    def build_summary_row node
      @order.map do |m|
        node[ m ]  # hm..
      end
    end

    def render_cel sym, x
      fld = @hash[ sym ]
      if fld
        if fld.filter
          res = fld.filter[ x ]
        elsif fld.is_autonomous
          res = x  # it is a proxy or something, passthru
        else
          res = "#{ x }"  # le meh
        end
      end
      res
    end

  protected

    def initialize sexp
      super( & nil )
      @the_rest = @hdr = nil
      op_h = {
        :fields => -> { process_fields sexp }
      }
      while sexp.length.nonzero?
        op_h.fetch( sexp.shift ).call
      end
      yield self if block_given?
      name, node = defectch -> k, v { v.is_rest }, -> { }
      name && @the_rest and add_the_rest
      arr = reduce [] do |ar, (nm, fld)|
        ar << nm if fld.is_noop || fld.is_rest
        ar
      end
      delete_multiple arr if arr.length.nonzero?
      nil
    end

    def process_fields sexp
      while sexp.length.nonzero?
        process_field( * sexp.shift )
      end
    end

    Field_ = ::Struct.new :header, :filter, :is_autonomous, :is_rest, :is_noop

    def process_field sym, x, *a
      if @hash.key? sym
        fail "merge is not implemented - #{ sym }"
      else
        fld = Field_.new
        a.unshift x
        h = ( ::Hash === a.last ) ? a.pop.dup : { }
        a.each { |k| h[ :"is_#{ k }" ] = true }
        h.each { |k, v| fld[ k ] = v }
        @order << sym  # include `is_noop` for now, process after `rest`
        @hash[ sym ] = fld
      end
      nil
    end

    def add_the_rest
      # BE CAREFUL - box hacking
      xtra_a = @the_rest - @order ; @the_rest = nil
      if xtra_a.length.nonzero?
        idx = @order.index name
        @order[ idx, 1 ] = xtra_a
        xtra_a.each do |k|
          @hash[k] = nil
        end
      end
      nil
    end
  end
end
