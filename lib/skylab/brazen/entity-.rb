module Skylab::Brazen

  Entity_ = Brazen_::Entity[ -> do

    o :meta_property, :argument_arity,
        :enum, [ :zero, :one ],
        :default, :one


    o :meta_property, :default, :entity_class_hook, -> cls, prop do

      cls.add_iambic_event_listener :iambic_normalize_and_validate,

        -> obj do
          obj.aply_dflt_proc_if_necessary prop ; nil
        end

    end

    o :meta_property, :parameter_arity,
        :enum, [ :zero_or_one, :one ],
        :default, :zero_or_one


    property_class_for_write  # flush the above to get the below

    class self::Property

      def initialize( * )
        @desc_p_a = nil
        @default = nil
        super
      end

      def has_default
        ! @default.nil?
      end

      def has_description
        ! @desc_p_a.nil?
      end

      def get_description_lines expression_agent
        a = []
        @desc_p_a.each do |p|
          expression_agent.instance_exec a, & p
        end
        a
      end

      def is_required
        :one == @parameter_arity
      end

      def takes_argument
        :one == @argument_arity
      end

      o do

        o :iambic_writer_method_name_suffix, :'='

        def description=
          x = iambic_property
          if x.respond_to? :ascii_only?
            str = x
            x = -> y { y << str }
          end
          ( @desc_p_a ||= [] ).push x
        end

        def flag=
          @argument_arity = :zero
        end

        def required=
          @parameter_arity = :one
        end
      end
    end
  end ]

  module Entity_
    def aply_dflt_value_if_necessary prop
      ivar = prop.as_ivar
      if ! instance_variable_defined? ivar ||
          instance_variable_get( ivar ).nil?
        instance_variable_set ivar, prop.default
      end ; nil
    end
  end
end
