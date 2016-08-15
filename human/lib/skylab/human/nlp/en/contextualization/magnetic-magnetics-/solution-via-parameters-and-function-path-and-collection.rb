module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetic_Magnetics_::Solution_via_Parameters_and_Function_Path_and_Collection

      # (experimental, born during re-arch. a lot like [#ba-047].)

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def collection= col
        @_read_FIT_via_const = col.proc_for_read_function_item_ticket_via_const
        @_read_function_via_FIT = col.proc_for_read_function_item_via_function_item_ticket
        @collection = col
      end

      attr_writer(
        :function_symbol_stack,
        :parameters,
      )

      def execute

        ps = @parameters  # ("parameter store")

        stack_sym_a = @function_symbol_stack
        sym_st = Common_::Stream.via_range( stack_sym_a.length-1 .. 0 ) do |d|
          stack_sym_a.fetch d
        end

        sym = sym_st.gets
        inv = _invocation_via_symbol sym ; sym = nil
        begin

          # call the current function

          fun = inv.function
          if fun.respond_to? :via_magnetic_parameter_store
            x = fun.via_magnetic_parameter_store ps
          else
            _a = __build_arguments_for_function inv, ps
            x = fun.call( * _a )
          end

          # see if there's a next function

          sym = sym_st.gets
          sym || break  # when none, result is 'x' (might be array eek)

          # when there's a next function, write the results
          # from that last function into the parameter store

          sym_a = inv.item_ticket.product_term_symbols
          if 1 == sym_a.length

            ps.write_magnetic_value x, sym_a.first

          else
            self._COVER_ME
            sym_a.each_with_index do |sym_, d|
              ps.write_magnetic_value x.fetch( d ), sym_
            end
          end

          inv = _invocation_via_symbol sym ; sym = nil
          redo
        end while nil
        x
      end

      def __build_arguments_for_function inv, ps
        a = []
        inv.item_ticket.prerequisite_term_symbols.each do |sym|
          a.push ps.read_magnetic_value sym
        end
        a
      end

      def _USE_ME_mutate_if_necessary_to_land_on sym  # very near [#ta-005]

        @_did ||= _prepare

        a = ( @_mutable_stack_array ||= __flush_to_mutable_stack )

        sym_a = a.first.item_ticket.product_term_symbols

        if ! sym_a.include? sym

          via_sym = sym_a.first

          _const = @collection.const_for_A_atom_via_B_atom sym, via_sym

          _fit = @collection.read_function_item_ticket_via_const _const

          _f = @_read_function_via_FIT[ _fit ]

          _node = Function_Invocation__.new _f, _fit

          a.unshift _node
        end

        NIL_
      end

      def bottom_item_ticket_
        @_read_FIT_via_const[ @function_symbol_stack.fetch( 0 ) ]
      end

      def _invocation_via_symbol sym

        if sym.respond_to? :call
          custom = sym[]
          Function_Invocation__.new custom.function, custom
        else
          it = @_read_FIT_via_const[ sym ]
          Function_Invocation__.new @_read_function_via_FIT[ it ], it
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
