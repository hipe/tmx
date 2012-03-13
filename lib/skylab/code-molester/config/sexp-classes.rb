module Skylab::CodeMolester::Config
  class Sexp < ::Skylab::CodeMolester::Sexp ; end
  S = Sexp
  class ValuesPseudohash < ::Enumerator
    def [] key
      d = detect { |o| key == o.key } or return nil
      d.value
    end
    def []= key, value
      @local_root.set_value(key, value)
    end
    def initialize local_root, &b
      @local_root = local_root
      super(&b)
    end
    def each &b
      if 2 == b.arity
        super do |el|
          b.call(el.key, el.value)
        end
      else
        super
      end
    end
    def keys
      map { |v| v.key }
    end
  end
  class ContentItemBranch < Sexp
    # note that for now this is hard-coded to assume string and not symbol keys!
    # (the test below cannot simply test for Fixnum-based key b/c it also must take ranges)
    def [] name
      String === name or return super
      if ( i = content_items.detect { |ii| name == ii.item_name } )
        if i.item_leaf?
          i.item_value
        else
          i
        end
      else
        _no_value name
      end
    end
    def []= k, v
      String === k or return super
      set_value k, v
      v
    end
    def item_leaf?
      false
    end
    def key? name
      !! content_items.detect { |ii| name == ii.item_name }
    end
    def _no_value name
    end
    def set_value name, value
      if item = content_items.detect { |i| name == i.item_name }
        _update_value item, value
      else
        _create_value name, value
      end
    end
    def value_items
      this = _assignments_sexp
      ValuesPseudohash.new(self) do |y|
        this.select(:assignment_line).each { |a| y << a }
      end
    end
  end
  class FileSexp < ContentItemBranch
    Sexp[:file] = self
    def _assignments_sexp
      self[1]
    end
    def content_items
      a = self[1]
      a2 = a.content_items
      b = self[2]
      b2 = b.content_items
      [*a2, *b2]
      # [*self[1].content_items, *self[2].content_items]
    end
    def _create_value name, value
      # we could try try dynamically add the node if necessary, but it
      # is less hacky to just assume it is there.  "Should" be there for all such valid trees.
      sec = detect(:nosecs) or fail("Invalid file sexp: child not found: nosecs")
      AssignmentLine.create(name, value, sec)
      nil
    end
    def _no_value name
      Section.create name, detect(:sections)
    end
    def _update_value assmt, value
      assmt.set_item_value value
    end
  end
  class Nosecs < ContentItemBranch
    Sexp[:nosecs] = self
    def content_items
      select(:assignment_line)
    end
  end
  class Sections < Sexp
    Sexp[:sections] = self
    def content_items
      select(:section)
    end
  end
  class Section < ContentItemBranch
    Sexp[:section] = self
    def content_items
      self[2].select(:assignment_line)
    end
    def _create_value name, value
      # see comment at other implementation of this method
      items = detect(:items) or fail("Invalid section sexp: child not found: items")
      AssignmentLine.create(name, value, items)
    end
    def item_leaf?
      false
    end
    def item_name
      self[1][1][2][1]
    end
    alias_method :section_name, :item_name
  end
  class << Section
    def create name, parent
      if tmpl = parent.last(:section)
        sl = tmpl.detect(:header).detect(:section_line)
        s0 = sl[1]
        s1 = sl[3][1]
      else
        s0 = '['
        s1 = ']'
      end
      sect = S[:section, S[:header, S[:section_line, s0, S[:name, name.to_s], S[:n_3, s1]]],
        S[:items, "\n"]]
      # parent.push "\n" # this probably breaks syntax, let's see if it's ok # SEE TESTS
      parent.push sect
      sect
    end
  end
  class AssignmentLine < Sexp
    Sexp[:assignment_line] = self
    NAME = 2
    VALUE = 4
    TRAILING_WHITESACE = 5
    @default_indent = '  '
    def item_leaf?
      true
    end
    def item_value
      self[VALUE][1]
    end
    alias_method :value, :item_value # compat
    def item_name
      self[NAME][1]
    end
    alias_method :key, :item_name # compat
    def set_item_value value
      self[VALUE][1] = value.to_s
    end
  end
  class << AssignmentLine
    def create name, value, parent
      # use the whitespace formatting of the previous item if you can
      if tmpl = parent.select(:assignment_line).last
        # anything?
      else
        tmpl = [nil, default_indent, nil, ' = ', nil]
      end
      al = self[:assignment_line, tmpl[1], S[:name, name.to_s], tmpl[3], S[:value, value.to_s]]
      if parent.size > 1 and parent.last.respond_to?(:symbol_name) and :assignment_line == parent.last.symbol_name
        parent.push "\n" # this is so bad
      end
      parent.push al
      parent.push "\n" # per the grammar
      nil
    end
    attr_accessor :default_indent
  end
  class Comment < Sexp
    Sexp[:comment] = self
    # node_reader :body
  end
end

