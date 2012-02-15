module Skylab::CodeMolester::Config
  class Sexp < ::Skylab::CodeMolester::Sexp ; end
  S = Sexp
  class ContentItemBranch < Sexp
    # note that for now this is hard-coded to assume string and not symbol keys!
    # (the test below cannot simply test for Fixnum-based key b/c it also must take ranges)
    def [] name
      String === name or return super
      i = content_items.detect { |i| name == i.item_name }
      if i and i.item_leaf?
        i.item_value
      else
        i
      end
    end
    def []= k, v
      String === k or return super
      set_value k, v
    end
    def item_leaf?
      false
    end
    def set_value name, value
      if i = content_items.detect { |i| name == i.item_name }
        _update_value i, value
      else
        _create_value name, value
      end
    end
  end
  class FileSexp < ContentItemBranch
    Sexp[:file] = self
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
    def item_name
      self[NAME][1]
    end
  end
  class << AssignmentLine
    def create name, value, parent
      # use the whitespace formatting of the previous item if you can
      if tmpl = parent.select(:assignment_line).last
        # cmnt = tmpl.detect(:comment) or fail("expecting comment nodes to exist for all assignment lines.")
        $stderr.puts "NOTICE: do the newline hack here @todo #{__FILE__}#{__LINE__}"
      else
        tmpl = [nil, default_indent, nil, ' = ', nil]
      end
      o = self[:assignment_line, tmpl[1], S[:name, name.to_s], tmpl[3], S[:value, value.to_s]]
      parent.push o
      parent.push "\n"
      o
    end
    attr_accessor :default_indent
  end
  class Comment < Sexp
    Sexp[:comment] = self
    # node_reader :body
  end
end

