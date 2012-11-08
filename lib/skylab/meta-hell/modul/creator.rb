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

    o[:body] = -> mod, name, f do
      M.memoize[ mod, name, f ]
      mod.module_exec name, & M.convenience
      nil
    end

    o[:build] = -> name { Modul::Meta.new name }

    o[:convenience] = -> full_module_name do   #   _Foo   self.Foo   send(:Foo)
      define_method( "_#{full_module_name}" ) { send full_module_name }
    end

    o[:define] = -> full_name, f, branch_f, leaf_f, body_f do
      parts = M.parts[ full_name ]
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
        body_f[ name ]
        break if last
        prev = memo
        memo = "#{memo}#{SEP}#{parts.shift}".intern
      end
      nil
    end

    o[:memoize] = -> mod, name, f do
      # memoize the module (e.g. class) around this very definition call
      # together with the anchor module.  Memoizing on the client alone will
      # get you possibly repeated definition block runs depending on how
      # you implement that .. in flux!

      memo_h = { }

      mod.let name do
        # ( self here is the client, not the defining class / module )
        memo_h.fetch( meta_hell_anchor_module.object_id ) do |id|
          memo_h[id] = instance_exec(& f)
        end
      end

      nil
    end

    o[:parts] = -> full_name { full_name.to_s.split SEP }

    M = ::Struct.new(* o.keys ).new ; o.each { |k, v| M[k] = v }

    let :__meta_hell_known_graph do
      a = ancestors # ACK skip Object, Kernel, BasicObject ACK ACK ACK
      o = a[ ((self == a.first) ? 1 : 0 ) .. -4 ].detect do |x|
        x.respond_to? :__meta_hell_known_graph
      end
      o and fail("ACK try to implement this crazy shit ~meta hell")
      { }
    end

    def modul full_name, &f
      g = __meta_hell_known_graph
      branch_f = -> name { g.fetch( name ) { |k| g[k] = M.build[ k ] } }
      M.define[ full_name, f,
        branch_f,
        branch_f,
        -> name { M.body[ self,  name, -> { modul! name } ] }
      ]
      nil
    end
  end


  module InstanceMethods
    extend MetaHell::Let::ModuleMethods

    o = { }

    o[:bang] = -> parts, f, mod, branch_f, leaf_f, found_f=nil do
      unless parts.empty? # sanity base case - zero list / empty string
        parts = parts.dup
        seen = [ const = parts.shift.intern ]
        loop do
          last = parts.empty?
          if mod.const_defined? const, false
            mod = mod.const_get const, false
            found_f and found_f[ mod ]
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

    o[:branch_f] = -> o, g, else_f do
      # make a lambda that will make branch nodes (e.g. modules or classes)
      -> parts, &result_f do
        name = M_.name[ parts ]
        meta = g.fetch( name ) { else_f[ o, name ] }
        M_.build[ meta, parts, o, g, result_f ]
        nil
      end
    end

    o[:build] = -> meta, seen, o, g, result_f do
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

    o[:vivify] = -> o, name, build_f, accessor_f do
      m = build_f.call
      sc = o.singleton_class
      sc.send(:define_method, name, &accessor_f)
      sc.class_exec name, & M.convenience
      m
    end

    o[:else] = -> o, name do
      M_.vivify[ o, name,
        -> { M.build[ name ] }, # build_f
        -> { modul! name }   # accessor_f - watch for inf. recursion
      ]
    end

    o[:name] = -> parts  { parts.join(SEP).intern }

    M_ = ::Struct.new(* o.keys ).new ; o.each { |k, v| M_[k] = v }
    M = ModuleMethods::M # hey can i borrow this

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

      branch_f = M_.branch_f[ self, ___meta_hell_known_graph, M_.else ]
      M_.bang[ M.parts[ full_name ], f, meta_hell_anchor_module,
        branch_f, branch_f]
    end
  end
end
