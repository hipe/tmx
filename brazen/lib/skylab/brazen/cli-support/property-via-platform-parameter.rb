module Skylab::Brazen

  module CLI_Support

    class Property_via_Platform_Parameter  # tiny intro at [#105]A

      def initialize opt_req_rest_sym, name_symbol

        @_name_symbol = name_symbol

        instance_exec( & H___.fetch( opt_req_rest_sym ) )

        @reqity_symbol_ = opt_req_rest_sym
      end

      # -- #[#fi-010]

      def description_proc
        NOTHING_  # there is no isomorph from the substrate to this
      end

      def option_argument_moniker  # this one [br] expansion
        NOTHING_
      end

      def argument_argument_moniker  # ditto
        NOTHING_
      end

      def name
        @___nf ||= ___build_name_function
      end

      def ___build_name_function

        s = @_name_symbol.id2name
        Callback_::Name::Modality_Functions::
          Mutate_string_by_chomping_any_trailing_name_convention_suffixes[ s ]

        Callback_::Name.via_variegated_symbol s.downcase.intern
      end

      def default_proc
        NIL_  # we can't reflect on default arguments
      end

      H___ = {

        opt: -> do  # "flag"
          @parameter_arity = :zero_or_one
          @argument_arity = :zero ; nil
        end,

        req: -> do  # regular argument
          @parameter_arity = :one
          @argument_arity = :one
        end,

        rest: -> do  # "glob"
          @parameter_arity = :zero_or_more
          @argument_arity = :one
        end
      }

      attr_reader(

        :parameter_arity,
        :argument_arity,

        :reqity_symbol_,  # internally convenient to preserve this
      )
    end
  end
end

# #tombstone: variegated_human_symbol_via_variable_name_symbol (absorbed here)
