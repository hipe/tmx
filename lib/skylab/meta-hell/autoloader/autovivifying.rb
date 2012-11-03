module Skylab::MetaHell
  module Autoloader::Autovivifying
    extend ::Skylab::Autoloader

    def self.extended mod
      mod.extend Autoloader::Autovivifying::ModuleMethods
      mod._autoloader_extended! caller[0] # necessary b.c. caller
    end
  end


  module Autoloader::Autovivifying::ModuleMethods
    extend ::Skylab::Autoloader::ModuleMethodsModuleMethods
    include ::Skylab::Autoloader::ModuleMethods

    def _const_missing const
      Autoloader::Autovivifying::ConstMissing.new const, dir_pathname, self
    end
  end


  class AutovivifiedModule < ::Module
    alias_method :const_defined_without_autoloader?, :const_defined? # #sl-106

    include Autoloader::Autovivifying::ModuleMethods
  end


  class Autoloader::Autovivifying::ConstMissing <
                                              ::Skylab::Autoloader::ConstMissing
    def load
      if file_pathname.exist?
        load_file
      elsif dir_pathname.exist?
        mod.const_set const, autovivified_module
      else
        raise ::NameError.new(%<uninitialized constant #{mod}::#{const} (#{
          }and no such file/directory to autoload -- #{file_pathname.dirname}/#{
          dir_pathname.basename}[#{EXTNAME}])>)
      end
      nil
    end

    def probably_loadable?
      super or dir_pathname.exist?
    end

  protected
    def autovivified_module
      o = AutovivifiedModule.new
      o.dir_path = dir_pathname.to_s
      o
    end

    def dir_pathname
      @dir_pathname ||= file_pathname.sub_ext('')
    end
  end
end
