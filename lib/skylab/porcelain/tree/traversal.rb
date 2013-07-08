module ::Skylab::Porcelain

  class Tree::Locus

    Headless::CLI::Tree::Glyphs.each do |g|
      attr_accessor g.normalized_glyph_name # blank crook pipe separator tee
    end

    attr_accessor :branch

    attr_accessor :empty

    attr_reader :node_formatter

    def node_formatter= x
      if ::Symbol === x
        @node_formatter = -> n { n.send x }
      else
        @node_formatter = x
      end
      x
    end

    def traverse root, &block
      @level = 0
      @block = block
      @prefix_stack = []
      _traverse root
    end

    def prefix meta
      if meta[:level]
        "#{ @prefix_stack * '' }#{ meta[:is_last] ? crook : tee }"
      end
    end

    def parent_prefix meta
      if meta[:level]
        meta[:is_last] ? blank : pipe
      end
    end

  protected

    param_h_h = {
      crook: -> v { self.crook = v },
      node: -> v { self.node = v },
      node_formatter: -> v { self.node_formatter = v },
      pipe: -> v { self.pipe = v },
      tee: -> v { self.tee = v }
    }

    default_glyph_set = :narrow # try :wide

    define_method :initialize do |param_h=nil|
      # param_h = param_h.dup if param_h
      _glyph_set!(( param_h && param_h.delete(:glyph_set) or default_glyph_set))
        # (because the client might want to start with a glyph set,
        # and then override certain glyphs, we set it here and not there.)
        # (because the client might weirdly want to set some of the glyphs
        # as nil, we set defaults this way and not the other way.)
      if param_h
        param_h.each { |k, v| instance_exec v, & param_h_h.fetch( k ) }
      end
      self.node_formatter ||= :name
    end

    safe_names_h = nil

    define_method :_glyph_set! do |x|
      if ::Symbol === x
        x = Headless::CLI::Tree::Glyph::Sets.const_fetch x
      end
      safe_names_h ||= ::Hash[
        Headless::CLI::Tree::Glyphs.each.map do |g|
          [ g.normalized_glyph_name, true ]
       end
      ]
      x.each do |n, v|
        if safe_names_h[ n ]
          instance_variable_set "@#{ n }", v
        else
          raise ::NameError.new "bad glyph name - #{ n }"
        end
      end
    end

    def _push meta
      @level += 1
      @prefix_stack.push parent_prefix( meta )
    end

    def _pop meta
      @level -= 1
      @prefix_stack.pop
    end

    def _traverse root, meta={ }
      @block.call root, meta
      sum = 1
      if root.has_children
        _push meta
        last = root.children_length - 1
        root.children.each_with_index do |child, idx|
          sm = _traverse child, is_first: ( 0 == idx ),
                                 is_last: ( last == idx ),
                                   level: @level
          sum += sm
        end
        _pop meta
      end
      sum
    end
  end
end
