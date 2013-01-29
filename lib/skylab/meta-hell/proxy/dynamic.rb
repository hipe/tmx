module Skylab::MetaHell

  module Plastic
    # #experimental.  Simply create an object whose singleton class
    # has a `define_method` method that has been made public, and
    # other fluff around it (or not) for quick and dirty metaprogramming.
    #
    # Alternate names for this that have been or are
    # being considered include: `Generic`, `Dynamic`
    #
    # (this will be re-evaluated at [#009] about define_singleton_methods)
    #
    # (in light of above, it is now just an ordinary empty class, will
    # might be only slighly more usefull than an ::Object.new because
    # of the name you get that might lead you here.)
    #
  end

  class Plastic::Instance
    class << self
      # public :define_method     # we did this before we knew about
                                  # define_singleton_method

      def [] h                    # convenience wrapper for below
        MetaHell::FUN.hash2instance[ h ]
      end
    end
  end
end
