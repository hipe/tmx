module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Solution_via_Parameters_and_Function_Path_and_Collection

      # (experimental, born during re-arch. a lot like [#ba-047].)

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def function_symbol_stack= x
        @_invo_stream = :__function_invocation_stream_via_function_symbol_stack
        @function_symbol_stack = x
      end

      attr_writer(
        :parameters,
        :function_path,
        :collection,
      )

      def execute

        ps = @parameters  # ("parameter store")

        st = send @_invo_stream
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

      def __function_invocation_stream_via_function_symbol_stack

        sym_a = @function_symbol_stack
        p = @collection.proc_for_read_function_item_ticket_via_const
        p_ = @collection.proc_for_read_function_item_via_function_item_ticket

        Common_::Stream.via_range( sym_a.length - 1 .. 0 ) do |d|

          _sym = sym_a.fetch d

          it = p[ _sym ]

          Function_Invocation___.new p_[ it ], it
        end
      end

      # ==

      class Function_Invocation___

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
