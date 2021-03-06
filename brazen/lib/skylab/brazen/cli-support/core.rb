module Skylab::Brazen

  module CLI_Support

    class << self

      def standard_action_property_box_
        Standard_action_property_box___[]
      end

      def standard_branch_property_box
        Standard_branch_property_box___[]
      end
    end  # >>

    option_argument_moniker_via_variegated_string = nil

    Option_argument_moniker_via_property = -> prp do
      s = prp.option_argument_moniker
      if s
        s
      else
        option_argument_moniker_via_variegated_string[
          prp.name.as_variegated_string ]
      end
    end

    term = '[a-z][a-z0-9]+'
    hack_rx = /\A <(?:#{ term }-)*(?<main>#{ term })>\z/i

    second_try_rx = nil

    Option_argument_moniker_via_switch = -> sw_o do

      # for its production syntax strings related to o.p, the syntax assembly
      # uses only the stdlib o.p as input. as such we have to reverse-infer
      # the same argument moniker (if any custom) from the o.p that came from
      # the formal. (and we do the shortening heuristic used elsewhere in
      # this document.)

      md = hack_rx.match sw_o.arg
      if  md

        md[ :main ].upcase

      else

        second_try_rx ||= /(?<=\A )[A-Z]+\z/
        md = second_try_rx.match sw_o.arg

        if md
          md[ 0 ]
        else

          sw_o.arg  # [cc]
        end
      end
    end

    option_argument_moniker_via_variegated_string = -> s do

      s.split( UNDERSCORE_ ).last.upcase
    end

    Standard_branch_property_box___ = Lazy_.call do

      _Property = Modality_Specific_Property

      bx = Box_.new

      bx.add :action, _Property.new( :action, :is_required, true )

      bx.add :help, _Property.new( :help,

        :description_proc, -> y do
          y << 'this screen (or help for action)'
        end,

        :option_argument_moniker, 'cmd',
        :parameter_arity, :zero_or_one,
        :argument_arity, :zero_or_one,  # #[#002.G]
      )

      bx.freeze
    end

    Standard_action_property_box___ = Common_::Lazy.call do

      bx = Box_.new

      bx.add :help, Modality_Specific_Property.new(

        :help,

        :description_proc, -> y do
          y << "this screen"
        end,

        :argument_arity, :zero,
        :parameter_arity, :zero_or_one,
      )

      bx.freeze
    end

    param_arity = {
      optional: :zero_or_one,
      required: :one,
    }

    Didactic_glyph = -> sym, moniker, debugging_symbol do

      Modality_Specific_Property.new(
        debugging_symbol,
        :argument_argument_moniker, moniker,
        :argument_arity, :one,
        :parameter_arity, param_arity.fetch( sym ),
      )
    end

    class Modality_Specific_Property

      # #open [#006] what to do about this custom CLI prop class?

      def initialize name_sym, * x_a

        @name = Common_::Name.via_variegated_symbol name_sym

        @argument_arity = :one

        @parameter_arity = :one

        x_a.each_slice( 2 ) do |i, x|
          instance_variable_set :"@#{ i }", x
        end

        freeze
      end

      def dup_by & edit_p
        otr = dup
        otr.instance_exec( & edit_p )
        otr
      end

      # -- #[#fi-010]

      def name_symbol
        @name.as_variegated_symbol
      end

      attr_reader(
        :option_argument_moniker,
        :argument_argument_moniker,
        :name,
        :description_proc,
        :default_proc,
        :parameter_arity,
        :argument_arity,
      )

      def parameter_arity_is_known  # necessary because [#fi-002.4]
        TRUE
      end
    end

    class As_Bound_Call

      def receiver
        self
      end

      def method_name
        :produce_result
      end

      def args
        NIL_
      end

      def block
        NIL_
      end
    end

    module Option_Parser
      # (here because the would-be corefile is an orphan)
      Autoloader_[ self ]
    end

    Actions = nil  # [#062]
    GENERIC_ERROR_EXITSTATUS = 5
    Here_ = self
    MAX_DESC_LINES = 2
    SHORT_HELP = '-h'.freeze
    SUCCESS_EXITSTATUS = 0
  end
end
