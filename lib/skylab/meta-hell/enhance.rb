module Skylab::MetaHell

  module Enhance

    # support for the "contained DSL" pattern (#todo wherd is that writeup?)

  end

  class Enhance::Shell

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

        define_singleton_method :to_struct, & FUN_.to_struct
        define_singleton_method    :struct, & FUN_.struct

        self
      end
    end

    def self.new *a
      a = a.flatten.freeze

      raw( a ).class_exec do

        define_method :initialize do |*aa|
          @h = ::Hash[ a.zip aa ]
        end

        self
      end
    end
  end

  Enhance::Shell::FUN_ = -> do

    o = { }

    # `to_struct` - this is defined as a "class method" on the generated
    # shell class. pass it a `def_blk` - type function and it will result
    # in a struct with members corresponding to the members of the shell,
    # with each "macro" strictly taking one argument.

    o[:to_struct] = -> f do
      st = struct.new
      new( * const_get( :A_, false ).map do |i|
        -> x do
          st[ i ] = x
          nil  # change it if needed
        end
      end ).instance_exec( & f )
      st
    end

    o[:struct] = -> do
      if const_defined? :Struct_, false
              const_get :Struct_, false
      else    const_set :Struct_, ::Struct.new( * const_get( :A_, false ) )
      end
    end

    ::Struct.new( * o.keys ).new( * o.values )

  end.call

  class Enhance::OneShot

    # per the `enhance` pattern, make one-shot shells easy & paranoid.
    #
    # a one-shot shell is what we use when we do this:
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

    -> do  # `initialize`
      h = {

        # 2-arg form -
        # initialize with the shell object this one shot is a one-shot of,
        # and a callback function that flushes

        2 => -> cnd, flsh do
          [ cnd, flsh ]
        end,

        # 1-arg form -
        # your one-shot exists to serve exactly one DSL input (method).
        # `func` will be called with the (necessarily) one argument
        # that that input (method) receives.

        1 => -> func do
          cnd_kls = MetaHell_._lib.module_lib.value_via_relative_path self.class, '..'
          ex = nil
          cnd = cnd_kls.new -> x do
            ex = x
          end
          flsh = -> do
            func[ ex ]
            nil
          end
          [ cnd, flsh ]
        end
      }
      define_method :initialize do |* shell_flush_a|
        shell, flush = instance_exec( * shell_flush_a, &
          h.fetch( shell_flush_a.length ) )
        @execute = -> meth_i, arg_a, block_b do
          @mutex = meth_i
          freeze
          r = shell.send meth_i, * arg_a, & block_b
          flush.call
          r
        end
      end
    end.call

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
  end
end
