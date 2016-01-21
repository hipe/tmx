module Skylab::Autonomous_Component_System

  module Operation

    class Proc_based_Implementation___

      def initialize p, fo
        @formal = fo
        @_p = p
      end

      def deliverable_via_selecting_session o

        @_formal_params_index ||= Formal_Params_Index___.new self
        Build_deliverable___.new( o, self ).execute
      end

      # -- sub-clients

      attr_reader(
        :formal,
        :_formal_params_index,
        :_p,
      )

      class Build_deliverable___

        def initialize o, impl
          @argument_stream = o.argument_stream
          @_foz = impl._formal_params_index
          @_p = impl._p
          @pp_ = o.pp_
          @selection_stack = o.selection_stack
        end

        def execute  # this finishes constructing the bound call..

          bx = @_foz.box
          a = @selection_stack

          o = Home_::Parameter::Box_via_Argument_Stream.new(
            @argument_stream, a, @_foz )

          if 1 == bx.length

            # having only one formal argument is a special case: for these
            # (for now) we do NOT support the use of named argument(s).

            o.current_symbol = bx.at_position( 0 ).name_symbol
          end

          _args = o.execute

          Here_::Delivery_::Deliverable.new a, _args, @_p, :call, & @pp_
        end
      end

      class Formal_Params_Index___

        def initialize impl

          @box = ACS_::Parameter::Box_via_platform_params_and_metadata[
            impl._p.parameters,
            impl.formal,
          ]
        end

        attr_reader(
          :box,
        )
      end
    end
  end
end
