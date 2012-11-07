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

    def klass full_name, *a, &f
      let( :_nearest_klass_full_name ) { full_name } # for i.m. klass()
      g = __meta_hell_known_graph
      F.define_f[ full_name, f,
        -> name { g.fetch( name ) { |k| g[k] = F.meta_f[ k ] } }, # branch
        -> name { _meta_hell_klass_meta name, a, g },             # leaf
        -> name { __meta_hell_module!( name ) { modul! name } }   # memo
      ]
      nil
    end

    -> do
      meta_f = nil
      define_method :_meta_hell_klass_meta do |name, a, g|
        m, f = meta_f[ name, g ]
        if ! a.empty?
          1 == a.length and ::Hash === a.first or fail ArgumentError.exception(
            "expecting options hash not #{ a.map(&:class).join(', ') }" )
          a.first.each { |k, v| m._option! k, v }
        end
        f.call
        m
      end

      meta_f = -> name, g do
        found = g.key? name
        m = found ? g[name] : Klass::Meta.new(name)
        after_f = -> do
          if ! found
            m._freeze!
            g[name] = m
          end
        end
        [ m, after_f ]
      end

    end.call
  end

  module InstanceMethods
    extend MetaHell::Let::ModuleMethods

    include Modul::Creator::InstanceMethods

    let( :klass ) { send _nearest_klass_full_name }

    let( :object ) { klass.new }
  end
end
