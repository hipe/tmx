module Skylab::CodeMolester

  module Sexp::Registrar

    # this is a new refactor on an old legacy piece. it may or may not have
    # a bright future - in tan-man we do this kind of thing isomorphically
    # or something .. but anyway this here is fine now.

    -> do

      mutex = nil

      define_singleton_method :[] do |mod|
        mod.module_exec( & mutex )
        mod
      end

      mutex = Lib_::Module_mutex[ -> do

        @sexp_registry_h = { }

        define_singleton_method :[]= do |symbol, klass|
          @sexp_registry_h[ symbol ] = klass
          # (the above will in theory bork when a child class tries to
          # mutate the parent's registry. but suggestions welcome, future self)
        end

        # `[]` - builds the sexp either with the registered factory or
        # as a generic sexp based on whether a factory with that name was
        # registered (below)

        me = self
        define_singleton_method :[] do |*a|
          res = nil
          if me == self
            if a.length.nonzero?
              kls = @sexp_registry_h[ a.fetch 0 ]
              if kls && me != kls
                res = kls[ *a ]
              end
            end
          end
          res ||= super( *a )
          res
        end
      end ]
    end.call
  end
end
