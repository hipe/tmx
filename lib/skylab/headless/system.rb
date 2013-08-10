module Skylab::Headless

  module System

    # provides system reflection and environment info in a zero-configuration
    # manner, e.g things like where a cache dir or a temp dir that can be
    # used is, for whatever specific system we are running on.
    #
    # the whole premise of this node is dubious; but its implementation is so
    # neato that it makes it worth it. at worst it puts tracking leashes on
    # all of its uses throughout the system until we figure out what the
    # 'Right Way' is.

    module InstanceMethods
    private
      def system
        @system ||= System::Client_.new
      end
    end

    define_singleton_method :system, MetaHell::FUN.memoize_to_const_method[
      -> { System::Client_.new }, :SYSTEM_CLIENT_ ]

    def self.defaults
      System::DEFAULTS_
    end
  end
end
