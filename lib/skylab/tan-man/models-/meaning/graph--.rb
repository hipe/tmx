module Skylab::TanMan

  class Models::Meaning::Graph

    include Core::SubClient::InstanceMethods

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

    def resolve_meaning_strings meaning_name, interminable_meaning
      trail_a = []
      h = { }
      is_circular = false
      outer_h = CircleHash.new(
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
        end
      )
      ea = @graph.walk_pre_order meaning_name.intern, 0, outer_h
      terminal_a = ea.reduce [] do |m, sym|
        trail_a << sym
        if @terminal_h.key? sym
          m.concat @terminal_h.fetch( sym )
        end
        m
      end
      if terminal_a.length.zero?
        if is_circular
          res = Models::Meaning::Circular.new trail_a
        else
          res = Models::Meaning::Interminable.new trail_a
        end
        interminable_meaning[ res ]
        false
      else
        terminal_a
      end
    end

    CircleHash = TanMan_._lib.proxy_lib.nice :[], :[]=, :fetch

    class Models::Meaning::Interminable
      attr_reader :trail_a, :reason
      def initialize trail_a
        @reason = :interminable
        @trail_a = trail_a
      end
    end

    class Models::Meaning::Circular < Models::Meaning::Interminable
      def initialize trail_a
        @reason = :circular
        @trail_a = trail_a
      end
    end

  private

    -> do

      looks_like_terminal = nil  # scope

      define_method :initialize do |meaning_controller, meaning_enumerator|
        @graph = ::Skylab::Basic::Digraph.new  # (loaded by p.s. monadic)
        @terminal_h = ::Hash.new { |h, k| h[k] = [ ] }
        meaning_enumerator.each do |fly|
          if looks_like_terminal[ fly.value ]
            @graph.absorb_node fly.name.intern
            @terminal_h[ fly.name.intern ] << fly.value
          else
            @graph.absorb_node fly.name.intern, [ fly.value.intern ]
          end
        end
      end

      valid_name_rx = Models::Meaning.valid_name_rx
                                               # centralize this hack -
      looks_like_terminal = -> value do        # a meaning looks like a
        valid_name_rx !~ value                 # terminal definition iff
      end                                      # its value is not a
                                               # valid name!

    end.call
  end
end
