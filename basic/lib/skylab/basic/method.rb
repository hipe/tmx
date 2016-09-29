module Skylab::Basic

  module Method

    class << self

      def curry
        Curry__
      end
    end

    class Curry__

      class << self
        def unbound * a
          if a.length.zero?
            Unbound__
          else
            Unbound__.new( * a )
          end
        end
      end

      # a method curry (like that other thing) binds arguments to a bound method call
      #
      #     class Foo
      #       def bar a, b
      #         "ok:#{a}#{b}"
      #       end
      #     end
      #
      #     _foo = Foo.new
      #
      #     mc = Home_::Method.curry.new _foo.method( :bar ), [ 'yes', 'sir' ]
      #
      # it's really little more than a structure holding the constituent
      # parts of a method call
      #
      #     x = mc.receiver.send mc.method_name, * mc.arguments
      #     x  # => "ok:yessir"

      def initialize method, arg_a=EMPTY_A_
        @bound_method = method
        @arguments = arg_a
      end

      def method_name
        @bound_method.name
      end

      def receiver
        @bound_method.receiver
      end

      attr_reader :arguments

      # you can validate your argument arity before the call
      #
      #     class Bar
      #       def bar x, y=nil
      #         [ x, y ]
      #       end
      #     end
      #
      #     foo = Bar.new
      #
      #     p = -> *a do
      #       mc = Home_::Method.curry.new foo.method(:bar), a
      #       errmsg = nil
      #       mc.validate_arity do |o|
      #         errmsg = "no: #{ o.actual } for #{ o.expected }"
      #       end
      #       if errmsg then errmsg else
      #         mc.receiver.send mc.method_name, * mc.arguments
      #       end
      #     end
      #
      # too many arguments:
      #
      #     p[ 1, 2, 3 ] # => "no: 3 for 1..2"
      #
      # the max number of allowed args:
      #
      #     p[ 1, 2 ]  # => [ 1, 2 ]
      #
      # the min number of allowed args:
      #
      #     p[ 1 ]  # => [ 1, nil ]
      #
      # not enough arguments:
      #
      #     p[ ]  # => "no: 0 for 1..2"

      def validate_arity
        arity = get_arity ; len = @arguments.length
        if len < arity.min or arity.max && arity.max < len
          yield Arity_Validation_Failure_.new( len, arity )
        else
          self
        end
      end
      #
      class Arity_Validation_Failure_
        def initialize actual_d, arity
          @actual_d = actual_d ; @arity = arity
        end
        def actual
          @actual_d
        end
        def expected
          @arity.as_string
        end
      end

      def parameters
        @bound_method.parameters
      end

    private

      def get_arity
        Arity.from_parameters parameters
      end

      class Unbound__
        def initialize um
          0 < um.arity or raise ::ArgumentError, "for now, arity must be #{
            }greater than or equal to 1 (had #{ um.arity }) for method #{
             }'#{ um.name }'"
          @unbound_method = um
          @curry = method :build_curried_method
        end
        attr_reader :curry
      private
        def build_curried_method * a
          um = @unbound_method
          -> * a_ do
            um.bind( self ).call( * a, * a_ )
          end
        end
      end
    end

    class Arity
      def self.from_parameters para
        count_h = para.reduce( ::Hash.new 0 ) do |m, (i, _)|
          m[ i ] += 1 ; m
        end
        min = count_h[ :req ]
        new min, ( min + count_h[ :opt ] if ! count_h.key? :rest )
      end
      class << self
        private :new
      end
      def initialize min, max
        @min = min ; @max = max
      end
      attr_reader :min, :max
      def min_max
        [ @min, @max ]
      end
      def as_string
        ( @max && @max != @min ) ? "#{ @min }..#{ @max }" : "#{ @min }"
      end
    end
  end
end
