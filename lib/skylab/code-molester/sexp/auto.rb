module ::Skylab::CodeMolester

  module Sexp::Auto

    # (redundancy note-
    # there is another Sexp::Auto in tan-man. this one was started before
    # that one, then that one grew very strong, and now we are cleaning
    # up this one. but the point is we are no where near ready to merge
    # the two - they work very differently. they will have to continue
    # to cross-polinate for a while..)

    class Conduit_
      def initialize mod, op_h
        op_h.keys.each do |k|
          define_singleton_method k do |*a|
            mod.module_exec( *a, & op_h.fetch( k ) )
          end
        end
      end
    end

    class Conduit_::SingleShot
      def with sexp_auto_class
        @mutex = :with
        freeze
        @then[ :sexp_auto_class, sexp_auto_class ]
        sexp_auto_class
      end

      def initialize &later
        @then = later
      end
    end

    # `[]` - like `enhance` but use the default sexp class
    # ( also just for fun we grease the wheels with the alternate syntax )

    def self.[] mod
      enhance mod do
        sexp_auto_class Sexp
      end
    end

    -> do  # `enhance`

      init = nil ; op_h = { }

      define_singleton_method :enhance do |mod, &blk|
        if blk
          mod.module_exec( & init )
          Conduit_.new( mod, op_h ).instance_exec( &blk )
          nil
        else
          Conduit_::SingleShot.new do |name, value|
            mod.module_exec( & init )
            mod.module_exec value, & op_h.fetch( name )
            nil
          end
        end
      end

      mut_h = { }
      init = -> do  # self is the client module
        did = nil
        mut_h.fetch object_id do
          mut_h[ object_id ] = did = true

          include InstanceMethods

          cache_h = { }  # one cache per class that includes Sexp::Auto!

          define_method :sexp_helper_cache do
            cache_h
          end
        end
        did or fail "test me - multiple enhancements not yet tested."
      end

      op_h[:sexp_auto_class] = -> kls do  # self is the client module

        define_singleton_method :build_sexp do |*a|
          kls[ *a ]
        end

      end
    end.call
  end
end

module ::Skylab::CodeMolester::Sexp::Auto

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

  UnhelpfulHelper = ::Object.new

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
            fail "nope: #{ ele }"
          end
        end
      end
      s
    end

    REDUCE = lambda do |sexp, node|
      if node.terminal?
        # i don't love this
        if ::String === sexp.last
          sexp.last.concat node.text_value
        else
          sexp.push(node.text_value)
        end
      elsif node.respond_to?(:sexp)
        sp = node.sexp
        if ::String === sp
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
