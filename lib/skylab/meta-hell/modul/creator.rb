module Skylab::MetaHell::Modul::Creator

  Creator = self
  MetaHell = ::Skylab::MetaHell
  Modul = MetaHell::Modul
  SEP = '__'
  SEP_ = '::'

  def self.extended mod # #sl-109
    mod.extend ModuleMethods
    mod.send :include, InstanceMethods
  end

  module ModuleMethods # expectts you to define your own let()
    extend MetaHell::Let # #impl

    o = ::Hash.new

    o[:convenience_f] = -> full_module_name do
      # _Foo self.Foo send(:Foo)
      define_method( "_#{full_module_name}" ) { send full_module_name }
    end

    o[:meta_f] = -> name { Modul::Meta.new name }

    o[:define_f] = -> full_name, f, branch_f, leaf_f, memo_f do
      parts = full_name.to_s.split SEP
      memo = parts.shift.intern
      prev = nil
      loop do
        name = memo # localized variable - important!
        if prev # relate sorrounding node to this child
          n = branch_f[ prev ]
          n.children.push(name) unless n.children.include? name
        end
        last = parts.empty?
        if last # then you have target doohah
          m = leaf_f[ name ]
          m.blocks.push f if f
        else
          m = branch_f[ name ]
        end
        memo_f[ name ]
        break if last
        prev = memo
        memo = "#{memo}#{SEP}#{parts.shift}".intern
      end
      nil
    end

    F = ::Struct.new(* o.keys ).new ; o.each { |k, v| F[k] = v }

    let :__meta_hell_known_graph do
      a = ancestors # ACK skip Object, Kernel, BasicObject ACK ACK ACK
      o = a[ ((self == a.first) ? 1 : 0 ) .. -4 ].detect do |x|
        x.respond_to? :__meta_hell_known_graph
      end
      o and fail("ACK try to implement this crazy shit ~meta hell")
      { }
    end

    def ___meta_hell_memoize_module full_module_name, &f
      # memoize the module (e.g. class) around this very definition call
      # together with the anchor moudule.  Memoizing on the client alone will
      # get you possibly repeated definition block runs depending on how
      # you implement that .. in flux!

      memo_h = { }

      let full_module_name do
        memo_h.fetch( meta_hell_anchor_module.object_id ) do |mod|
          memo_h[mod] = instance_exec(& f)
        end
      end
    end

    def __meta_hell_module! full_module_name, &f
      ___meta_hell_memoize_module full_module_name, &f
      module_exec full_module_name, & F.convenience_f # ! module_exec
      nil
    end

    def modul full_name, &f
      g = __meta_hell_known_graph
      branch_f = -> name { g.fetch( name ) { |k| g[k] = F.meta_f[ k ] } }
      F.define_f[ full_name, f,
        branch_f,
        branch_f,
        -> name { __meta_hell_module!( name ) { modul! name } }
      ]
      nil
    end
  end


  module InstanceMethods
    extend MetaHell::Let::ModuleMethods

    o = { }

    o[:bang_f] = -> parts, f, mod, branch_f, leaf_f do
      unless parts.empty? # sanity base case - zero list / empty string
        parts = parts.dup
        seen = [ const = parts.shift.intern ]
        loop do
          last = parts.empty?
          if mod.const_defined? const, false
            mod = mod.const_get const, false
          elsif last
            leaf_f.call( seen ) { |m| mod = mod.const_set const, m }
          else
            branch_f.call( seen ) { |m| mod = mod.const_set const, m }
          end
          if last
            f and mod.module_exec(& f) # ick but yolo
            break
          end
          seen.push( const = parts.shift.intern )
        end
      end
      mod
    end

    o[:build_f] = -> meta, seen, o, g, result_f do
      s = seen.join( SEP_ ).freeze
      if meta._locked?
        fail "circular dependency on #{s} - should you be using ruby instead?"
      end
      meta._lock!
      mod = meta._build o, g
      mod.singleton_class.send(:define_method, :to_s) { s }
      meta.blocks.each do |_f|
        mod.module_exec(& _f)
      end
      meta._unlock!
      result_f[ mod ]
      # this totally will be broken if you think of it as ruby
      meta.children.each do |ch|
        o.modul! ch
      end
      nil
    end

    o[:else_f] = -> o, g, name do
      m = ModuleMethods::F.meta_f[ name ]
      sc = o.singleton_class
      sc.send :define_method, name do
        modul! name # super sketchy if done wrong!
      end
      sc.class_exec name, & ModuleMethods::F.convenience_f
      m
    end

    o[:name_f] = -> parts  { parts.join(SEP).intern }

    F_ = ::Struct.new(* o.keys ).new ; o.each { |k, v| F_[k] = v }

    let :___meta_hell_known_graph do
      self.class.__meta_hell_known_graph
    end

    def modul! full_name, &f
      # get this module by name now, autovivifying where necessary, running
      # any and all known blocks on the module iff you are autovivifying it.
      # Note this naive implementation runs your blocks in
      # the order they were defined, but on a per-module basis one at a time.
      # It does the modules from outside in (breadth-first) no matter
      # what order they were defineed in #experimental!

      branch_f = -> parts, &result_f do
        g = ___meta_hell_known_graph
        name = F_.name_f[ parts ]
        meta = g.fetch( name ) { F_.else_f[ self, g, name ] }
        F_.build_f[ meta, parts, self, g, result_f ]
        nil
      end
      F_.bang_f[ full_name.to_s.split(SEP), f, meta_hell_anchor_module,
        branch_f, branch_f]
    end
  end
end
