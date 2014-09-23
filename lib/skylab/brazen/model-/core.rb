module Skylab::Brazen

  class Model_  # read [#013]

    module LIB

      class << self

        def actual_property
          Actual_Property__
        end

        def collection_controller
          Collection_Controller_
        end

        def silo_controller
          Model_::Silo_Controller_
        end

        def silo
          Model_::Silo_
        end
      end
    end

    class << self

      def is_promoted
      end

      def is_silo
        true  # for now
      end

      attr_accessor :after_i, :description_block, :precondition_controller_i_a

      def new_flyweight evr, kern
        new kern do
          @event_receiver = evr
          @property_box = Flyweight_Property_Box__.new self
        end
      end

      def collection_controller
        if const_defined? :Collection_Controller__, false
          const_get :Collection_Controller__, false
        else
          const_set( :Collection_Controller__,
            const_set( :Generated_Collection_Controller___,
              ::Class.new( LIB.collection_controller ) ) )
        end
      end

      def silo_controller
        if const_defined? :Silo_Controller__, false
          const_get :Silo_Controller__, false
        else
          const_set( :Silo_Controller__,
            const_set( :Generated_Silo_Controller__,
              ::Class.new( LIB.silo_controller ) ) )
        end
      end

      def silo
        if ! const_defined? :Silo__, false
          const_set :Silo__, Silo_.make( self )
        end
        const_get :Silo__, false
      end

      def unmarshalled event_receiver, kernel, & p
        entity = new kernel do
          @event_receiver = event_receiver
          @came_from_persistence = true
        end
        entity.first_edit_via_proc p
      end

      def edited event_receiver, kernel, & p
        entity = new kernel do
          @event_receiver = event_receiver
        end
        entity.first_edit_via_proc p
      end

      def persist_to= i
        @persist_to_i = i
      end
      attr_reader :persist_to_i
      def persist_to
        @did_resolve_persist_to ||= resolve_persist_to
        @persist_to
      end
    private
      def resolve_persist_to
        @persist_to = if persist_to_i
          Node_Identifier_.via_symbol @persist_to_i
        end
        true
      end
    public

      def preconditions
        @did_resolve_pcia ||= resolve_precondition_controller_identifer_a
        @preconditions
      end

      def resolve_precondition_controller_identifer_a
        if precondition_controller_i_a
          a = @precondition_controller_i_a.map do |i|
            Node_Identifier_.via_symbol i
          end
          persist_to and a.push @persist_to
        elsif persist_to
          a = [ @persist_to ]
        end
        @preconditions = a  # can be nil
        ACHEIVED_
      end

      def process_some_customized_inflection_behavior scanner
        Process_customized_model_inflection_behavior__[ scanner, self ] ; nil
      end

      def node_identifier
        @node_id ||= Node_Identifier_.via_name_function name_function, self
      end

    private

      def name_function_class
        Model_Name_Function_
      end

      def make_action_making_actions_module
        factory = Model_::Action_Factory__.make self, action_class, entity_module
        const_set :Factory___, factory
        factory.make_actions_module
      end

      def action_class
        main_model_class.const_get :Action, false
      end

      def entity_module
        main_model_class.const_get :Entity, false
      end

      def main_model_class
        superclass
      end
    end  # >>

    extend Lib_::Name_function[].name_function_methods

    include module Interface_Element_Instance_Methdods__

      def name
        self.class.name_function
      end

      def is_visible
        ! is_invisible
      end

      attr_reader :is_invisible

      def has_description
        ! self.class.description_block.nil?
      end

      def under_expression_agent_get_N_desc_lines expression_agent, d=nil
        Brazen_::Lib_::N_lines[].
          new( [], d, [ self.class.description_block ], expression_agent ).
           execute
      end

      def any_action_property_value i
        ivar = :"@#{ i }"
        if instance_variable_defined? ivar
          instance_variable_get ivar
        end
      end

      def action_property_value i
        ivar = :"@#{ i }"
        instance_variable_defined?( ivar ) or raise say_no_action_prop( i )
        instance_variable_get ivar
      end

    private

      def say_no_action_prop i
        "action prop not set: '#{ i }'"
      end

      def sign_event ev
        Event_[].wrap.signature name, ev
      end

      self
    end

    def initialize kernel, & p  # #note-180 do not set error count here
      @kernel = kernel
      @kernel.do_debug and @kernel.debug_IO.
        puts ">> >> >> >> MADE #{ name.as_slug } CTRL"
      p and instance_exec( & p )
    end

    # ~ multipurpose, simple readers

    attr_reader :any_bound_call_for_edit_result,
      :came_from_persistence,
      :error_count

    def is_branch
      true
    end

    def is_visible
      true
    end

    def to_even_iambic
      scn = to_normalized_actual_property_scan ; y = []
      while actual = scn.gets
        y.push actual.name_i, actual.value_x
      end ; y
    end

    def to_normalized_actual_property_scan
      i_a = self.class.properties.get_names
      i_a.sort!
      Scan_[].nonsparse_array( i_a ).map_by do |i|
        Actual_Property__.new i, any_property_value( i )
      end
    end
    Actual_Property__ = ::Struct.new :name_i, :value_x

    def parameter_value i
      @parameter_box.fetch i
    end

    def any_parameter_value i
      @parameter_box[ i ]
    end

    def local_entity_identifier_string
      @property_box.fetch NAME_
    end

    def any_property_value i
      @property_box[ i ]
    end

    def property_value i  # ( was #note-120 )
      @property_box.fetch i
    end

    # ~ action scanning

    def get_action_scan
      get_lower_action_scan
    end

    def get_lower_action_scan
      acr = self.class.actn_class_reflection
      acr and acr.get_lower_action_cls_scan.map_by do |cls|
        cls.new @kernel
      end
    end

    def get_unbound_action_scan
      self.class.get_unbound_lower_action_scan
    end

    class << self

      def get_unbound_action_scan
        get_unbound_upper_action_scan
      end

      def get_unbound_upper_action_scan
        acr = actn_class_reflection
        acr and acr.get_upper_action_cls_scan
      end

      def get_node_scan
        acr = actn_class_reflection
        acr and acr.get_node_scan
      end

      def get_unbound_lower_action_scan
        acr = actn_class_reflection
        acr and acr.get_lower_action_cls_scan
      end

      def is_actionable
        @did_reslolve_acr ||= init_action_class_reflection
        @is_actionable
      end

      def actn_class_reflection
        @did_reslolve_acr ||= init_action_class_reflection
        @acr
      end

    private

      def init_action_class_reflection
        has = const_defined? ACTIONS__, false  # #one
        has ||= entry_tree.instance_variable_get( :@h ).key? ACTIONS___
        @acr = has && bld_action_class_reflection
        @is_actionable = @acr && true
        true
      end

      def bld_action_class_reflection
        Lazy_Action_Class_Reflection.new self, const_get( ACTIONS__, false )
      end
      ACTIONS__ = :Actions ; ACTIONS___ = 'actions'.freeze
    end

    class Lazy_Action_Class_Reflection

      def initialize * a
        @cls, @mod = a
      end

      def get_upper_action_cls_scan
        @did ||= work
        Scan_[].nonsparse_array @up_a
      end

      def get_lower_action_cls_scan
        @did ||= work
        Scan_[].nonsparse_array @down_a
      end

      def get_node_scan
        @did ||= work
        Scan_[].nonsparse_array @all_a
      end

      def all_a
        @did ||= work
        @all_a
      end

    private

      def work
        i_a = @mod.constants
        @all_a = [] ; @up_a = [] ; @down_a = []
        i_a.each do |i|
          cls = @mod.const_get i, false
          @all_a.push cls
          if cls.is_actionable
            if cls.is_promoted
              @up_a.push cls
            else
              @down_a.push cls
            end
          end
        end
        if @down_a.length.nonzero?  # #two
          @up_a.push @cls
        end
        DONE_
      end
    end

    # ~ edit :+#hook-in

    def first_edit &p
      first_edit_via_proc p
    end

    def first_edit_via_proc p
      set_property_values_via_edit_proc p
      via_properties_produce_edit_result
    end

    def edit & p
      es = Late_Edit_Shell__.new @parameter_box, x_a=[], self.class.properties
      p[ es ]
      if x_a.length.nonzero?
        process_iambic_fully 0, x_a
      end
      afp = es.action_formal_properties
      if afp
        @action_formal_properties = afp
      end
      nil
    end

    attr_reader :action_formal_properties

    class Late_Edit_Shell__

      def initialize pbx, x_a, props

        add_prop_iambic = nil

        @set_arg = -> i, x do
          prop = props[ i ]

          if prop
            add_prop_iambic[ prop, x ]
          else
            pbx.add_or_replace i, x
          end ; nil
        end

        @set_prop = -> i, x do
          prop = props[ i ]
          if prop
            add_prop_iambic[ prop, x ]
          else
            x_a.push i, x  # [#037] errors welcome
          end ; nil
        end

        add_prop_iambic = -> prop, x do
          if prop.takes_argument
            x_a.push prop.name_i, x
          else
            x_a.push prop.name_i
          end
        end

        @concat_props = -> x_a_ do
          x_a.concat x_a_ ; nil
        end
      end

      attr_accessor :action_formal_properties

      def with_arguments * x_a
        x_a.each_slice 2 do |x, y|
          @set_arg[ x, y ]
        end ; nil
      end

      def set_arg i, x
        @set_arg[ i, x ] ; nil
      end

      def with_argument_box bx
        bx.each_pair( & @set_arg ) ; nil
      end

      def with * x_a
        @concat_props[ x_a ] ; nil
      end

      def with_iambic x_a
        @concat_props[ x_a ] ; nil
      end
    end

  private

    def set_property_values_via_edit_proc p
      @parameter_box ||= Box_.new
      es = Early_Edit_Shell__.new @parameter_box, x_a=[], self.class.properties
      p[ es ]
      x = es.evr and @event_receiver = x
      x = es.precons and @preconditions = x
      @property_box ||= Box_.new
      @error_count ||= 0
      if x_a.length.nonzero?
        process_iambic_fully 0, x_a
      end
      nil
    end

    class Early_Edit_Shell__ < Late_Edit_Shell__

      attr_accessor :precons, :evr

      def with_event_receiver x
        @evr = x ; nil
      end

      def with_preconditions x
        @precons = x ; nil
      end

      def with_unmarshalled_hash h
        h.each_pair do |s, x|
          @set_prop[ s.intern, x ]
        end ; nil
      end
    end

    def via_properties_produce_edit_result  # :+#public-API
      notificate :iambic_normalize_and_validate
      self
    end

    def set_any_bound_call_for_edit_result x, *a
      if a.length.zero?
        @any_bound_call_for_edit_result = x
      else
        @any_bound_call_for_edit_result = Brazen_.bound_call( x, * a )
      end ; nil
    end

  public

    # ~ create

    def produce_any_persist_result
      expected_datastore_is_resolved and @datastore.persist_entity self, self
    end

    def persist_entity x, evr
      expected_datastore_is_resolved and @datastore.persist_entity x, evr
    end

    def any_native_create_before_create_in_datastore
      PROCEDE_
    end

    # ~ retrive one

    def entity_via_identifier id_o, evr
      expected_datastore_is_resolved and @datastore.entity_via_identifier id_o, evr
    end

    # ~ retrieve (many)

    def entity_scan_via_class cls, evr
      expected_datastore_is_resolved and @datastore.entity_scan_via_class cls, evr
    end

    # ~ delete (anemic out-of-box implementation: pass the buck)

    def delete_entity entity, evr
      expected_datastore_is_resolved and @datastore.delete_entity entity, evr
    end

  private

    public def any_native_delete_before_delete_in_datastore erv
      PROCEDE_
    end

    def expected_datastore_is_resolved
      @did_check_that_expected_datastore_exists ||= rslv_expected_datastore
      @datastore_does_exist
    end

    def rslv_expected_datastore
      @did_check_that_expected_datastore_exists = true
      @persist_to ||= self.class.persist_to
      if @persist_to
        when_persist_to_rslv_expected_datastore
      else
        @datastore_does_exist = false
        when_expected_datastore_does_not_exist
      end
      ACHEIVED_
    end

    def when_expected_datastore_does_not_exist
      Model_::Small_Time_Actors__::When_expected_datastore_not_indicated[ self ]
    end

    def when_persist_to_rslv_expected_datastore
      if preconditions
        @datastore = @preconditions.fetch @persist_to.full_name_i
        @datastore_does_exist = @datastore ? true : false
      else
        when_kernel_rslv_expected_datastore
      end ; nil
    end

    def when_kernel_rslv_expected_datastore
      silo = @kernel.silo_via_identifier @persist_to, @event_receiver
      if silo
        @datastore = silo.
          controller_as_datastore_via_entity self, @event_receiver
        @datastore_does_exist = @datastore ? true : false
      else
        @datastore_does_exist = false
      end ; nil
    end

    # ~ multipurpose internal producers

    def actual_property_box
      @property_box
    end

    def silo
      @silo ||= prdc_silo
    end

    def prdc_silo
      @kernel.silo_via_identifier self.class.node_identifier
    end

 public  # ~ multipurpose internal readers & callbacks

    attr_reader :preconditions

    def properties
      @property_box
    end

    def receive_event ev
      @event_receiver.receive_event ev
    end

    def action_via_action_class cls
      @kernel.action_via_action_class cls
    end

    class Action_as_Item__

      def initialize bound
        @bound = bound
        @cls = bound.class
      end

      def name
        @bound.name
      end

      def has_description
        @cls.description_block
      end

      def under_expression_agent_get_N_desc_lines exp, n=nil
        Brazen_::Lib_::N_lines[].
          new( [], n, [ @cls.description_block ], exp ).execute
      end
    end

    class Process_customized_model_inflection_behavior__

      Actor_[ self, :properties, :scanner, :cls ]

      def execute
        :noun == @scanner.current_token or raise ::ArgumentError, say_only
        @scanner.advance_one
        x = @scanner.current_token
        if :with_lemma == x
          @scanner.advance_one
          x = @scanner.current_token
        end
        x.respond_to? :ascii_only? or raise ::ArgumentError, say_string
        @scanner.advance_one
        acpt Customized_Model_Inflection__.new x
      end

      def say_only
        "the only kind of inflection a model may customize is 'noun' #{
          }(had '#{ @scanner.current_token }')"
      end

      def say_string
        "noun lemma must be a string (had #{ @scanner.current_token.inspect })"
      end

      def acpt _MODEL_INFLECTION_
        @cls.send :define_singleton_method, :custom_branch_inflection do
          _MODEL_INFLECTION_
        end ; nil
      end
    end

    class Customized_Model_Inflection__

      def initialize s
        @noun_lemma = s
      end

      attr_reader :noun_lemma

    end

    class Model_Name_Function_ < Lib_::Name_function[].name_function_class

      def initialize cls, parent, const_i
        @cls = cls
        super
      end

      attr_reader :cls

      def inflected_noun
        inflection_kernel.inflected_noun
      end

      def noun_lexeme
        inflection_kernel.noun_lexeme
      end

    private
      def inflection_kernel
        @inflection_kernel ||= Model_::Inflection_Kernel__.for_model self
      end
    end

    class Flyweight_Property_Box__

      def initialize ent
        symbol_to_string_h = {}
        ent.class.properties.get_names.each do |i|
          symbol_to_string_h[ i ] = i.id2name
        end
        @symbol_to_string_h = symbol_to_string_h ; nil
      end

      def replace_hash h
        @h = h ; nil
      end

      def fetch i, & p
        _s = @symbol_to_string_h[ i ]
        if _s
          @h.fetch _s, & p
        elsif p
          p[]
        else
          raise ::KeyError, say_key_error( i )
        end
      end
    private
      def say_key_error i
        "key not found: '#{ i }'"
      end
    end

    # ~ the stack

    class Collection_Controller_

      Actor_[ self, :properties,
        :action,
        :preconditions,
        :model_class,
        :event_receiver, :kernel ]

      class << self

        def build_with * x_a
          new do
            process_iambic_fully x_a
          end
        end

        def build_via_iambic x_a
          new do
            process_iambic_fully x_a
          end
        end
      end

      def initialize & p
        instance_exec( & p )
        @kernel.do_debug and @kernel.debug_IO.
          puts ">> >> >>    MADE #{ model_class.name_function.as_slug } CCTL"
      end

      def provide_action_precondition id, g
        if id.entity_name_s
          prvd_act_prcn_when_entity id, g
        else
          self
        end
      end

    private

      def prvd_act_prcn_when_entity id, _g
        ds = datastore.entity_via_identifier id, @event_receiver
        ds and ds.as_precondition_via_preconditions @preconditions
      end

      def datastore
        @preconditions.fetch model_class.persist_to.full_name_i
      end

      def model_class
        @model_class
      end
    end

    class Silo_Controller_

      Actor_[ self, :properties,
        :preconditions,
        :model_class,
        :event_receiver, :kernel ]

      def initialize
        super
        @kernel.do_debug and @kernel.debug_IO.
          puts ">> >>       MADE #{ model_class.name_function.as_slug } SCTL"
      end

      def provide_collection_controller_precon id, graph
        a = model_class.preconditions
        if a
          bx = Model_::Preconditions_.establish_box_with(
            :self_identifier, id,
            :identifier_a, a,
            :on_self_reliance, method( :when_cc_relies_on_self ),
            :graph, graph,
            :level_i, :collection_controller_prcn,
            :event_receiver, @event_receiver )
          bx and begin
            model_class.collection_controller.build_with(
              :action, graph.action,
              :preconditions, bx,
              :model_class, model_class,
              :event_receiver, @event_receiver,
              :kernel, @kernel )
          end
        else
          model_class.collection_controller.build_with(
            :model_class, model_class,
            :event_receiver, @event_receiver,
            :kernel, @kernel )
        end
      end

      def when_cc_relies_on_self id, graph, silo
        graph.touch :silo_controller_prcn, id, silo
      end

    private

      def receive_silo_controller_as_precondition_method_not_implemented ev
        receive_event ev
      end

      def receive_event ev
        @event_receiver.receive_event ev
      end

      def wrap_action_precondition_not_resolved_from_identifier_event ev
        ev
      end

      def model_class
        @model_class
      end
    end

    class Silo_

      class << self

        def make _MODEL_CLASS_, & p
          ::Class.new( self ).class_exec do
            define_method :model_class do _MODEL_CLASS_ end
            p and class_exec( & p )
            self
          end
        end
      end

      def initialize kernel
        @kernel = kernel
        @kernel.do_debug and @kernel.debug_IO.
          puts ">>          MADE #{ model_class.name_function.as_slug } SILO"
      end

      def name_i
        model_class.name_function.as_lowercase_with_underscores_symbol
      end

      def provide_action_prcn id, g, evr
        cc = g.touch :collection_controller_prcn, id, self
        cc and begin
          cc.provide_action_precondition id, g
        end
      end

      def provide_collection_controller_prcn id, g, evr
        sc = g.touch :silo_controller_prcn, id, self
        sc and begin
          sc.provide_collection_controller_precon id, g
        end
      end

      def provide_silo_controller_prcn id, g, evr
        a = model_class.preconditions
        if a && a.length.nonzero?
          bx = Model_::Preconditions_.establish_box_with(
            :self_identifier, id,
            :identifier_a, a,
            :on_self_reliance, method( :when_silo_controller_relies_on_self ),
            :graph, g,
            :level_i, :silo_controller_prcn,
            :event_receiver, evr )
          bx and begin
            model_class.silo_controller.build_with(
              :preconditions, bx,
              :model_class, model_class,
              :event_receiver, evr, :kernel, @kernel )
          end
        else
          bld_base_silo_controller evr
        end
      end

      def when_silo_controller_relies_on_self id, graph, silo
        silo
      end

      def controller_as_datastore_via_entity entity, evr  # :+#public-API
        bld_base_silo_controller( evr ).controller_as_datastore_via_entity entity
      end

      def bld_base_silo_controller evr
        model_class.silo_controller.build_with(
          :model_class, model_class,
          :event_receiver, evr, :kernel, @kernel )
      end
    end
  end
end
