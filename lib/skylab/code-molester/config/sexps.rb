module Skylab::CodeMolester::Config

  MetaHell = ::Skylab::MetaHell
                                  # if you somehow got here without sexp
  S = self::Sexp                  # load it here and now / shorten it
                                  # we especially need it for registering

  module Sexps                    # isn't it nice to see a plain old module
  end                             # so docile


  class Sexps::ValuesPseudohash < ::Enumerator
    def [] key
      d = detect { |o| key == o.key } or return nil
      d.value
    end
    def []= key, value
      root.set_mixed key, value
    end
    def initialize root, &b
      self.root = root
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
    attr_accessor :root
  end


  class Sexps::SectionsPseudohash < Sexps::ValuesPseudohash
    extend MetaHell::DelegatesTo
    def [] key
      detect { |i| key == i.item_name }
    end
    def []= key, value
      Hash === value or raise ArgumentError.new("Every assignment to an entire section must be a Hash, had #{value.class}")
      sec = self[key] || Sexps::Section.create(key, root)
      value.each { |k, v| sec[k] = v }
      value
    end
    delegates_to :root, :remove
  end


  class Sexps::ContentItemBranch < Sexp
    # note that for now this is hard-coded to assume string and not symbol keys!
    # (the test below cannot simply test for Fixnum-based key b/c it also must take ranges)
    def [] *a
      1 == a.count && ::String === a.first or return super
      name = a.first
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
    def []= *a
      2 == a.count and ::String === a.first or return super
      set_mixed( *a )
      a.last
    end
    def item_leaf?
      false
    end
    def key? name
      !! content_items.detect { |ii| name == ii.item_name }
    end
    def _no_value name
    end
    def set_mixed name, value
      if ::Hash === value
        sections[name] = value
      elsif item = content_items.detect { |i| name == i.item_name }
        _update_value item, value
      else
        _create_value name, value
      end
    end
    def value_items
      Sexps::ValuesPseudohash.new(self) do |y|
        _assignments_sexp.select(:assignment_line).each { |a| y << a }
      end
    end
  end



  class Sexps::FileSexp < Sexps::ContentItemBranch
    Sexp[:file] = self
    delegates_to :nosecs, :prepend_comment
    # delegates_to :sections, :append_comment # e.g.
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
      Sexps::AssignmentLine.create name, value, sec
      nil
    end
    def nosecs
      detect :nosecs
    end
    def sections
      detect(:sections).enumerator
    end
    def _update_value assmt, value
      assmt.set_item_value value
    end
  end


  class Sexps::Nosecs < Sexps::ContentItemBranch
    Sexp[:nosecs] = self
    def content_items
      select :assignment_line
    end
    def prepend_comment line
      o = build_comment_line(line) or return false
      self[1,0] = [o] # supreme hackery
      o
    end
  end



  class Sexps::Sections < Sexp
    Sexp[:sections] = self
    def enumerator
      Sexps::SectionsPseudohash.new self do |y|
        select(:section).each { |s| y << s }
      end
    end
    alias_method :content_items, :enumerator
  end



  class Sexps::Section < Sexps::ContentItemBranch
    Sexp[:section] = self
    def content_items
      self[2].select :assignment_line
    end
    def _create_value name, value
      # see comment at other implementation of this method
      items = detect(:items) or fail("Invalid section sexp: child not found: items")
      Sexps::AssignmentLine.create(name, value, items)
    end
    def item_leaf?
      false
    end
    def item_name
      self[1][1][2][1]
    end
    alias_method :section_name, :item_name
    def item_name= str
      self[1][1][2][1] = str
    end
    alias_method :section_name=, :item_name=
    def _update_value assmt, value # c/p
      assmt.set_item_value value
    end
  end



  class << Sexps::Section
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



  class Sexps::AssignmentLine < Sexp
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



  class << Sexps::AssignmentLine
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



  class Sexps::Comment < Sexp
    Sexp[:comment] = self
    # node_reader :body
  end
end
