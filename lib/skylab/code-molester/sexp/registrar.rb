module Skylab::CodeMolester

  module Sexp::Registrar

    # associate a lowercase underscores symbol name with a grammar symbol cls

    class << self

      def [] mod
        mod.module_exec :register, & Enhance__ ; nil
      end

      Enhance__ = CM_.lib_.module_lib.mutex( -> method_name_i do

        _ME = self
        _REGISTRY_H = {}

        define_singleton_method :[] do |*a|

          if _ME == self && a.length.nonzero?
            cls = _REGISTRY_H[ a.fetch 0 ]
            _ME == cls && cls = nil  # sanity avoid infinite recursion
          end
          if cls
            cls[ *a ]
          else
            super( *a )
          end
        end

        define_singleton_method method_name_i do |i|
          _REGISTRY_H[ i ] = self
        end

        nil
      end )
    end
  end
end
