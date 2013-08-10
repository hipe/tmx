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
      Flush_stack_[ Build_stack_from_mod_[ mod ] ]
    end

    def self.to mod  # in contrast to above, this form mutates client module
      # regardless of whether it already responds to dir_pathname
      Flush_stack_[
        Build_stack_from_2_mods_[ mod, Surrounding_module_[ mod ] ] ]
    end

    Build_stack_from_2_mods_ = -> mod1, mod do
      stack_a = [ * mod1 ] ; top_has_dpn = false
      while ! ( mod.respond_to? :dir_pathname and mod.dir_pathname )
        stack_a.push mod
        mod.instance_variable_defined? :@dir_pathname and
          break( top_has_dpn = true )
        mod = Surrounding_module_[ mod ]
      end
      top_has_dpn and MAARS[ stack_a.pop ]
      stack_a << mod
    end

    Build_stack_from_mod_ = Build_stack_from_2_mods_.curry[ nil ]

    Surrounding_module_ = -> mod do
      _mod = MetaHell::Module::Accessors::FUN.resolve[ mod, '..' ] or
        raise "can't - rootmost module (::#{ mod }) has no dir_pathname"
      _mod
    end

    Flush_stack_ = -> stack_a do
      mod = stack_a.pop
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
