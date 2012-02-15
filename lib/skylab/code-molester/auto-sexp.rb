module Skylab::CodeMolester
  module AutoSexp
    def self.extended mod
      mod.auto_sexp_init
      mod.send(:include, InstanceMethods)
    end
    def auto_sexp_init # @api-private
      cache = {} # one cache per class that includes AutoSexp!
      define_method(:sexp_helper_cache) { cache }
      factory = nil
      self.singleton_class.send(:define_method, :sexp_factory_class) do |klass=nil|
        if klass
          factory = klass
        elsif factory
          factory
        else
          require File.expand_path('../sexp', __FILE__)
          factory = Sexp
        end
      end
    end
    def build_sexp *a
      sexp_factory_class[*a]
    end
  end
end

module Skylab::CodeMolester::AutoSexp
  EXPAND = { 't' => :terminal, 'n' => :nonterminal, 'w' => :whitespace }
  Ele = Struct.new(:method, :type, :index, :name)
  SexpHelper = Struct.new(:nt, :eles, :methods)
  TERMINAL_RULE_HELPER = Class.new.class_eval do
    def eles
    end
    def nt
    end
    self
  end.new

  UnhelpfulHelper = Object.new

  module InstanceMethods # @api private
    def sexp_helper
      key = singleton_class.ancestors.first
      sexp_helper_cache[key] ||= begin
        mod = singleton_class.ancestors[0..1].reverse.detect { |m| m.to_s.match(/([^:]+)[0-9]$/) }
        if mod
          modname = $1
          nt = modname.gsub(/([a-z])([A-Z])/){ "#{$1}_#{$2}" }.downcase.intern
          h = SexpHelper.new(nt, [])
          (h.methods = mod.instance_methods).each do |m|
            if (md = /^([wnt])_([0-9]+)(?:_(.+))?$/.match(m.to_s))
              h.eles.push Ele.new(m, EXPAND[md[1]], md[2].to_i, md[3] && md[3].intern)
            end
          end
          h
        else
          TERMINAL_RULE_HELPER
        end
      end
    end
    def sexp
      h = sexp_helper
      h.nt.nil? and return text_value # hack
      s = self.class.build_sexp(h.nt)
      if h.eles.nil?
        s.push text_value
      else
        h.eles.each do |ele|
          el = (:self == ele.method) ? self : send(ele.method)
          case ele.type
          when :whitespace
            s[ele.index] = el.text_value
          when :terminal
            s[ele.index] = self.class.build_sexp(ele.name, el.text_value)
          when :nonterminal
            s[ele.index] = _sexp_reduce(el, ele.name || ele.method)
          else
            fail("nope: #{ele}")
          end
        end
      end
      s
    end
    REDUCE = lambda do |sexp, node|
      if node.terminal?
        # i don't love this
        if String === sexp.last
          sexp.last.concat node.text_value
        else
          sexp.push(node.text_value)
        end
      elsif node.respond_to?(:sexp)
        sp = node.sexp
        if String === sp
          sexp.push sp
        elsif sexp.symbol_name == sp.symbol_name
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
      s = self.class.build_sexp(name)
      REDUCE[s, node]
      s
    end
  end
end

