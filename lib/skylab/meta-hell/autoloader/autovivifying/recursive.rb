module Skylab::MetaHell

  module Autoloader::Autovivifying::Recursive

    Methods = Autoloader::Methods

    def self.[] mod, *a
      loc = if a.length.zero?
        caller_locations( 1, 1 )[ 0 ]
      elsif (( x = a[ 0 ] )) and x.respond_to? :base_label
        a.shift
      else
        :deferred
      end
      _enhance mod, * loc
      if a.length.nonzero?
        1 == a.length and :deferred == a[ 0 ] or fail "sanity - currently #{
          }'deferred' is the only bundle option - had #{ a[ 0 ] }"
        mod.module_exec( & Bundles__::Deferred )
      end
      nil
    end
    define_singleton_method :_enhance, & Autoloader::Enhance_

    module Bundles__
      Deferred = -> do
        singleton_class.class_exec do
          alias_method :_, :dir_pathname
          undef_method :dir_pathname
          define_method :dir_pathname do
            singleton_class.class_exec do
              undef_method :dir_pathname
              alias_method :dir_pathname, :_
            end
            Upwards[ self ]
            @dir_pathname
          end
        end
      end
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
          if dir_pathname.nil?  # let module graphs charge passively
            init_dir_pathname tug.branch_pathname  # just after file load
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

    def self.[] mod  # #re-entrant
      Flush_stack__[ Build_stack_from_mod__[ mod ] ]
    end

    def self.to mod  # in contrast to above, this form mutates client module
      # regardless of whether it already responds to dir_pathname
      Flush_stack_[
        Build_stack_from_2_mods__[ mod, Surrounding_module__[ mod ] ] ]
    end

    Build_stack_from_2_mods__ = -> mod1, mod do
      stack_a = [ * mod1 ] ; top_has_dpn = false
      while ! ( mod.respond_to? :dir_pathname and mod.dir_pathname )
        stack_a.push mod
        mod.instance_variable_defined? :@dir_pathname and
          break( top_has_dpn = true )
        mod = Surrounding_module__[ mod ]
      end
      top_has_dpn and MAARS[ stack_a.pop ]
      stack_a << mod
    end

    Build_stack_from_mod__ = Build_stack_from_2_mods__.curry[ nil ]

    Surrounding_module__ = -> mod do
      _mod = MetaHell::Module::Accessors::FUN.resolve[ mod, '..' ] or
        raise "can't - rootmost module (::#{ mod }) has no dir_pathname"
      _mod
    end

    Flush_stack__ = -> stack_a do
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
