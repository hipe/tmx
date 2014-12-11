module Skylab::Brazen

  class Model_  # read [#013]

    module LIB

      class << self

        def action_class
          Model_::Action
        end

        def actual_property
          Actual_Property_
        end

        def collection_controller
          Collection_Controller_
        end

        def entity * a, & p
          if a.length.nonzero? || p
            Model_::Entity.via_nonzero_length_arglist a, & p
          else
            Model_::Entity
          end
        end

        def name_function_class
          Model_Name_Function_
        end

        def retrieve_methods
          Model_::Action_Factory__.retrieve_methods
        end

        def silo_controller
          Model_::Silo_Controller_
        end

        def silo
          Model_::Silo_
        end
      end
    end

    Actual_Property_ = Callback_::Box.pair

    class << self

      def is_promoted
      end

      def is_silo
        true  # for now
      end

      attr_accessor :after_i, :description_block, :precondition_controller_i_a

      def local_entity_identifier_string
        properties.fetch NAME_
      end

      def new_flyweight kernel, & oes_p
        new kernel do
          @property_box = Flyweight_Property_Box__.new self
          recv_selective_listener_proc oes_p
        end
      end

      def collection_controller
        if ! const_defined? :Collection_Controller__, false
          if const_defined? :Collection_Controller__
            self._DO_ME
          else
            cls = ::Class.new LIB.collection_controller
            const_set :Generated_Collection_Controller___, cls
            const_set :Collection_Controller__, cls
          end
        end
        const_get :Collection_Controller__, false
      end

      def silo_controller
        if ! const_defined? :Silo_Controller__, false
          if const_defined? :Silo_Controller__
            cls = ::Class.new const_get( :Silo_Controller__ )
            const_set :Generated_Silo_Controller_Subclass___, cls
            const_set :Silo_Controller__, cls
          else
            cls = ::Class.new LIB.silo_controller
            const_set :Generated_Silo_Controller__, cls
            const_set :Silo_Controller__, cls
          end
        end
        const_get :Silo_Controller__, false
      end

      def silo
        if ! const_defined? :Silo__, false
          if const_defined? :Silo__
            const_set :Silo__, const_get( :Silo__ ).make( self )
          else
            const_set :Silo__, Silo_.make( self )
          end
        end
        const_get :Silo__, false
      end

      def unmarshalled kernel, oes_p, & edit_p
        new kernel do
          recv_selective_listener_proc oes_p
          @came_from_persistence = true
        end.first_edit( & edit_p )
      end

      def edit_entity kernel, oes_p, & edit_p
        new kernel do
          recv_selective_listener_proc oes_p
        end.first_edit( & edit_p )
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

      attr_reader :did_resolve_pcia

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
        ACHIEVED_
      end

      def process_some_customized_inflection_behavior scanner
        Process_customized_model_inflection_behavior__[ scanner, self ]
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

    extend Brazen_.name_library.name_function_proprietor_methods

    # [#013]:#note-A the below order

    include Callback_::Actor.methodic_lib.iambic_processing_instance_methods

    include Brazen_::Entity::Instance_Methods

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

      self
    end

    def initialize kernel, & p  # #note-180 do not set error count here
      @kernel = kernel
      @kernel.do_debug and @kernel.debug_IO.
        puts ">> >> >> >> MADE #{ name.as_slug } CTRL"
      p and instance_exec( & p )
    end

    def initialize_copy _otr_  # when entity is flyweight
      @property_box = @property_box.dup
    end

    # ~ multipurpose, simple readers

    attr_reader :any_bound_call_for_edit_result,
      :came_from_persistence

    def is_branch
      true
    end

    def is_visible
      true
    end

    def to_even_iambic
      scn = to_normalized_actual_property_stream ; y = []
      while actual = scn.gets
        y.push actual.name_i, actual.value_x
      end ; y
    end

    def to_normalized_actual_property_scan_for_persist
      to_normalized_actual_property_stream
    end

    def to_normalized_actual_property_stream
      LIB_.stream.via_nonsparse_array( get_sorted_property_name_i_a ).map_by do |i|
        Actual_Property_.new any_property_value( i ), i
      end
    end

    def to_normalized_bound_property_scan
      props = self.class.properties
      LIB_.stream.via_nonsparse_array( get_sorted_property_name_i_a ).map_by do |i|
        get_bound_property_via_property props.fetch i
      end
    end

    def get_sorted_property_name_i_a
      i_a = self.class.properties.get_names
      i_a.sort! ; i_a
    end

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

    def normalize_property_value_via_normal_entity prop, ent, & oes_p
      normal_x = ent.property_value prop.name_i
      mine_x = property_value prop.name_i
      if normal_x != mine_x
        @property_box.replace prop.name_i, normal_x
        maybe_send_event :info, :normalized_value do
          bld_normalized_value_event normal_x, mine_x, prop
        end
      end
    end

    def bld_normalized_value_event normal_x, mine_x, prop
      build_OK_event_with :normalized_value, :prop, prop,
          :previous_x, mine_x, :current_x, normal_x do |y, o|
        y << "using #{ ick o.current_x } for #{ par o.prop } #{
         }(was #{ ick o.previous_x })"
      end
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
        LIB_.stream.via_nonsparse_array @up_a
      end

      def get_lower_action_cls_scan
        @did ||= work
        LIB_.stream.via_nonsparse_array @down_a
      end

      def get_node_scan
        @did ||= work
        LIB_.stream.via_nonsparse_array @all_a
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
          if ! cls.respond_to? :name
            cls = try_convert_to_node_like_via_mixed cls, i
            cls or next
          end
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

      def try_convert_to_node_like_via_mixed x, i
        if x.respond_to? :call
          Model_::Node_via_Proc._DO_ME_like_an_action x, i
        end
      end
    end

    # ~ edit :+#hook-in

    def first_edit & edit_p
      _ok = set_prps_via_first_edit( & edit_p )
      _ok && via_props_produce_edit_result
    end

    def edit & edit_p  # #todo this is covered visually by `source rm` ONLY
      _ok = set_prps_via_subsequent_edit( & edit_p )
      _ok && via_props_produce_edit_result
    end

    attr_reader :action_formal_properties

  private

    def set_prps_via_first_edit & edit_p

      @parameter_box ||= Box_.new

      x_a = []

      es = First_Edit_Session__.new @parameter_box, x_a, self.class.properties
      edit_p[ es ]  # the blocks of edit sessions are only for setting parameters

      oes_p = es.handle_event_selectively
      if oes_p
        recv_selective_listener_proc oes_p
      end

      precons = es.precons
      if precons
        @preconditions = precons
      end

      @property_box ||= Box_.new

      if x_a.length.zero?
        ACHIEVED_
      else
        process_iambic_stream_fully iambic_stream_via_iambic_array x_a
      end
    end

    def set_prps_via_subsequent_edit & edit_p

      x_a = []

      es = Subsequent_Edit_Session__.new @parameter_box, x_a, self.class.properties
      edit_p[ es ]  # the blocks of edit sessions are only for setting parameters

      afp = es.action_formal_properties
      if afp
        @action_formal_properties = afp
      end

      if x_a.length.zero?
        ACHIEVED_
      else
        process_iambic_stream_fully iambic_stream_via_iambic_array x_a
      end
    end

    class Subsequent_Edit_Session__

      def initialize pbx, x_a, props

        add_prop_iambic = nil

        @set_arg = -> i, x do
          prop = props[ i ]

          if prop
            add_prop_iambic[ prop, x ]
          else
            pbx.set i, x
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

    class First_Edit_Session__ < Subsequent_Edit_Session__

      attr_accessor :precons

      def on_event_selectively & oes_p
        @handle_event_selectively = oes_p ; nil
      end

      attr_reader :handle_event_selectively

      def with_preconditions x
        @precons = x ; nil
      end

      def with_unmarshalled_hash h
        h.each_pair do |s, x|
          @set_prop[ s.intern, x ]
        end ; nil
      end
    end

    def via_props_produce_edit_result
      ok = normalize
      if ok
        self
      else
        ok
      end
    end

  public

    # ~ create

    def produce_any_persist_result
      datastore_resolved_OK and @datastore.persist_entity self, & handle_event_selectively
    end

    def persist_entity x, & oes_p
      datastore_resolved_OK and @datastore.persist_entity x, & oes_p
    end

    def any_native_create_before_create_in_datastore
      PROCEDE_
    end

    # ~ retrive one

    def entity_via_identifier id_o, & oes_p
      datastore_resolved_OK and @datastore.entity_via_identifier id_o, & oes_p
    end

    # ~ retrieve (many)

    def entity_scan_via_class cls, & oes_p
      datastore_resolved_OK and @datastore.entity_scan_via_class cls, & oes_p
    end

    # ~ delete (anemic out-of-box implementation: pass the buck)

    def delete_entity entity, & oes_p
      datastore_resolved_OK and @datastore.delete_entity entity, & oes_p
    end

  private

    public def any_native_delete_before_delete_in_datastore
      PROCEDE_
    end

    def datastore_resolved_OK
      @did_attempt_to_resolve_datastore ||= rslv_datastore
      @datastore_resolved_OK
    end

    def rslv_datastore
      @did_attempt_to_resolve_datastore = true
      @persist_to ||= self.class.persist_to
      if @persist_to
        via_persist_to_rslv_datastore
      else
        when_no_persist_to_for_rslv_datastore
      end
      ACHIEVED_
    end

    def when_no_persist_to_for_rslv_datastore
      @datastore_is_OK = false
      Model_::Small_Time_Actors__::When_datastore_not_indicated[ self ]
    end

    def via_persist_to_rslv_datastore
      if preconditions
        _intermediary = @preconditions.fetch @persist_to.full_name_i
        @datastore = _intermediary.datastore_controller_via_entity self
        @datastore_resolved_OK = @datastore ? true : false
      else
        via_kernel_rslv_datastore
      end ; nil
    end

    def via_kernel_rslv_datastore
      silo = @kernel.silo_via_identifier @persist_to, & @on_event_selectively
      if silo
        @datastore = silo.dsc_via_entity self, & @on_event_selectively
        @datastore_resolved_OK = @datastore ? true : false
      else
        @datastore_resolved_OK = false
      end ; nil
    end

    # ~ multipurpose internal producers

    def actual_property_box
      @property_box
    end

    def primary_box
      @property_box
    end

    def any_secondary_box
      @parameter_box
    end

    def silo
      @silo ||= prdc_silo
    end

    def prdc_silo
      @kernel.silo_via_identifier self.class.node_identifier
    end

    # ~ the event throughput pipeline

    def recv_selective_listener_proc oes_p
      receive_selective_listener_proc oes_p ; nil
    end

 public  # ~ multipurpose internal readers & callbacks

    def action_via_action_class cls
      @kernel.action_via_action_class cls
    end

    attr_reader :preconditions

    def properties
      @property_box
    end

    def datastore  # for low-level actors
      _ok = datastore_resolved_OK
      _ok and @datastore
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
        end
        KEEP_PARSING_
      end
    end

    class Customized_Model_Inflection__

      def initialize s
        @noun_lemma = s
      end

      attr_reader :noun_lemma

    end

    class Model_Name_Function_ < Brazen_.name_library.name_function_class

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

      def [] i
        s = @symbol_to_string_h[ i ]
        s and @h[ s ]
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
        :kernel, :on_event_selectively ]

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

      def datastore_controller_via_entity _
        self
      end

      def persist_entity ent, & oes_p
        @dsc ||= datastore_controller
        @dsc and via_dsc_persist_entity ent, & oes_p
      end

    private

      def normalize_entity_name_via_fuzzy_lookup ent, & oes_p  # (covered by [tm] for now)
        ent_ = one_entity_via_fuzzy_lookup ent, & oes_p
        ent_ and begin
          ent.normalize_property_value_via_normal_entity(
            ent.class.local_entity_identifier_string, ent_, & oes_p )
          ACHIEVED_
        end
      end

      def one_entity_via_fuzzy_lookup ent, & oes_p
        ent_a = matching_entities_via_fuzzy_lookup ent, & oes_p
        case 1 <=> ent_a.length
        when  0
          ent_a.fetch 0
        when -1
          one_entity_when_via_fuzzy_lookup_ambiguous ent_a, ent, & oes_p  # #todo
        when  1
          one_entity_when_via_fuzzy_lookup_not_found ent, & oes_p
        end
      end

      def matching_entities_via_fuzzy_lookup ent, & oes_p

        against_s = ent.local_entity_identifier_string
        rx = /\A#{ ::Regexp.escape against_s }/

        a = [] ; scn = entity_scan_via_class ent.class, & oes_p

        while x = scn.gets
          s = x.local_entity_identifier_string
          rx =~ s or next
          if against_s == s
            a.clear.push x
            break
          else
            a.push x.dup
          end
        end

        a
      end

      def one_entity_when_via_fuzzy_lookup_not_found ent, & oes_p

        oes_p.call :error, :entity_not_found do
          bld_entity_not_found_event ent
        end

        UNABLE_
      end

      def bld_entity_not_found_event ent

        _scn = entity_scan_via_class ent.class

        _a_few_ent_a = _scn.take A_FEW__ do |x|
          x.dup
        end

        build_not_OK_event_with :entity_not_found,
            :ent, ent, :a_few_ent_a, _a_few_ent_a do |y, o|

          human_s = ent.class.name_function.as_human

          s_a = o.a_few_ent_a.map do |x|
            val x.local_entity_identifier_string
          end

          y << "#{ human_s } not found: #{
           }#{ ick o.ent.local_entity_identifier_string } #{
            }(some known #{ human_s }#{ s s_a }: #{ s_a * ', ' })"

        end
      end

      A_FEW__ = 3

      def via_dsc_persist_entity ent, & oes_p
        @dsc.persist_entity ent, & oes_p
      end

    public

      def delete_entity id_x, & oes_p
        @dsc ||= datastore_controller
        @dsc and via_dsc_delete_entity id_x, & oes_p
      end

    private

      def prvd_act_prcn_when_entity id, _g
        ds = datastore.entity_via_identifier id, & handle_event_selectively
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
        :kernel, :on_event_selectively ]

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
            :on_event_selectively, @on_event_selectively )
          bx and begin
            model_class.collection_controller.build_with(
              :action, graph.action,
              :preconditions, bx,
              :model_class, model_class,
              :kernel, @kernel, :on_event_selectively, @on_event_selectively )
          end
        else
          model_class.collection_controller.build_with(
            :model_class, model_class,
            :kernel, @kernel, :on_event_selectively, @on_event_selectively )
        end
      end

      def when_cc_relies_on_self id, graph, silo
        graph.touch :silo_controller_prcn, id, silo
      end

    private

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

      def provide_action_prcn id, g, & oes_p
        cc = g.touch :collection_controller_prcn, id, self
        cc and begin
          cc.provide_action_precondition id, g, & oes_p
        end
      end

      def provide_collection_controller_prcn id, g, & oes_p
        sc = g.touch :silo_controller_prcn, id, self
        sc and begin
          sc.provide_collection_controller_precon id, g, & oes_p
        end
      end

      def provide_silo_controller_prcn id, g, & oes_p
        a = model_class.preconditions
        if a && a.length.nonzero?
          bx = Model_::Preconditions_.establish_box_with(
            :self_identifier, id,
            :identifier_a, a,
            :on_self_reliance, method( :when_silo_controller_relies_on_self ),
            :graph, g,
            :level_i, :silo_controller_prcn,
            :on_event_selectively, oes_p )
          bx and begin
            model_class.silo_controller.build_with(
              :preconditions, bx,
              :model_class, model_class,
              :kernel, @kernel, :on_event_selectively, oes_p )
          end
        else
          build_silo_controller( & oes_p )
        end
      end

      def when_silo_controller_relies_on_self id, graph, silo
        silo
      end

      def dsc_via_entity entity, & oes_p
        build_silo_controller( & oes_p ).datastore_controller_via_entity entity
      end

      def build_silo_controller & oes_p
        model_class.silo_controller.build_with(
          :model_class, model_class,
          :kernel, @kernel, :on_event_selectively, oes_p )
      end
    end
  end
end
