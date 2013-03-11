module Skylab::MetaHell

  module Autoloader::Autovivifying::Recursive
    def self.extended mod
      mod.module_exec do
        extend Autoloader_::Methods
        @tug_class = Autoloader::Autovivifying::Recursive::Tug
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
end
