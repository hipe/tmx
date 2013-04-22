module Skylab::MetaHell

  module Enhance

    # support for the "contained DSL" pattern (#todo wherd is that writeup?)

  end

  class Enhance::Conduit

    class << self
      alias_method :mh_new, :new
    end

    def self.raw a
      ::Class.new( self ).class_exec do

        class << self
          alias_method :new, :mh_new
        end

        a.each do |i|
          define_method i do |*aa, &b|
            @h.fetch( i )[ *aa, &b ]
          end
        end

        const_set :One_Shot_, Enhance::OneShot.new( a )

        const_set :A_, a  # exposed for hacking

        self
      end
    end

    def self.new a

      a = a.dup.freeze

      raw( a ).class_exec do

        define_method :initialize do |*aa|
          @h = ::Hash[ a.zip aa ]
        end

        self
      end
    end
  end

  class Enhance::OneShot

    # per the `enhance` pattern, make one-shot conduits easy & paranoid.
    #
    # a one-shot conduit is what we use when we do this:
    #
    #     class Foo
    #       Bar.enhance( self ).with :magic
    #     end
    #
    # instead of this:
    #
    #     clas Foo
    #       Bar.enhance self do
    #         with :magic
    #       end
    #     end
    #
    # the one-shot object is the result of the first call to `enhance`
    # above. it is designed below to be "impossible" to hack (HA)
    # and only good for one shot.

    class << self
      alias_method :meta_hell_new, :new
    end

    def self.new meth_a

      ::Class.new( self ).class_exec do

        class << self
          alias_method :new, :meta_hell_new
        end

        meth_a.each do |i|
          define_method i do |*a, &b|
            @execute[ i, a, b ]
          end
        end

        self
      end
    end

    def initialize conduit, flush
      @execute = -> meth_i, arg_a, block_b do
        @mutex = meth_i
        freeze
        r = conduit.send meth_i, * arg_a, & block_b
        flush.call
        r
      end
    end
  end
end
