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

    o :meta_property, :has_ad_hoc_normalizers,
        :entity_class_hook, -> prop, cls do
          cls.add_iambic_event_listener :iambic_normalize_and_validate,
          -> obj do
            obj.aply_ad_hoc_normalizers prop ; nil
          end
        end

    o :meta_property, :parameter_arity,
        :enum, [ :zero_or_one, :one ],
        :default, :zero_or_one,
        :entity_class_hook_once, -> cls do

          req_a = cls.properties.reduce_by( & :is_actually_required ).to_a.freeze

          if req_a.length.nonzero?

            cls.add_iambic_event_listener :iambic_normalize_and_validate,
            -> obj do
              obj.check_for_missing_required_props req_a ; nil
            end
          end
        end

    add_iambic_event_listener :iambic_normalize_and_validate, -> obj do
      obj.nilify_all_ivars_not_defined
    end

    property_class_for_write  # flush the above to get the below

    class self::Property

      def initialize( * )
        @can_be_from_argv = true
        @desc_p_a = nil
        @default = nil
        super
      end

      attr_reader :ad_hoc_normalizer, :norm_p_a
      attr_reader :can_be_from_argv, :can_be_from_environment

      def environment_name_i
        "BRAZEN_#{ @name.as_variegated_symbol }"
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

      def is_actually_required  # see [#006]
        is_required && ! has_default
      end

      def is_required
        :one == @parameter_arity
      end

      def takes_argument
        :one == @argument_arity
      end

    private

      def add_ad_hoc_normalizer & p
        @has_ad_hoc_normalizers = true
        ( @norm_p_a ||= [] ).push p
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

        def environment=
          @can_be_from_argv = false
          @can_be_from_environment = true
        end

        def flag=
          @argument_arity = :zero
        end

        def non_negative_integer=
          add_ad_hoc_normalizer do |x, prop, val_p, ev_p|
            x.nil? or NORMALIZE_NON_NEGATIVE_INTEGER__[ x, prop, val_p, ev_p ]
          end
        end

        def required=
          @parameter_arity = :one
        end
      end

      NORMALIZE_NON_NEGATIVE_INTEGER__ = -> x, prop, val_p, ev_p do
        md = INTEGER_RX__.match x
        if md
          d = md[ 0 ].to_i
          if 0 > d
            ev_p[ :error, :invalid_non_negative_integer, :x, d, :prop, prop,
              -> y, o do
                y << "#{ par o.prop } must be non-negative, had #{ ick o.x }"
              end ]
          else
            val_p[ d ]
          end
        else
          ev_p[ :error, :invalid_non_negative_integer, :x, x, :prop, prop,
            -> y, o do
              y << "#{ par o.prop } must be a non-negative integer, #{
                }had #{ ick o.x }"
          end ]
        end ; nil
      end

      INTEGER_RX__ = /\A-?\d+\z/
    end
  end ]

  module Entity_

    def aply_ad_hoc_normalizers prop  # this evolved from [#fa-019]
      ivar = prop.as_ivar
      prop.norm_p_a.each do |p|
        p[ ( instance_variable_get ivar if instance_variable_defined? ivar ),
          prop,
          -> x do
            instance_variable_set ivar, x
          end,
          -> i, * x_a, p_ do
            on_channel_entity_structure i, Brazen_::Entity::Event.new( x_a, p_ )
          end ]
      end ; nil
    end

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
          x.nil? || EMPTY_S_ == x and m << prop
        else
          m << prop
        end
        m
      end
      miss_a.length.nonzero? and whine_about_missing_reqd_props miss_a ; nil
    end

    def nilify_all_ivars_not_defined
      self.class.properties.each_value do |prop|
        if ! instance_variable_defined? prop.as_ivar
          instance_variable_set prop.as_ivar, nil
        end
      end ; nil
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
  end
end
