module Skylab::Callback

  Session = ::Module.new

  module Session::Ivars_with_Procs_as_Methods


    # enhance a class via enabling ivars to hold procs that act as methods
    #
    #     class Foo
    #       def initialize
    #         @bar = -> { :baz }
    #       end
    #       Subject_[ self, :bar ]
    #     end
    #
    #     Foo.new.bar  # => :baz


    # you can indicate an ivar with a name other than the method name:
    #
    #     class Bar
    #       def initialize
    #         @_secret = -> { :ting }
    #       end
    #       Subject_[ self, :@_secret, :wahoo ]
    #     end
    #
    #     Bar.new.wahoo  # => :ting


    # you can use the DSL to control visibility
    #
    #     class Baz
    #       def initialize
    #         @_go = -> { :thats_right }
    #         @_hi = -> x { "HI:#{ x }" }
    #       end
    #
    #       Subject_[ self ].as_public_method :_hi
    #
    #       Subject_[ self ].as_private_getter :@_go, :yep
    #
    #     end
    #
    #     foo = Baz.new
    #
    #     foo._hi( 'X' ) #=> "HI:X"
    #     foo.yep  # => NoMethodError: private method `yep' called for ..
    #     foo.send( :yep )  # => :thats_right
    #


    # you can use the struct-like producer to create the class automatically
    #
    #     Wahoo = Subject_[].new :fief do
    #       def initialize
    #         @fief = -> { :zap }
    #       end
    #     end
    #
    #     Wahoo.new.fief  # => :zap
    #
    # enjoy!


    class << self

      def [] * a
        call_via_arglist a
      end

      def call * a
        call_via_arglist a
      end

      def new * i_a, & p
        cls = ::Class.new Base__
        via_client_and_iambic cls, i_a
        p and cls.class_exec( & p )
        cls
      end

      def call_via_arglist a
        case 1 <=> a.length
        when -1 ; via_client_and_iambic a.shift, a
        when  0 ; shell_for a.first
        else    Session::Ivars_with_Procs_as_Methods
        end
      end

    private

      def shell_for mod
        One_Shot_Shell__.new do |ppp, gm, i_a|
          define_methods mod, ppp, gm, i_a
        end
      end

      def via_client_and_iambic mod, i_a
        define_methods mod, :public, :method, i_a
      end
    end

    Base__ = ::Class.new  # just helps you track the origins of things

    class One_Shot_Shell__

      def initialize & p
        @p = p
      end

      %i| public private |.each do |ii|
        %i| getter method |.each do |jj|
          define_method "as_#{ ii }_#{ jj }" do |*a|
            @p[ ii, jj, a ]
          end
        end
      end
    end

    define_singleton_method :define_methods, -> do

      _OP_H = {
        getter: -> ivar, meth_i do
          define_method meth_i do
            instance_variable_get( ivar ).call
          end
        end,
        method: -> ivar, meth_i do
          define_method meth_i do |*a, &p|
            instance_variable_get( ivar ).call( *a, &p )
          end
        end
      }

      -> mod, public_or_private_i, getter_or_method_i, i_a do
        gets = -> { i_a.shift }
        ( mod.module_exec do
          while i = gets[]
            if AT__ == i[ 0 ]
              ivar = i
              meth_i = gets[]
              meth_i or raise ::ArgumentError, "method expected after #{ ivar }"
            else
              meth_i = i
              ivar = :"@#{ i }"
            end
            module_exec ivar, meth_i, & _OP_H.fetch( getter_or_method_i )
            send public_or_private_i, meth_i
          end
        end ) ; nil
      end
    end.call

    AT__ = '@'.freeze

  end
end
