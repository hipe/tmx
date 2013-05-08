module Skylab::MetaHell

  module Autoloader::Autovivifying::Recursive
    def self.extended mod
      mod.module_exec do
        extend Autoloader_::Methods
        @tug_class ||= Autoloader::Autovivifying::Recursive::Tug # multi-entrant
        init_autoloader caller[2]  # the location of the call to `extend` !
      end
    end
  end

  class Autoloader::Autovivifying::Recursive::Tug <
        Autoloader::Autovivifying::Tug

    attr_reader :const

    protected

    # `load_file` - do what parent does, and (since the load didn't raise an
    # exception, it set the appropriate constant of the appropriate module --
    # the end result of autoloading), if the value of that constant can
    # define a singleton class, (i.e it's a module, a class, or even some
    # arbitrary object that can have an s.c), then we "upgrade" it to be
    # a recursive autoloader based on the straightforward nerkage below.

    def load_file after=nil
      super
      x = @mod.const_get @const, false
      do_initialize = if x.respond_to? :dir_pathname
        true
      elsif ::TypeError != ( x.singleton_class rescue ::TypeError ) # else final
        x.extend Autoloader_::Methods
        true
      end
      if do_initialize
        me = self
        x.instance_exec do
          if dir_pathname.nil?  # allow shenanigans
            init_dir_pathname me.send( :branch_pathname )
          end
          if tug_class.nil?
            @tug_class = me.class
          end
        end
      end
      true  # (in case we ever fail gracefully, future-proof it)
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
      stack_a = [ ]
      while ! ( mod.respond_to? :dir_pathname and mod.dir_pathname )
        stack_a.push mod
        _mod = MetaHell::Module::Accessors::FUN.resolve[ mod, '..' ]
        _mod or raise "can't - rootmost module (::#{ mod }) has no dir_pathname"
        mod = _mod
      end
      while mod_ = stack_a.pop
        n = mod_.name
        mod_.module_exec do
          @dir_pathname = mod.dir_pathname.join(
            ::Skylab::Autoloader::Inflection::FUN.
              pathify[ n[ n.rindex( ':' ) + 1 .. -1 ] ] )
          extend MAARS
        end
        mod = mod_
      end
      nil
    end
  end
end
