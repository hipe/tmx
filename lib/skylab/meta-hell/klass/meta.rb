module Skylab::MetaHell
  class Klass::Meta < MetaHell::Modul::Meta
    include MetaHell::Let::InstanceMethods # __memoized #impl

    -> do
      extends_f = nil

      define_method :_build do |o, g|
        x = extends_f[ extends, o, g ] if extends
        ::Class.new(* [x].compact )
      end

      valid = [::Class, ::Symbol] ; symbol_f = nil

      extends_f = -> extends, o, g do
        valid.include?(extends.class) or raise "invalid 'extends:' value - #{
          }expecting #{ valid.join ' or ' }, had #{ extends.class }"
        case extends
        when ::Class  ; extends
        when ::Symbol ; o.instance_exec(extends, g, & symbol_f)
        end
      end

      symbol_f = -> symbol, g do
        g.key?(symbol) or raise "#{symbol.inspect} is not in the definitions#{
          } graph. The definitions graph includes: (#{ g.keys.join ', ' })"
        send symbol
      end

    end.call

    def extends # non-normalized
      __memoized[:extends]
    end

    def _freeze!
      __memoized[:extends] ||= nil
    end

    def _option! k, v
      if respond_to?( m = "_set_#{k}!" )
        send m, v
      else
        raise "invalid option \"#{k}\" (did you mean \"extends\"?)"
      end
    end

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
