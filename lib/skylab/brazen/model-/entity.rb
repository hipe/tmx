module Skylab::Brazen

  class Model_

  Entity = Entity_[][ -> do  # see [#047]

    o :ad_hoc_processor, :after, -> scan do
      scan.scanner.advance_one
      scan.reader.after_i = scan.scanner.gets_one ; nil
    end

    o :ad_hoc_processor, :desc, -> scan do
      scan.scanner.advance_one  # `desc`
      scan.reader.description_block = scan.scanner.gets_one ; nil
    end

    o :ad_hoc_processor, :inflect, -> scan do
      scan.scanner.advance_one  # `inflect`
      scan.reader.process_some_customized_inflection_behavior scan.scanner
    end

    o :ad_hoc_processor, :is_promoted, -> scan do
      scan.scanner.advance_one
      scan.reader.is_promoted = true
    end

    o :ad_hoc_processor, :persist_to, -> scan do
      scan.scanner.advance_one
      scan.reader.persist_to = scan.scanner.gets_one ; nil
    end

    o :ad_hoc_processor, :preconditions, -> scan do
      scan.scanner.advance_one
      scan.reader.precondition_controller_i_a = scan.scanner.gets_one ; nil
    end

    o :meta_property, :argument_arity,
        :enum, [ :zero, :one ],
        :default, :one,
        :property_hook, -> prop do
          if :zero == prop.argument_arity
            prop.iambic_writer_method_proc = -> do
              accept_entity_property_value prop, true ; nil
            end
          end
        end

    o :meta_property, :argument_moniker

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
          Entity::Add_check_for_missing_required_properties[ cls ]
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

      def upcase_environment_name_i
        :"BRAZEN_#{ @name.as_variegated_symbol.upcase }"
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

      def takes_many_arguments
        :zero_to_many == @argument_arity or :one_to_many == @argument_arity
      end

      def argument_is_required
        :one == @argument_arity or :one_to_many == @argument_arity
      end

      def has_custom_moniker  # [#014] this is a smell here
      end

      def << a
        @scan = Lib_::Iambic_scanner[].new 0, a
        process_iambic_fully
        self
      end

    private

      def add_ad_hoc_normalizer & p
        @has_ad_hoc_normalizers = true
        ( @norm_p_a ||= [] ).push p
      end

      o do

        o :iambic_writer_method_name_suffix, :'='

        def ad_hoc_normalizer=
          add_ad_hoc_normalizer( & iambic_property ) ; nil
        end

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
          add_ad_hoc_normalizer do |x, val_p, ev_p, prop|
            x.nil? or NORMALIZE_NON_NEGATIVE_INTEGER__[ x, prop, val_p, ev_p ]
          end
        end

        def required=
          @parameter_arity = :one
        end
      end

      class NORMALIZE_NON_NEGATIVE_INTEGER__

        Callback_::Actor[ self, :properties,
          :x, :prop, :val_p, :ev_p ]

        def execute
          if @x.respond_to? :bit_length
            @d = @x
            execute_via_integer
          else
            execute_when_not_integer
          end
        end

        def execute_when_not_integer
          @md = INTEGER_RX__.match @x
          if @md
            execute_via_matchdata
          else
            when_did_not_match
          end
        end
        INTEGER_RX__ = /\A-?\d+\z/

        def when_did_not_match
          @ev_p[ :invalid_non_negative_integer, :x, @x, :prop, @prop,
            -> y, o do
              y << "#{ par o.prop } must be a non-negative integer, #{
                }had #{ ick o.x }"
          end ]
        end

        def execute_via_matchdata
          @d = @md[ 0 ].to_i
          execute_via_integer
        end

        def execute_via_integer
          if 0 > @d
            when_negative
          else
            @val_p[ @d ]
          end
        end

        def when_negative
          @ev_p[ :invalid_non_negative_integer, :x, @d, :prop, @prop,
            -> y, o do
              y << "#{ par o.prop } must be non-negative, had #{ ick o.x }"
            end ]
        end
      end
    end
  end ]

  module Entity

    Event_[].sender self

    def aply_ad_hoc_normalizers prop  # this evolved from [#fa-019]
      i = prop.name_i
      bx = actual_property_box_for_write
      prop.norm_p_a.each do |p|
        _x = bx.fetch i do end
        p[ _x,
          -> x do
            bx.set i, x ; nil
          end,
          -> * x_a, p_ do
            _ev = build_not_OK_event_via_mutable_iambic_and_message_proc x_a, p_
            receive_event _ev
          end,
          prop ]
      end ; nil
    end

    def aply_dflt_value_if_necessary prop
      i = prop.name_i
      bx = actual_property_box_for_write
      if bx[ i ].nil?
        bx.set i, prop.default
      end ; nil
    end

    # ~ missing requireds check

    Add_check_for_missing_required_properties = -> cls do
      cls.add_iambic_event_listener :iambic_normalize_and_validate,
        Check_for_missing_required_properties__
    end

    Check_for_missing_required_properties__ = -> obj do
      if ! obj.began_checking_for_missing_required_props  # #note-240
        obj.began_checking_for_missing_required_props = true
        obj.check_for_missing_required_props
      end
    end

    attr_accessor :began_checking_for_missing_required_props

    def check_for_missing_required_props
      miss_a = Scan_[].nonsparse_array( self.class.required_properties ).
        map_reduce_by do |prop|
          arg = get_bound_argument_via_property prop
          if argument_is_missing arg
            arg.property
          end
        end.to_a
      if miss_a.length.nonzero?
        whine_about_missing_reqd_props miss_a ; nil
      end
    end

  private

    const_get :Module_Methods, false  # sanity
    module Module_Methods
      def required_properties
        @required_prop_a ||= bld_required_prop_a
      end
    private
      def bld_required_prop_a
        req_a = properties.reduce_by( & :is_actually_required ).to_a.freeze
        clear_properties   # #open [#021]
        req_a
      end
    end

    def get_bound_argument_via_property prop
      had = true
      x = actual_property_box.fetch prop.name_i do
        had = false ; nil
      end
      Actual_And_Formal_Property__.new x, had, prop
    end

    class Actual_And_Formal_Property__

      def initialize * a
        @value_x, @actuals_has_name, @property = a
        freeze
      end

      attr_reader :value_x, :actuals_has_name, :property

      def name_i
        @property.name_i
      end
    end

    def argument_is_missing arg
      if arg.actuals_has_name
        x = arg.value_x
        if x.nil?
          true
        elsif EMPTY_S_ == x
          true
        end
      else
        true
      end
    end

    def whine_about_missing_reqd_props miss_a
      _ev = build_not_OK_event_with :missing_required_properties,
          :miss_a, miss_a do |y, o|
        s_a = o.miss_a.map do |prop|
          par prop
        end
        y << "missing required propert#{ 1 == s_a.length ? 'y' : 'ies' } #{
          }#{ s_a * ' and ' }"
      end
      receive_missing_required_properties _ev
    end

    def receive_missing_required_properties ev
      _s = ev.render_first_line_under Brazen_::API.expression_agent_instance
      raise ::ArgumentError, _s
    end

    def receive_missing_required_properties_softly ev
      @error_count += 1
      event_receiver.receive_event ev
    end

    # ~

    def via_properties_init_ivars
      formal = self.class.properties
      scn = formal.to_scan
      while prop = scn.gets
        i = prop.name_i
        x = if @property_box.has_name i
          @property_box.fetch i
        elsif @parameter_box.has_name i
          @parameter_box.fetch i
        else
          nil
        end
        ivar = prop.as_ivar
        if instance_variable_defined? ivar
          x = instance_variable_get ivar
          x.nil? or raise "HM: #{ ivar }"
        end
        instance_variable_set ivar, x
      end ; nil
    end

    def accept_entity_property_value prop, x
      actual_property_box_for_write.add prop.name_i, x ; nil
    end

    def actual_property_box_for_write
      actual_property_box
    end
  end
  end
end
