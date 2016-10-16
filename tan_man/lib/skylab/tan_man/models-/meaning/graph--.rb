module Skylab::TanMan

  class Models_::Meaning::Graph__  # :[#087].

    # Some notes about resolving meaning: Meanings are currently stored
    # in comment strings in the sexps, and are not in their 'resting state'
    # held as sexps like other parts of the document. For this reason and
    # others, we do not cache a parsed sexp / graph of meanings, but rather
    # each time a meaning is to be applied (after being resolved) to a node,
    # we create an entire semantic graph to nerk the derk. This may have
    # to change for some strange scenario where we need more performace,
    # resolving lots of meanings quickly, but for the purpose of one-meaning
    # assignment-per-request, this should be sufficient to create the
    # whole graph on each request. Even if it feels icky, it will introduce
    # far fewer headaches as we develop this.
    #
    # Implementation note: experimentally this graph is "collapsed" one-way
    # lazily - so it indexes itself zero or one times and never goes back.
    # Hence after we index ourselves we can release the source data and not
    # get confused.


    def initialize meaning_st

      g = Home_.lib_.basic::Digraph.new
      h = ::Hash.new { |h_, k| h_[ k ] = [] }

      mn = meaning_st.gets
      while mn
        sym = mn.natural_key_string.intern
        v_s = mn.value_string
        if Looks_like_terminal__[ v_s ]
          g.absorb_node sym
          h[ sym ].push v_s
        else
          g.absorb_node sym, [ v_s.intern ]
        end
        mn = meaning_st.gets
      end

      @graph = g
      @terminal_h = h
    end

    Looks_like_terminal__ = -> do

      # centralize this hack - a meaning looks like a terminal
      # definition IFF its value is not a valid name!

      valid_name_rx = /\A[a-z][-a-z0-9]*\z/
      -> x do
        valid_name_rx !~ x
      end
    end.call

    def meaning_values_via_meaning_name meaning_name_s, & oes_p

      trail_a = []
      h = {}
      is_circular = false

      outer_h = CircleHash__.new(
        :[]    => -> k     { h[k] },
        :[]=   => -> k, v  { h[k] = v },
        :fetch => -> k, &b do
          had = true
          val = h.fetch k do
            had = false
            b[]
          end
          if had
            is_circular = true
            trail_a << k
          end
          val
        end )

      ea = @graph.walk_pre_order meaning_name_s.intern, 0, outer_h

      terminal_a = ea.reduce [] do | m, sym |
        trail_a.push sym
        if @terminal_h.key? sym
          m.concat @terminal_h.fetch sym
        end
        m
      end

      if terminal_a.length.zero?
        oes_p ||= -> *, & ev_p do
          raise ev_p[]
        end
        oes_p.call :error, :interminal_meaning, * ( :circular if is_circular ) do
          if is_circular
            Circular__.new_with :trail_a, trail_a
          else
            Interminable__.new_with :trail_a, trail_a
          end
        end
        UNABLE_
      else
        terminal_a
      end
    end

    CircleHash__ = Home_.lib_.basic::Proxy::Makers::Functional::Nice.new(
      :[], :[]=, :fetch )

    Interminable__ = Common_::Event.prototype_with :interminable,
        :trail_a, nil, :reason, :interminal, :ok, false do | y, o |

      self._RIDE_ME

      trail_a = o.trail_a
      stack_a = [ "#{ ick trail_a.last } has no meaning." ]

      if 1 < trail_a.length
        stack_a.push "#{ lbl trail_a[ -2 ] } means #{ val trail_a[ -1 ] }, but "
        trail_a.pop
      end

      while 1 < trail_a.length
        stack_a.push "#{ lbl trail_a[ -2 ] } means #{ val trail_a[ -1 ] } and "
        trail_a.pop
      end

      y << stack_a.reverse.join( EMPTY_S_ )
    end

    Circular__ = Common_::Event.prototype_with(  # #[#ta-007]
      :circular,
      :trail_a, nil,
      :reason, :circular,
      :ok, false,

    ) do | y, o |

      self._RIDE_ME

      _s = o.trail_a.map do | sym |
        "#{ lbl sym }"
      end.join( ' -> ' )

      "circular dependency in meaning: #{ _s }"
    end
  end
end
