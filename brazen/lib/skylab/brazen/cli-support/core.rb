module Skylab::Brazen

  module CLI_Support

    class << self

      def standard_action_property_box_
        Standard_action_property_box___[]
      end
    end  # >>

    Standard_action_property_box___ = Callback_::Lazy.call do

      bx = Box_.new

      bx.add :help, Property.new(
        :help,
        :argument_arity, :zero,
        :desc, -> y do
          y << "this screen"
        end )

      bx.freeze
    end

    class Property  # #open [#006] what to do about this custom CLI prop class?

      # (we don't want to keep this but despite that we'll clean it up:)

      # -- initialization & dup-mutate

      def initialize name_i, * x_a
        @argument_arity = :one
        @custom_moniker = nil
        @desc = nil
        @name = Callback_::Name.via_variegated_symbol name_i
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

      # -- reflection (higher-to-lower-level)

      def under_expression_agent_get_N_desc_lines expag, d=nil
        if @desc
          N_lines_[ [], d, [ @desc ], expag ]
        end
      end

      # ~ simple derived properties

      def is_effectively_optional_  # explained in [#006]

        # since these have no defaults, it is simply a function of:

        ! is_required
      end

      def name_symbol
        @name.as_variegated_symbol
      end

      def has_custom_moniker
        @custom_moniker
      end

      def has_description
        @desc
      end

      def takes_argument  # zero to many takes argument
        :zero != @argument_arity
      end

      def argument_is_required
        :one == @argument_arity || :one_or_more == @argument_arity
      end

      def takes_many_arguments
        :zero_or_more == @argument_arity || :one_or_more == @argument_arity
      end

      # ~ direct properties

      attr_reader(
        :argument_arity,
        :argument_moniker,
        :custom_moniker,
        :desc,
        :is_required,
        :name,
        :parameter_arity,
      )

      # ~ constant properties

      def has_default
        NIL_
      end

      def has_primitive_default
        NIL_
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

    FILE_SEPARATOR_BYTE = ::File::SEPARATOR.getbyte 0
    GENERIC_ERROR_EXITSTATUS = 5
    Here_ = self
    MAX_DESC_LINES = 2
    SHORT_HELP = '-h'.freeze
    SUCCESS_EXITSTATUS = 0
  end
end
