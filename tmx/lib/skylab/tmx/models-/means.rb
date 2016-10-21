module Skylab::TMX

  class Models_::Means

    # (purely a specialized session, just for expression)

    class << self
      alias_method :[], :new
    end  # >>

    def initialize sym, x, sym_
      @_dependency_shape = sym
      @_dependency_symbol = x
      @_self_shape = sym_
    end

    def say_self_via_ivar ivar, expag
      _name = Common_::Name.via_variegated_string ivar[1..-1]
      _say _name, @_self_shape, expag
    end

    def say_self_via_symbol sym, expag
      _name = Common_::Name.via_variegated_symbol sym
      _say _name, @_self_shape, expag
    end

    def say_dependency_under expag
      _name = Common_::Name.via_variegated_symbol @_dependency_symbol
      _say _name, @_dependency_shape, expag
    end

    def _say name, shape_sym, expag
      send METHOD___.fetch( shape_sym ), expag, name
    end

    METHOD___ = {
      human: :__say_human,
      primary: :__say_primary,
    }

    def __say_human _expag, name
      name.as_human
    end

    def __say_primary expag, name
      expag.calculate do
        say_primary_ name
      end
    end
  end
end
