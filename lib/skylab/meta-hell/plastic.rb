module Skylab::MetaHell

  module Plastic
    # #experimental.  Simply create an object whose singleton class
    # has a `define_method` method that has been made public, and
    # other fluff around it. Useful for quick and dirty metaprogramming.
    #
    # Alternate names for this that have been or are
    # being considered include: `Generic`, `Dynamic`
    #
    # (this will be re-evaluated at [#009] about define_singleton_methods)
  end

  class Plastic::Instance
    class << self
      public :define_method

      def [] h                    # convenience wrapper for below
        MetaHell::FUN.hash2instance[ h ]
      end
    end
  end
end
