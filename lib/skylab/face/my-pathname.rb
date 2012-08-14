require 'pathname'

module Skylab::Face
  class MyPathname < ::Pathname
    include ::Skylab::Face::PathTools::InstanceMethods
    def bare ; to_s.sub(/\.rb$/, '') end
    def join(*a) ; self.class.new(super(*a)) end # waiting for ruby patch :(
    def pretty ; pretty_path(to_s) end
  end
end
