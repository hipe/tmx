module Skylab::MetaHell

  module Module

    # `mutex`        - produce a function from another function. the produced
    # function is designed to enusre that it is never `module_exec`ed against
    # the same module more than once (using `object_id`). the first time that
    # the produced function is module_exec'd against some module the argument
    # function `func_for_module` is also module_exec'd on that module. if any
    # subsequent attempts are made to call this same function on the selfsame
    # argument module (HA) a runtime error is raised. produced function takes
    # no arguments, but `func_for_module` function may.

    -> do  # `mutex`
      mutex = me = nil
      define_singleton_method :mutex do mutex end
      mutex = -> func_for_module, method_name=nil do
        mut_h = { }
        ->( *a ) do  # self should be a client module.
          did = res = nil
          mut_h.fetch object_id do
            mut_h[ object_id ] = did = true
            res = module_exec( *a, & func_for_module )
          end
          if ! did
            msg = if method_name
              "#{ me }failure - cannot call `#{ method_name }` more #{
              }than once on a #{ self }"
            else
              "#{ me }failure - #{ self }"
            end
            raise msg
          end
          res
        end
      end
      me = '`MetaHell::Module.mutex` '
    end.call
  end
end
