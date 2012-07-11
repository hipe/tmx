require 'pathname'

module Skylab::Face
  class MyPathname < ::Pathname
    include ::Skylab::Face::PathTools
    def join *a
      self.class.new(super(*a)) # awful! waiting for patch for ruby maybe?
    end
    def pretty
      pretty_path to_s
    end
  end
end
