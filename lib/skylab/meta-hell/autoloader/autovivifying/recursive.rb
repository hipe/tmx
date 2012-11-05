module Skylab::MetaHell
  module Autoloader::Autovivifying::Recursive

    def self.extended mod
      mod.extend Autoloader::Autovivifying::Recursive::ModuleMethods
      mod._autoloader_extended! caller[0] # necessary b.c. caller
    end
  end


  module Autoloader::Autovivifying::Recursive::ModuleMethods
    extend ::Skylab::Autoloader::ModuleMethodsModuleMethods
    include Autoloader::Autovivifying::ModuleMethods

    def _const_missing_class
      Autoloader::Autovivifying::Recursive::ConstMissing
    end
  end

  class Autoloader::Autovivifying::Recursive::AutovivifiedModule <
                                                              AutovivifiedModule
    include Autoloader::Autovivifying::Recursive::ModuleMethods
  end

  class Autoloader::Autovivifying::Recursive::ConstMissing <
                                         Autoloader::Autovivifying::ConstMissing

  protected
    def autovivified_module
      o = Autoloader::Autovivifying::Recursive::AutovivifiedModule.new
      o.dir_path = dir_pathname.to_s
      o
    end

    def load_file
      super
      o = mod.const_get const, false
      if o.respond_to? :dir_path
        if o.dir_path
          # possibly a module that explicitly extended an autoloader of its
          # own for whatever nefarious reasons
        else
          set_dir_path = true
          # it might not be set in the case of if you have a child class
          # of a parent class that is "infected" with this recursive hack
        end
      else
        o.extend Autoloader::Autovivifying::Recursive::ModuleMethods
        set_dir_path = true
      end
      if set_dir_path
        o.dir_path = normalized # you loaded a file. *its* dirpath corresponds
        # to the path you used to load the file, not *your* dir_path
      end
      true
    end
  end
end
