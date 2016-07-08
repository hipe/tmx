module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Solution_via_Parameters_and_Function_Path_and_Collection

      # (experimental, born during re-arch. a lot like [#ba-047].)

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def function_symbol_path= x
        @_forward_m = :__forward_stream_via_path
        @_reverse_m = :__reverse_stream_via_path
        @function_symbol_path = x
      end

      def function_symbol_stack= x
        @_forward_m = :__forward_stream_via_stack
        @_reverse_m = :__reverse_stream_via_stack
        @function_symbol_stack = x
      end

      attr_writer(
        :parameters,
        :collection,
      )

      def execute

        @_did ||= _prepare

        ps = @parameters  # ("parameter store")

        st = send @_forward_m
        inv = st.gets

        begin

          # call the current function

          fun = inv.function
          if fun.respond_to? :via_magnetic_parameter_store
            x = fun.via_magnetic_parameter_store ps
          else
            a = []
            inv.item_ticket.prerequisite_term_symbols.each do |sym|
              a.push ps.read_magnetic_value sym
            end
            x = fun.call( * a )
          end

          # see if there's a next function

          inv_ = st.gets
          inv_ || break  # when none, result is 'x' (might be array eek)

          # when there's a next function, write the results
          # from that last function into the parameter store

          sym_a = inv.item_ticket.product_term_symbols
          if 1 == sym_a.length

            ps.write_magnetic_value x, sym_a.first

          else
            Home_._COVER_ME
            sym_a.each_with_index do |sym, d|
              ps.write_magnetic_value x.fetch( d ), sym
            end
          end
          inv = inv_
          redo
        end while nil
        x
      end

      def mutate_if_necessary_to_land_on sym  # very near [#ta-005]

        @_did ||= _prepare

        a = ( @_mutable_stack_array ||= __flush_to_mutable_stack )

        sym_a = a.first.item_ticket.product_term_symbols

        if ! sym_a.include? sym

          _const = @collection.const_for_A_atom_via_B_atom sym, sym_a.first

          _fit = @collection.read_function_item_ticket_via_const _const

          _f = @_read_function_via_FIT[ _fit ]

          _node = Function_Invocation__.new _f, _fit

          a[ 0, 0 ] = [ _node ]

        end
        NIL_
      end

      def _prepare
        @_read_FIT_via_const = @collection.proc_for_read_function_item_ticket_via_const
        @_read_function_via_FIT = @collection.proc_for_read_function_item_via_function_item_ticket
        ACHIEVED_
      end

      def __flush_to_mutable_stack

        remove_instance_variable :@_forward_m

        _stack_as_st = send remove_instance_variable :@_reverse_m

        mutable_array = _stack_as_st.to_a

        @function_symbol_path = nil
        @function_symbol_stack = nil
        remove_instance_variable :@function_symbol_stack
        remove_instance_variable :@function_symbol_path

        @_forward_m = :__forward_stream_via_mutable_stack_array
        @_reverse_m = :__reverse_stream_via_mutable_stack_array

        mutable_array
      end

      def __forward_stream_via_mutable_stack_array
        a = @_mutable_stack_array
        Common_::Stream.via_range( a.length - 1 .. 0 ) do |d|
          a.fetch d
        end
      end

      def __reverse_stream_via_mutable_stack_array
        Common_::Stream.via_nonsparse_array @_mutable_stack_array
      end

      def __forward_stream_via_path

        _forward_of :@function_symbol_path
      end

      def __reverse_stream_via_path

        _reverse_of :@function_symbol_path
      end

      def __forward_stream_via_stack

        _reverse_of :@function_symbol_stack
      end

      def __reverse_stream_via_stack

        _forward_of :@function_symbol_stack
      end

      def _forward_of ivar

        _go Common_::Stream.via_nonsparse_array instance_variable_get ivar
      end

      def _reverse_of ivar

        sym_a = instance_variable_get ivar
        _st = Common_::Stream.via_range( sym_a.length - 1 .. 0 ) do |d|
          sym_a.fetch d
        end
        _go _st
      end

      def _go sym_st

        p = @_read_FIT_via_const
        p_ = @_read_function_via_FIT

        sym_st.map_by do |sym|

          if sym.respond_to? :call

            custom = sym[]
            Function_Invocation__.new custom.function, custom
          else
            it = p[ sym ]
            Function_Invocation__.new p_[ it ], it
          end
        end
      end

      # ==

      class Function_Invocation__

        def initialize x, it
          @function = x
          @item_ticket = it
        end

        attr_reader(
          :function,
          :item_ticket,
        )
      end

      # ==
    end
  end
end
# #history: born during rewrite
