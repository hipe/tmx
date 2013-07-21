module Skylab::MetaHell

  module Autoloader::Autovivifying::Recursive

    Methods = Autoloader::Methods

    class << self
      define_method :[], & Autoloader::Enhance_
    end
  end

  class Autoloader::Autovivifying::Recursive::Tug <
        Autoloader::Autovivifying::Tug

    def load_and_get correction=nil
      x = super
      yes = if x.respond_to? :dir_pathname
        true
      elsif ::Module === x
        x.extend Autoloader::Methods
        true
      end
      if yes
        tug = self
        x.instance_exec do
          if dir_pathname.nil?  # allow shenanigans
            init_dir_pathname tug.branch_pathname
          end
          if tug_class.nil?
            tug.class.enhance self
          end
        end
      end
      x
    end
  end

  module Autoloader::Autovivifying::Recursive::Upwards

    # turn a module and each of its not-yet enhanced parent modules into a
    # MAARS module. This works provided that it eventually hits a module that
    # responds to `dir_pathname` and responds with true-ish.
    #
    # (note we can *not* assume that "having"/"knowing" the `dir_pathname`
    # is isomorphic with `respond_to?` `dir_pathname` - in real life there are
    # times when the one is true but not the other so we must check for both.)
    #
    # #multi-entrant

    def self.[] mod
      stack_a = [ ] ; top_has_dpn = false
      while ! ( mod.respond_to? :dir_pathname and mod.dir_pathname )
        stack_a.push mod
        mod.instance_variable_defined? :@dir_pathname and
          break( top_has_dpn = true )
        _mod = MetaHell::Module::Accessors::FUN.resolve[ mod, '..' ] or
          raise "can't - rootmost module (::#{ mod }) has no dir_pathname"
        mod = _mod
      end
      top_has_dpn and MAARS[ stack_a.pop ]
      while mod_ = stack_a.pop
        n = mod_.name
        mod_.module_exec do
          @dir_pathname = mod.dir_pathname.join(
            ::Skylab::Autoloader::FUN.
              pathify[ n[ n.rindex( ':' ) + 1 .. -1 ] ] )
          MAARS[ self ]
        end
        mod = mod_
      end
      nil
    end
  end
end
