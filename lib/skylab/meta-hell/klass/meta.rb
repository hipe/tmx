module Skylab::MetaHell
  class Klass::Meta < MetaHell::Modul::Meta
    include MetaHell::Let::InstanceMethods # __memoized #impl

    # This metadata class (like its parent) has two distinct purposes :
    # 1) represent all data presented using the DSL in a lightweight way
    # 2) act as an adapter for building the "product" object, in this
    #    case the class, doing things like resolving superclasses, etc.

    def build_product client, kg
      supra = _resolve_superclass client, kg
      o = ::Class.new(* [supra].compact )
      _init_product o
      o
    end

    def extends # non-normalized .. we use a hash to hold this so we can have
      __memoized[:extends]        # meaninful nils, i.e. "this was set and is
    end                           # known not to exist.", which is used below.

    def _freeze!
      __memoized[:extends] ||= nil
    end

    def optionals! a              # ( we do a little validation here of
      if ! a.empty?               #   the DSL itself. )
        1 == a.length && ::Hash === a.first or fail "expection options #{
          }hash not not #{ a.map(&:class).join(', ') }"
        a.first.each { |k, v| _option! k, v }
      end
      nil
    end

    def safe? ; false end

  protected

    def _option! k, v
      if respond_to?( m = "_set_#{k}!" )
        send m, v
      else
        raise "invalid option \"#{k}\" (did you mean \"extends\"?)"
      end
    end

    -> do

      resolve_superclass = {

        ::NilClass => ->(*) { },

        ::Class => ->( meta, * ) { meta.extends },

        ::Symbol => -> me, client, kg do
          meta = kg.fetch me.extends do |x|
            raise "#{x.inspect} is not in the definitions graph.#{
            } The definitions graph includes: (#{ kg.keys.join ', ' })"
          end
          if me._locked?
            fail "cyclic dependency? (#{ me.name } < #{ meta.name })"
          end
          me._lock!
          result = client.send meta.name
          me._unlock!
          result
        end
      }

      define_method :_resolve_superclass do |client, kg|
        f = resolve_superclass.fetch extends.class do |klass|
          raise "invalid 'extends:' value - expecting Class or Symbol,#{
            } had #{ extends.class }"
        end
        f[ self, client, kg ]
      end

    end.call

    def _set_extends! mixed
      if __memoized.key? :extends # if its value is known
        if extends != mixed       # normalizing is out of scope
          raise ::TypeError.exception("superklass mismatch (#{
            extends || 'nothing' } then #{ mixed || 'nothing' })")
        end                       # else nothing to set
      else
        __memoized[:extends] = mixed
      end
    end
  end
end
