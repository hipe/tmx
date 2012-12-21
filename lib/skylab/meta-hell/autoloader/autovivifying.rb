module Skylab::MetaHell::Autoloader

  Autoloader = self
  MetaHell = ::Skylab::MetaHell


  module Autovivifying
    extend ::Skylab::Autoloader

    Autoloader = Autoloader
    Autovivifying = self

    def self.extended mod
      mod.extend Autovivifying::ModuleMethods
      mod._autoloader_init! caller[0]
    end
  end


  module Autovivifying::ModuleMethods
    include ::Skylab::Autoloader::ModuleMethods

    def _const_missing_class
      Autovivifying::ConstMissing
    end
  end


  class Autovivifying::ConstMissing < ::Skylab::Autoloader::ConstMissing
    extend MetaHell::Let

    def load f=nil
      if file_pathname.exist?
        load_file f
      elsif dir_pathname.exist?
        mod.const_set const, build_autovivified_module
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

    def build_autovivified_module
      m = ::Module.new
      m.extend module_methods_module
      m.dir_path = dir_pathname.to_s
      m._autoloader_init! nil
      m
    end

    let( :dir_pathname ) { file_pathname.sub_ext '' }

    def module_methods_module
      Autovivifying::ModuleMethods
    end
  end
end
