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
      _md = path.match(%r{(?<=^#{Regexp.escape(dir.to_s)}/).+}) or
        fail("sanity check: expecting #{dir} to be at head of #{path}")
      constantize(_md[0]).downcase == const.to_s.downcase or
        fail("sanity check: does #{_md[0]} isomorph #{const}?")
      const_set(const, AutovivifiedModel.new(path).
        extend(Autoloader::Autovivifying))
    end
  end
end
