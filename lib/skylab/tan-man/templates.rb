module Skylab::TanMan
  module Templates
    @cache = { }
  end
  class << Templates
    def [] stem
      pathname = dir_pathname.join(stem) # it normalizes various paths
      @cache[pathname.to_s] ||= TanMan::Template.from_pathname(pathname)
    end
    attr_accessor :dir_pathname
  end
  Templates.dir_pathname =
    ::Pathname.new(::File.expand_path('../templates', __FILE__))
end
