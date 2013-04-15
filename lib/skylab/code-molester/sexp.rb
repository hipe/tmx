module ::Skylab::CodeMolester

  # apologies to zenspider

  class Sexp < ::Array

    # constructor -
    #
    # `def self.[] *a` it is left as-is from parent, but see `Registrar`

    #         ~ readers for core attributes ~

    # `symbol_name` - NOTE no, we do not mean `name_symbol` here.
    #  Here the intended meaning is that of e.g a grammar symbol,
    #  (terminal, nonterminal, etc) (although it could be whatever).

    def symbol_name
      ::Symbol === fetch( 0 ) or fail "sanity"  # #todo - maybe never
      fetch 0
    end

    #         ~ readers for derived attributes ~

    def unparse
      sio = CodeMolester::Services::StringIO.new
      unparse_to sio
      sio.string
    end

    def unparse_to sio
      self[ 1 .. -1 ].each do |x|
        if x.respond_to? :unparse_to
          x.unparse_to sio
        else
          sio.write x.to_s
        end
      end
      nil
    end

    #         ~ readers for children ~

    #         The below method names changes often!

    def child name_sym
      with_scanner_for_symbol name_sym do |scn|
        scn.gets
      end
    end

    def rchild name_sym
      with_scanner_for_symbol name_sym do |scn|
        scn.pos = -1
        scn.rgets
      end
    end

    def select_children name_sym
      children( name_sym ).to_a
    end

    -> do  # `each_child`

      op_h = {
        0 => -> do
          ::Enumerator.new do |y|
            with_scanner do |scn|
              while x = scn.gets
                y << x
              end
            end
          end
        end,
        1 => -> name_sym do
          ::Enumerator.new do |y|
            with_scanner_for_symbol name_sym do |scn|
              while x = scn.gets
                y << x
              end
            end
          end
        end
      }

      define_method :children do |*name_sym, &b|
        ea = instance_exec( * name_sym, & op_h.fetch( name_sym.length ) )
        b ? ea.each( &b ) : ea
      end
    end.call


    #         ~ lower-level access to the underlying scanning ~

    def with_scanner &blk
      Sexp::Scanner_.with_scanner self, &blk
    end

    def with_scanner_for_symbol sym, &blk
      Sexp::Scanner_::Bound.with_symbol_scanner self, sym, &blk
    end

    #         ~ mutators (side-effects) ~

    def remove sexp
      with_scanner do |scn|
        oid = sexp.object_id
        found = nil
        while sxp = scn.gets
          if oid == sxp.object_id
            break( found = sxp )
          end
        end
        if found
          self[ scn.pos, 1 ] = []
          found
        else
          raise "sexp #{ oid } was not an immediate child of this sexp."
        end
      end
    end
  end

  # NOTE this assumes "strict sexps" [#003]

  class Sexp::Scanner_

    # this is not expected to work well if you instantiate it directly

    CodeMolester::Services::Pool.enhance( self ).with :with_instance

    def self.with_scanner sexp, &blk
      with_instance do |scn|
        scn.set_sexp sexp
        blk[ scn ]
      end
    end

    # ( for internal fly-weighting use only )
    def set_sexp sexp
      tgt_sym = gets = nil
      FUN.build_scan_functions[ sexp,
        -> x do
          if x.respond_to? :each_index
            ! tgt_sym || tgt_sym == x.fetch( 0 )
          end
        end,
        -> gts do
          gets = gts
        end,
        -> rpos do
          @pos = rpos
        end
      ]
      @gets = -> do
        tgt_sym &&= nil
        gets[ ]
      end
      @scan = -> search_symbol do
        tgt_sym = search_symbol
        gets[ ]
      end
    end

    def scan search_symbol
      @scan[ search_symbol ]
    end

    def gets
      @gets[ ]
    end

    def pos
      @pos[ ]
    end

    def clear_for_pool
      @gets = @scan = @pos = nil
    end
  end

  class Sexp::Scanner_::Bound  # Bound to a search method

    Services::Pool.enhance( self ).with :with_instance

    def self.with_symbol_scanner sexp, search_symbol, &blk
      with_instance do |scn|
        scn.set_as_symbol_scanner sexp, search_symbol
        blk[ scn ]
      end
    end

    # internal use (as flyweight) only!
    # (ironicly, this might be slow and we could speed it up by
    # making a reversible scanner only conditionally. but let's first
    # see how slow it actually is -- it may be neglibible. #todo)

    def set_as_symbol_scanner sexp, bound_symbol
      rinc = winc = gets = nil

      forward = true
      fwd = -> do
        winc[ 1 ]
        forward = true
      end
      Sexp::Scanner_::FUN.build_scan_functions[ sexp,
        -> x do
          x.respond_to? :each_index and bound_symbol == x.fetch( 0 )
        end,
        -> g do
          gets = g
          @gets = -> do
            forward or fwd[ ]
            gets[ ]
          end
        end,
        -> rp do
          @pos = rp
        end,
        -> wp { @wpos = wp }, -> ri { rinc }, -> wi { winc = wi }
      ]

      @rgets = -> do
        if forward
          winc[ -1 ]
          forward = false
        end
        gets[ ]
      end

      nil
    end

    def gets
      @gets.call
    end

    def pos  # used in removing elements
      @pos.call
    end

    def pos= x
      @wpos[ x ]
      x
    end

    def rgets
      @rgets.call
    end

    def clear_for_pool
      @gets = @pos = nil
      @wpos = @rgets = nil
    end
  end

  Sexp::Scanner_::FUN = -> do

    o = { }

    # `build_scan_functions` - a very internal function, and for fun a
    # very experimental one, that in one shot builds multiple functions
    # used in scanning. we come from a planet with no ivars.

    build_position_functions = nil
    o[:build_scan_functions] = -> sexp, match, gets_, *rpos_wpos_rinc_winc do
      pgets = nil
      build_position_functions[ sexp, -> p { pgets = p }, *rpos_wpos_rinc_winc ]
      pos = nil
      gets_[ -> do
        res = nil
        while pos = pgets[]
          match[ x = sexp.fetch( pos ) ] and break( res = x )
        end
        res
      end ]

      nil
    end

    # `build_position_functions`
    # ( we insisted on making one central function for scanning, including
    # reverse scanning. the result somehow ended up 5x as complex as if
    # we did not support reverse scanning. )

    build_position_functions = -> sexp, gets_, *rpos_wpos_rinc_winc do
      read_pos, write_pos, read_increment, write_increment = rpos_wpos_rinc_winc
      low_pos = 1  # beginning position is always 1 per [#003]
      high_pos = sexp.length - 1  # can have negative width
      hot = inc = bound = beg_pos = end_pos = now_pos = nil
      rbound = nil
      fbound = -> { now_pos <= end_pos }
      winc = -> increment do
        inc = increment
        inc.zero? and fail "test me - this might be ok"
        if inc > 0
          bound = fbound
          beg_pos = low_pos ; end_pos = high_pos
        else
          bound = ( rbound ||= -> { now_pos >= end_pos } )
          beg_pos = high_pos ; end_pos = low_pos
        end
        hot = true
        nil
      end
      winc[ 1 ]
      read_increment[ -> { inc } ] if read_increment
      write_increment[ winc ] if write_increment
      gets_[ -> do
        if hot
          if now_pos
            now_pos += inc
          else
            now_pos = beg_pos
          end
          if bound[]
            now_pos
          else
            hot = now_pos = nil
          end
        end
      end ]
      read_pos[ -> { now_pos } ] if read_pos
      write_pos[ -> x do
        if x < 0
          x = high_pos + 1 + x
          x = 1 if x < 1  # because of [#003]
        end
        if x > 0
          now_pos = [ x, high_pos ].min
        else
          fail "not on sexps you can't - #{ x }"
        end
      end ] if write_pos
      nil
    end

    ::Struct.new( * o.keys ).new( * o.values )
  end.call

end
