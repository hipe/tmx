module Skylab::Headless

  class Arity < ::Module

    # i am pleased to offer an awesome addition to headless, emigrated in
    # from face, and documented (heavily) at [#fa-024] and some supporting
    # essays. this moved here basically because we found ourselves making
    # lookup hashes with the same metadata in multiple places.

    # part of the point of this is to reduce the scope of arity: to think
    # of it as less than an unbounded range and more of: what are the fewest
    # number of questions we can ask of an arity to get most of the utility
    # from it. we are looking for the global maxima on the derivative between
    # effort and utility. we are looking for multiplier effects.

    # the particular implementation of this relatively simple thing is a point
    # of some experimentation, however. suffice it to say the only part of
    # its public API that is semi-stable (for some definition of stable) is
    # what is covered by the specs.

    # a dirty secret is that Arity subclasses ::Module for fun awesome
    # hackiness, but hopefully this won't affect you if you are e.g making
    # custom arities..

    def initialize i, includes_zero, is_unbounded, desc
      @normalized_name, @includes_zero, @is_unbounded, @desc =
        i, includes_zero, is_unbounded, desc.freeze
      if :zero == i
        def self.is_zero? ; true end
      end
      freeze
    end

    def is_zero?
      false
    end

    define_extent = -> f do
      name_a = [ ] ; obj_a = [ ] ;  h = { }
      f[ -> *a do
        o = new( *a )
        name_a << ( nn = o.normalized_name )
        obj_a << o
        h[ nn ] = o
      end ]
      NAMES_ = name_a.freeze ; EACH_ = obj_a.freeze ; h.freeze
      define_singleton_method :fetch do |i, &b|
        h.fetch i, &b
      end
      class << self
        alias_method :[], :fetch
      end
      nil
    end

    define_extent[ -> define do

      attr_reader        :normalized_name, :includes_zero, :is_unbounded, :desc

      ZERO         = define[ :zero,         true,           false, '0' ]
      ZERO_OR_ONE  = define[ :zero_or_one,  true,           false, '[0..1]' ]
      ZERO_OR_MORE = define[ :zero_or_more, true,           true , '[0..]' ]
      ONE          = define[ :one,          false,          false, '1' ]
      ONE_OR_MORE  = define[ :one_or_more,  false,          true , '[1..]' ]

   end ]

    # usage:
    #
    #     Headless::Arity::NAMES_ # => [ :zero, :zero_or_one, :zero_or_more, :one, :one_or_more ]
    #     Headless::Arity::EACH_.first.normalized_name  # => :zero
    #     Headless::Arity[ :one_or_more ].is_unbounded  # => true

  end
end
