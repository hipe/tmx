module Skylab::MetaHell

  module Function

    # `MetaHell::Function` can act as an enhancer that enhances a class via
    # enabling ivars that hold procs to act as methods of the object:
    #
    #     class Foo
    #       def initialize
    #         @bar = -> { :baz }
    #       end
    #       MetaHell::Function self, :bar
    #     end
    #
    #     Foo.new.bar  # => :baz

    # You can use ivars with arbitrary names
    # like so:
    #
    #     class Foo
    #       def initialize
    #         @_secret = -> { :ting }
    #       end
    #       MetaHell::Function self, :@_secret, :wahoo
    #     end
    #
    #     Foo.new.wahoo  # => :ting

    # You can use the DSL to control visibility
    # like so:
    #
    #     class Foo
    #       def initialize
    #         @_go = -> { :yep }
    #         @_hi = -> x { "HI:#{ x }" }
    #       end
    #       MetaHell::Function.enhance( self ).as_private_getter :@_go, :yep
    #       MetaHell::Function.enhance( self ).as_public_method :_hi
    #     end
    #
    #     f = Foo.new
    #
    #     f._hi 'X' #=> "HI:X"
    #     f.yep # => NoMethodError: private method `yep' called for ..
    #

    def self.define_public_methods_on_client i_a, mod
      _make_methods mod, :public, :method, i_a
    end

    # `self._make_methods` - mutates `i_a`.

    -> do

      h = {
        getter: -> ivar, meth do
          define_method meth do
            instance_variable_get( ivar ).call
          end
        end,
        method: -> ivar, meth do
          define_method meth do |*a, &b|
            instance_variable_get( ivar ).call( *a, &b )
          end
        end
      }

      define_singleton_method :_make_methods do |
            host, public_or_private_i, getter_or_method_i, i_a |
        gets = -> { i_a.shift }
        host.module_exec do
          while i = gets[]
            if '@' == i[ 0 ]  # sorry purists
              ivar = i
              meth = gets[] or fail "sanity - method expected after #{ ivar }"
            else
              meth = i
              ivar = :"@#{ i }"
            end
            module_exec ivar, meth, & h.fetch( getter_or_method_i )
            send public_or_private_i, meth
          end
        end
        nil
      end
    end.call

    def self.enhance host
      block_given? and raise ::ArgumentError, "sanity - not yet supported"
      Shell_One_Shot_.new -> ppp, gm, i_a do
        _make_methods host, ppp, gm, i_a
      end
    end
  end

  class Function::Shell_One_Shot_

    def initialize f
      @f = f
    end

    %i| public private |.each do |ii|
      %i| getter method |.each do |jj|
        define_method "as_#{ ii }_#{ jj }" do |*a|
          @f[ ii, jj, a ]
        end
      end
    end
  end

  # Alternately you can use the struct-like producer to create an entire
  # class with this behavior like so:
  #
  #     Wahoo = MetaHell::Function::Class.new :fief
  #     class Wahoo
  #       def initialize
  #         @fief = -> { :zap }
  #       end
  #     end
  #     Wahoo.new.fief  # => :zap
  #
  # enjoy!

  class Function::Class
    class << self
      alias_method :orig_new, :new

      def new * i_a, & cls_p
        from_i_a_and_p i_a, cls_p
      end

      def from_i_a_and_p i_a, cls_p
        ::Class.new( self ).class_exec do
          class << self
            alias_method :new, :orig_new
          end
          MetaHell.Function self, * i_a
          cls_p and class_exec( & cls_p )
          self
        end
      end
    end
  end
end
