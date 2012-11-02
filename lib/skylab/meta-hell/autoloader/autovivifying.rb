require_relative '../../../skylab'

module Skylab::MetaHell
  module Autoloader end
  module Autoloader::Autovivifying
    def self.extended mod
      mod.extend Autoloader::Autovivifying::ModuleMethods
      mod._autoloader_init! caller[0] # necessary to duplicate this bc "caller"
    end
  end
  module Autoloader::Autovivifying::ModuleMethods
    include ::Skylab::Autoloader::ModuleMethods
    def _const_missing const
      Autoloader::Autovivifying::ConstMissing.new const, dir_pathname, self
    end
  end
  class AutovivifiedModule < ::Module
    include Autoloader::Autovivifying::ModuleMethods
    def initialize dir_path
      @dir_path = dir_path
    end
  end
  class Autoloader::Autovivifying::ConstMissing <
    ::Skylab::Autoloader::ConstMissing

    def load
      if file_pathname.exist?
        load_file
      elsif dir_pathname.exist?
        o = AutovivifiedModule.new(dir_pathname.to_s)
        mod.const_set(const, o)
      else
        raise ::LoadError.new("no such file to load -- #{file_pathname}")
      end
    end

  protected
    def dir_pathname
      @dir_pathname ||= file_pathname.sub_ext('')
    end
  end
end
