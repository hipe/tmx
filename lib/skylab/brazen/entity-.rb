module Skylab::Brazen

  Entity_ = Brazen_::Entity[ -> do

    o :meta_property, :argument_arity,
        :enum, [ :zero, :one ],
        :default, :one,
        :property_hook, -> prop do
          if :zero == prop.argument_arity
            ivar = prop.as_ivar
            prop.iambic_writer_method_proc = -> do
              instance_variable_set ivar, true ; nil
            end
          end
        end

    o :meta_property, :default,
        :entity_class_hook, -> prop, cls do
          cls.add_iambic_event_listener :iambic_normalize_and_validate,
          -> obj do
            obj.aply_dflt_value_if_necessary prop ; nil
          end
        end

    o :meta_property, :parameter_arity,
        :enum, [ :zero_or_one, :one ],
        :default, :zero_or_one,
        :entity_class_hook_once, -> cls do

          req_a = cls.properties.reduce_by( & :is_required ).to_a.freeze
          if req_a.length.nonzero?

            cls.add_iambic_event_listener :iambic_normalize_and_validate,
            -> obj do
              obj.check_for_missing_required_props req_a ; nil
            end
          end
        end


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

      def under_expression_agent_get_N_desc_lines expression_agent, n=nil
        Brazen_::Lib_::N_lines[].
          new( [], n, @desc_p_a, expression_agent ).execute
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

    def check_for_missing_required_props req_a
      miss_a = req_a.reduce [] do |m, prop|
        if instance_variable_defined? prop.as_ivar
          x = instance_variable_get prop.as_ivar
          x.nil? || EMPTY_S__ == x and m << prop
        else
          m << prop
        end
        m
      end
      miss_a.length.nonzero? and whine_about_missing_reqd_props miss_a ; nil
    end

  private

    def whine_about_missing_reqd_props miss_a
      entity_error :missing_required_props, :miss_a, miss_a do |y, ev|
        a = ev.miss_a
        y << "missing required propert#{ 1 == a.length ? 'y' : 'ies' } #{
          }#{ a.map { |prop| par prop } * ' and ' }"
      end ; nil
    end

    def entity_error * x_a, & p
      on_channel_entity_structure :error, Brazen_::Entity::Event.new( x_a, p )
    end

    def on_channel_entity_structure i, ev
      m = :"on_#{ i }_channel_#{ ev.terminal_channel_i }_entity_structure"
      if respond_to? m
        send m, ev
      else
        send :"on_#{ i }_channel_entity_structure", ev
      end ; nil
    end

  public

    def on_error_channel_missing_required_props_entity_structure ev
      raise ::ArgumentError,
        ev.render_first_line_under( Brazen_::API::EXPRESSION_AGENT )
    end

    def on_error_channel_entity_structure ev
      raise ev.render_first_line_under Brazen_::API::EXPRESSION_AGENT
    end

    EMPTY_S__ = ''.freeze
  end
end
