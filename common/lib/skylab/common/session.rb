module Skylab::Common

  Session = ::Module.new

  module Session::Ivars_with_Procs_as_Methods

    # enhance a class via enabling ivars to hold procs that act as methods
    #
    #     class Foo
    #       def initialize
    #         @bar = -> { :baz }
    #       end
    #       Home_::Session::Ivars_with_Procs_as_Methods[ self, :bar ]
    #     end
    #
    #     Foo.new.bar  # => :baz

    # you can indicate an ivar with a name other than the method name:
    #
    #     class Bar
    #       def initialize
    #         @_secret = -> { :ting }
    #       end
    #       Home_::Session::Ivars_with_Procs_as_Methods[ self, :@_secret, :wahoo ]
    #     end
    #
    #     Bar.new.wahoo  # => :ting

    # you can use the DSL to control visibility
    #
    #     class Baz
    #
    #       def initialize
    #         @_go = -> { :thats_right }
    #         @_hi = -> x { "HI:#{ x }" }
    #       end
    #
    #       o = Home_::Session::Ivars_with_Procs_as_Methods
    #
    #       o[ self ].as_public_method :_hi
    #
    #       o[ self ].as_private_getter :@_go, :yep
    #     end
    #
    #     foo = Baz.new
    #
    # calling this public method works:
    #
    #     foo._hi( 'X' ) # => "HI:X"
    #
    # calling this private method does not:
    #
    #     foo.yep  # => NoMethodError: private method `yep' called for ..
    #
    # but privately you can still call it:
    #
    #     foo.send( :yep )  # => :thats_right
    #

    # you can use the struct-like producer to create the class automatically
    #
    #     Wahoo = Home_::Session::Ivars_with_Procs_as_Methods.new :fief do
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
        edit_module_via_iambic cls, i_a
        p and cls.class_exec( & p )
        cls
      end

      def call_via_arglist a

        case 1 <=> a.length
        when -1
          edit_module_via_iambic a.shift, a
        when 0
          shell_for a.first
        else
          Session::Ivars_with_Procs_as_Methods
        end
      end

    private

      def shell_for mod
        One_Shot_Shell__.new do |ppp, gm, i_a|
          define_methods mod, ppp, gm, i_a
        end
      end

      def edit_module_via_iambic mod, i_a
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
