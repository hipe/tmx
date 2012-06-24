require_relative '../../../skylab'

module Skylab::MetaHell
  module Autoloader
  end
  class AutovivifiedModel < ::Module
    attr_accessor :dir_path
    def initialize dir_path
      @dir_path = dir_path
    end
  end
  module Autoloader::Autovivifying
    include Skylab::Autoloader
    def self.extended mod
      mod.autoloader_init! caller[0]
    end
    alias_method :autoloader_no_such_file, :no_such_file
    def no_such_file path, const
      File.directory?(path) or return autoloader_no_such_file(path, const)
      const.to_s == constantize(path.match(%r{(?<=^#{Regexp.escape(dir.to_s)}/).+})[0]) or fail('sanity check')
      const_set(const, AutovivifiedModel.new(path).extend(Autoloader::Autovivifying))
    end
  end
end
