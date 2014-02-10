module Skylab::Callback

  module Autoloader

    class Const_Reduction__  # doc is spec, 100% covered, three laws compliant

      Dispatch = -> a, p do
        if a.length.zero?
          if p
            new.process_block p
          else
            Proc_  # curriable form
          end
        else
          Proc_[ * a, &p ]
        end
      end

      def initialize
        @try_these_const_method_i_a = ALL_CONST_METHOD_I_A__
        @else_p = nil
      end

      ALL_CONST_METHOD_I_A__ = %i( as_const as_camelcase_const ).freeze

      Proc_ = -> const_i_a, mod, & p do
        shell = Shell_.new( kernel = new )
        shell.const_path const_i_a
        shell.from_module mod
        p and shell.else( & p )
        kernel.flush
      end

      def process_block p
        shell = Shell_.new self
        if p.arity.zero?
          shell.instance_exec( & p )
        else
          p[ shell ]
        end
        flush
      end

      class Shell_
        def initialize kernel
          @write_const_path = -> x { kernel.const_path = x }
          @write_else_p = -> x { kernel.else_p = x }
          @write_from_module = -> x { kernel.from_module = x }
        end
        def const_path x
          @write_const_path[ x ] ; nil
        end
        def else &p
          @write_else_p[ p ] ; nil
        end
        def from_module x
          @write_from_module[ x ] ; nil
        end
      end

      attr_writer :const_path, :else_p, :from_module

      def flush
        @const_path.length.times.reduce @from_module do |mod, d|
          procure_some_valid_name @const_path.fetch d or break @result
          step mod or break @result
        end
      end
    private
      def procure_some_valid_name token_x
        @name = Name.from_variegated_symbol token_x
        @const_i = @name.as_const or when_cannot_construe_valid_const
      end
      def when_cannot_construe_valid_const
        @exception = ::NameError.
          new say_cannot_construe, @name.as_variegated_symbol
        flush_exception
        CEASE_
      end
      def say_cannot_construe
        "wrong constant name #{ @name.as_variegated_symbol } for const reduce"
      end
      def flush_exception
        @else_p && 1 == @else_p.arity or raise @exception
        @result = @else_p[ @exception ] ; nil
      end
      def step mod
        const_i = @try_these_const_method_i_a.reduce nil do |_, const_method_i|
          const = @name.send const_method_i
          mod.const_defined? const, false and break const
        end
        if const_i
          mod.const_get const_i, false
        else
          @mod = mod
          when_const_not_defined
        end
      end
      def when_const_not_defined
        @else_p or raise build_name_error
        @result = if @else_p.arity.zero?
          @else_p[]
        else
          @else_p[ build_name_error ]
        end
        CEASE_
      end
      def build_name_error
        Name_Error__.new @mod, @name.as_variegated_symbol
      end

      class Name_Error__ < ::NameError
        def initialize mod, received_name_i
          @module = mod
          super "uninitialized constant #{ mod }::( ~ #{
            received_name_i } )", received_name_i
        end
        attr_reader :module
      end

      CEASE_ = false
    end
  end
end
