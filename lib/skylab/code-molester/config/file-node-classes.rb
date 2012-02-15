module Skylab::CodeMolester::Config
  class Sexp < ::Skylab::CodeMolester::Sexp
    def unparse sio=nil
      unless sio
        sio = StringIO.new
        ret = true
      end
      self[1..-1].each do |child|
        if child.respond_to?(:unparse)
          child.unparse(sio)
        else
          sio.write child.to_s
        end
      end
      if ret
        sio.rewind
        sio.read
      end
    end
  end
  MAP = Hash.new(Sexp)
  class << Sexp
    def for name, *a
      sexp = MAP[name].new
      sexp.concat [name, *a]
      sexp
    end
  end
  class ContentItemBranch < Sexp
    def [] name
      if name.kind_of?(String)
        i = content_items.detect { |i| name == i.item_name }
        if i and i.item_leaf?
          i.item_value
        else
          i
        end
      else
        super(name)
      end
    end
    def item_leaf?
      false
    end
  end
  class FileSexp < ContentItemBranch
    MAP[:file] = self
    def content_items
      a = self[1]
      a2 = a.content_items
      b = self[2]
      b2 = b.content_items
      [*a2, *b2]
      # [*self[1].content_items, *self[2].content_items]
    end
  end
  class Nosecs < ContentItemBranch
    MAP[:nosecs] = self
    def content_items
      select(:assignment_line)
    end
  end
  class Sections < Sexp
    MAP[:sections] = self
    def content_items
      select(:section)
    end
  end
  class Section < ContentItemBranch
    MAP[:section] = self
    def content_items
      self[2].select(:assignment_line)
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
    MAP[:assignment_line] = self
    def item_leaf?
      true
    end
    def item_value
      self[4][1]
    end
    def item_name
      self[2][1]
    end
  end
end

module Skylab::CodeMolester::Config::FileNode
  Sexp = ::Skylab::CodeMolester::Config::Sexp
  SEXP_HELPER = {}
  class Ele < Struct.new(:method, :type, :index, :name) ; end
  TMAP = { 't' => :terminal, 'n' => :nonterminal, 'w' => :whitespace }
  class SexpHelper < Struct.new(:nt, :eles, :methods) ; end
  module AutoSexp
    def _sexp_helper
      key = singleton_class.ancestors.first
      SEXP_HELPER[key] ||= begin
        h = SexpHelper.new
        mod = singleton_class.ancestors[0..1].reverse.detect { |m| m.to_s.match(/([^:]+)[0-9]$/) }
        unless mod
          fail("hack failed")
        end
        modname = $1
        nt = modname.gsub(/([a-z])([A-Z])/){ "#{$1}_#{$2}" }.downcase.intern
        h = SexpHelper.new(nt, [])
        (h.methods = mod.instance_methods).each do |m|
          if (md = /^([wnt])_([0-9]+)(?:_(.+))?$/.match(m.to_s))
            h.eles.push Ele.new(m, TMAP[md[1]], md[2].to_i, md[3] && md[3].intern)
          end
        end
        h
      end
    end
    def sexp
      h = _sexp_helper
      s = Sexp.for(h.nt)
      h.eles.each do |ele|
        el = send(ele.method)
        case ele.type
        when :whitespace ; s[ele.index] = el.text_value
        when :terminal   ;
          s[ele.index] = Sexp.for(ele.name, el.text_value)
        when :nonterminal; s[ele.index] = _sexp_reduce(el, ele.name || ele.method)
        end
      end
      s
    end
    REDUCE = lambda do |sexp, node|
      if node.terminal?
        # avoid these somewhow?
        sexp.push(node.text_value)
      elsif node.respond_to?(:sexp)
        sp = node.sexp
        if sexp.symbol_name == sp.symbol_name
          sexp.concat sp[1..-1]
        else
          sexp.push sp
        end
      else
        node.elements.each do |e|
          REDUCE[sexp, e]
        end
      end
      nil
    end
    def _sexp_reduce node, name
      s = Sexp.for(name)
      REDUCE[s, node]
      s
    end
  end
  class Node < Treetop::Runtime::SyntaxNode
    include AutoSexp
  end
end

