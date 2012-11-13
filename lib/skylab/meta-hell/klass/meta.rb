module Skylab::MetaHell
  class Klass::Meta < MetaHell::Modul::Meta
    include MetaHell::Let::InstanceMethods # __memoized #impl

    # This metadata class (like its parent) has two distinct purposes :
    # 1) represent all data presented using the DSL in a lightweight way
    # 2) act as an adapter for building the "product" object, in this
    #    case the class, doing things like resolving superclasses, etc.

    def build_product client=nil, kg=nil # kg = 'known graph'
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

    def safe?                     # hack to avoid autovivification circ. deps.:
      ! extends                   # If a class has a superclass, we don't have
    end                           # or want the logic to untangle a true
                                  # dependency graph when autovivification
                                  # happens.  But be warned the whole thing
                                  # will hence feel inconsistent..

  protected

    def _option! k, v
      if respond_to?( m = "_set_#{k}!" )
        send m, v
      else
        raise "invalid option \"#{k}\" (did you mean \"extends\"?)"
      end
    end

    -> do

      valid_rx = /\A[A-Z][_a-zA-Z0-9]*\z/

      resolve_class_name = -> client, full_name, kg do
        # basically just validate full_name, else bork an elaborate msg

        ::Symbol == full_name.class or fail 'sanity' # being cautious for now
        full_name.to_s =~ valid_rx or raise "malformed name: #{full_name}"
        if client.respond_to? full_name
          full_name
        else
          err = ["client does not have a `#{full_name}` method"]
          if kg
            if kg.key? full_name
              err.push " (although it was found in the known graph STRANGE)"
            else
              err.push " and is not in the definitions graph.#{
              } The definitions graph includes: (#{ kg.keys.join ', ' })"
            end
          else
            err.push " (and there is no known graph)"
          end
          fail "can't resolve class name #{full_name.inspect} -- #{ err * '' }."
        end
      end

      resolve_superclass = {

        ::NilClass => ->(*) { },

        ::Class => ->( meta, * ) { meta.extends },

        ::Symbol => -> me, client, kg do
          full_superclass_name = resolve_class_name[ client, me.extends, kg ]
          if me._locked?
            fail "cyclic dependency? (#{ me.name } < #{ full_superclass_name })"
          end
          me._lock!
          result = client.send full_superclass_name
          me._unlock!
          result
        end
      }

      fetch = -> klass do
        resolve_superclass.fetch klass do |k|
          raise "invalid 'extends:' value - expecting Class or Symbol,#{
            } had #{ k }"
        end
      end

      define_method :extends= do |mixed|
        fetch[ mixed.class ]      # confirm that it is a "type" we accept
        _set_extends! mixed       # confirm that we haven't yet set it
        mixed
      end

      define_method :_resolve_superclass do |client, kg|
        f = fetch[ extends.class ]
        f[ self, client, kg ]
      end

    end.call

    public :extends=

    def _set_extends! mixed
      if __memoized.key? :extends # if its value is known
        if extends != mixed       # normalizing is out of scope
          raise ::TypeError.exception("superklass mismatch for #{name} (#{
            extends || 'nothing' } then #{ mixed || 'nothing' })")
        end                       # else nothing to set
      else
        __memoized[:extends] = mixed
      end
    end
  end
end
