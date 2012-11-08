module Skylab::MetaHell::Klass::Creator

  # DSL for creating classes, for things like testing metaprogramming,
  # or testing libraries that do extensive reflection on class hierarchies,
  # class names, etc.
  # (it's not usually viable to test such things in static namespaces.)
  #
  #   **very** #experimental

  MetaHell = ::Skylab::MetaHell
  Klass = MetaHell::Klass
  Modul = MetaHell::Modul


  def self.extended mod # #sl-109
    mod.extend         ModuleMethods
    mod.send :include, InstanceMethods
  end

  module ModuleMethods
    include Modul::Creator::ModuleMethods # #impl for sure

    o = { }

    o[:build] = -> name, a do
      m = Klass::Meta.new name
      m.optionals! a if ! a.empty?
      m._freeze!
      m
    end

    o[:meta] = -> name, a, g do # mutates g
      meta = g.fetch name do
        m = K.build[ name, a ]
        a = nil
        g[name] = m
        m
      end
      a and meta.optionals! a
      meta
    end

    K = ::Struct.new(* o.keys).new ; o.each { |k, v| K[k] = v }

    def klass full_name, *a, &f
      let( :_nearest_klass_full_name ) { full_name } # for i.m. klass()
      g = __meta_hell_known_graph
      M.define[ full_name, f,
        -> name { g.fetch( name ) { |k| g[k] = M.build[ k ] } },  # branch
        -> name { K.meta[ name, a, g ] },                         # leaf
        -> name { __meta_hell_module!( name ) { modul! name } }   # memo
      ]
      nil
    end
  end

  module InstanceMethods
    extend MetaHell::Let::ModuleMethods

    include Modul::Creator::InstanceMethods

    K = ModuleMethods::K # #borrow

    let( :klass ) { send _nearest_klass_full_name }

    let( :object ) { klass.new }

    def klass! full_name, *a, &f
      # like module!, make this (or reopen it) now, and run any f on it.
      else_f = -> o, name do # nees to be bound to a, hence here
        M_.vivify[ o, name,
          -> { K.build[ name, a ] }, # build_f
          -> { klass! name } # acccessor_f - watch for inf. recursion
        ]
      end
      M_.bang[ M.parts[ full_name ], f, meta_hell_anchor_module,
        M_.branch_f[ self, ___meta_hell_known_graph, M_.else ],
        M_.branch_f[ self, ___meta_hell_known_graph, else_f ],
        -> m { ::Class == m.class or fail ::TypeError.exception "#{full_name
          } is not a class (it's a #{m.class})"
        }
      ]
    end
  end
end
