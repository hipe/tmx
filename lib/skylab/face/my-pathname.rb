require 'pathname'

module Skylab::Face

  class MyPathname < ::Pathname

    include Face::PathTools::InstanceMethods

    def join *a  # waiting for ruby patch :(  (as of 1.9.2p290)
      x = super(* a)
      r = self.class.new x
      r
    end

    def pretty
      pretty_path to_s
    end
  end
end
