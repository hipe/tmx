module Skylab::FileMetrics

  module Services::Table
    # not really table - just support for table
  end

  class Services::Table::Manifold < MetaHell::Formal::Box

    # name may change - the ordered collection of metadata
    # about each field.  Manages per field (by symbolic name) the
    # rendering of the header cel (typically in the first row),
    # and the rendering of each cel.

    attr_accessor :hdr

    def add_fields sym_a
      ( sym_a - @order ).each { |k| @order << k ; @hash[k] = nil }  # CAREFUL
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

    def build_row obj
      @order.map { |k| render_cel k, obj.send( k ) }
    end

    def render_cel sym, x
      fld = @hash[ sym ]
      dflt = res = nil
      if fld
        if fld.filter
          res = fld.filter[ x ]
        elsif fld.is_autonomous
          res = x  # it is a proxy or something, passthru
        else
          dflt = true
        end
      end
      if dflt
        res = "#{ x }"  # le meh
      end
      res
    end

  protected

    def initialize sexp
      super( & nil )
      @hdr = nil
      op_h = {
        :fields => -> { process_fields sexp }
      }
      while sexp.length.nonzero?
        op_h.fetch( sexp.shift ).call
      end
      yield self if block_given?
      nil
    end

    def process_fields sexp
      while sexp.length.nonzero?
        process_field( * sexp.shift )
      end
    end

    Field_ = ::Struct.new :header, :filter, :is_autonomous

    def process_field sym, x, *a
      if @hash.key? sym
        fail "merge is not implemented - #{ sym }"
      else
        fld = Field_.new
        a.unshift x
        h = ( ::Hash === a.last ) ? a.pop.dup : { }
        a.each { |k| h[ :"is_#{ k }" ] = true }
        h.each { |k, v| fld[ k ] = v }
        @order << sym
        @hash[ sym ] = fld
      end
      nil
    end
  end
end
