module Skylab::Common

  class Emission  # :[#003.2]

    class Interpreter

      define_singleton_method :common, ( Lazy_.call do

        class Common_Emission_Interpreter____ < self

          def __conventional__ i_a, & ev_p
            _ :receive_conventional_emission, i_a, & ev_p
          end

          def __expression__ i_a, & y_p
            _ :receive_expression_emission, i_a, & y_p
          end

          self
        end.new
      end )

      def initialize

        @on_conventional = method :__conventional__
        @on_data = method :__data__
        @on_expression = method :__expression__
        freeze
      end

      attr_writer(
        :on_conventional,
        :on_data,
        :on_expression,
      )

      def _call i_a, & x_p
        instance_variable_get( _category_for( i_a ).ivar )[ i_a, & x_p ]
      end

      alias_method :[], :_call
      alias_method :call, :_call

      def shape_of i_a
        _category_for( i_a ).name_symbol
      end

      h = nil
      define_method :_category_for do | i_a |
        h[ ( i_a[ 1 ] if i_a ) ]
      end

      Category__ = ::Struct.new :ivar, :name_symbol
      o = Category__

      h = ::Hash.new o[ :@on_conventional, :CONVENTIONAL_EMISSION_SHAPE ]

      h[ :data ] = o[ :@on_data, :DATA_EMISSION_SHAPE ]

      h[ :expression ] = o[ :@on_expression, :EXPRESSION_EMISSION_SHAPE ]

      def _ m, * args, & x_p
        Home_::BoundCall.via_args_and_method_name args, m, & x_p
      end

      # --

      def __data__ i_a, & x_p
        fail ___say_no_handler( i_a )
      end

      def ___say_no_handler i_a
        "emission interpreter must define a handler for #{ i_a.inspect }"
      end
    end

    # --

    class << self
      def of * i_a, & ev_p
        via_category i_a, & ev_p
      end
      alias_method :via_category, :new
      private :new
    end  # >>

    def initialize i_a, & ev_p
      @category = i_a
      @emission_value_proc = ev_p
    end

    attr_reader(
      :category,
      :emission_value_proc,
    )
  end
end
