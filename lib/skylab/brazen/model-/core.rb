module Skylab::Brazen

  class Model_  # read [#013]

    class << self

      attr_accessor :description_block, :persist_to

      def process_some_customized_inflection_behavior scanner
        Process_customized_model_inflection_behavior__[ scanner, self ] ; nil
      end

      def custom_branch_inflection
      end

    private

      def name_function_class
        Model_Name_Function_
      end
    end

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

      def action_property_value i
        ivar = :"@#{ i }"
        instance_variable_defined?( ivar ) or raise "action prop not set: '#{ i }'"
        instance_variable_get ivar
      end

    private

      def sign_event ev
        Entity_[]::Event::Signature_Wrapper.new name, ev
      end

      def build_event * x_a, & p
        build_event_via_iambic_and_proc x_a, p
      end

      def build_event_via_iambic_and_proc x_a, p
        Entity_[]::Event.inline_via_x_a_and_p x_a, p
      end

      self
    end

    def initialize kernel
      @kernel = kernel
    end

    def is_branch
      true
    end

    def is_visible
      true
    end

    # ~ common action & persistence collaborators

    def marshal_load x_a, no_p
      @error_count = 0
      @channel = :marshal_loading
      @listener = Proc_to_Listener_Adapter__.new no_p
      process_iambic_fully x_a
      notificate :iambic_normalize_and_validate
      if @error_count.nonzero?
        @listener.last_result
      else
        ACHEIVED_
      end
    end

    class Proc_to_Listener_Adapter__
      def initialize p
        @p = p
      end
      attr_reader :last_result
      def receive_marshal_loading_error ev
        @last_result = @p[ ev ] ; nil
      end
    end

    def edit action_x_a, prop_x_a
      action_x_a.each_slice( 2 ) do |ivar, x|
        instance_variable_set ivar, x
      end
      @error_count = 0
      process_iambic_fully prop_x_a
      notificate :iambic_normalize_and_validate
      @was_valid_after_edit = @error_count.zero?
      @error_count.nonzero? and Brazen_::API.exit_statii.fetch( :generic_error )
    end

    def persist
      @error_count = 0
      i = self.class.persist_to
      if :workspace == i
        persist_to_workspace
      else
        persist_to_datastore i
      end
    end
    attr_reader :came_from_persistence
  private
    def persist_to_workspace
      @kernel.models.workspaces.instance.persist_entity self
    end
    def persist_to_datastore i
      ds_i, locator_i = i.id2name.split( UNDERSCORE_, 2 ).map( & :intern )
      ds = @kernel.datastores.send ds_i
      ds.persist_entity_to_datastore self, locator_i
    end
  public

    def to_iambic
      scn = to_normalized_actual_property_scan ; y = []
      while actual = scn.gets
        y.push actual.name_i, actual.value_x
      end ; y
    end

    def to_normalized_actual_property_scan
      i_a = self.class.properties.get_names
      i_a.sort!
      Entity_[].scan_nonsparse_array( i_a ).map_by do |i|
        Actual_Property__.new i, property_value( i )
      end
    end
    Actual_Property__ = ::Struct.new :name_i, :value_x

    def property_value i  # #note-120
      instance_variable_get self.class.properties.fetch( i ).as_ivar
    end

    def receive_success_event ev
      send_event_on_channel ev, :success
    end

    def receive_error_event ev
      @error_count += 1
      send_event_on_channel ev, :error
    end

  private

    def send_event_on_channel ev, i
      tail_i = :"#{ @channel }_#{ i }"
      m_i = :"receive_#{ ev.terminal_channel_i }_#{ tail_i }"
      if @listener.respond_to? m_i
        @listener.send m_i, ev
      else
        @listener.send :"receive_#{ tail_i }", ev
      end
    end

  public

    # ~ action scanning

    class << self
      def get_unbound_action_scan
        get_unbound_upper_action_scan
      end
      def get_unbound_upper_action_scan
        acr = actn_class_reflection
        acr and acr.get_upper_action_class_scanner
      end
      def actn_class_reflection
        @did_reslolve_acr ||= init_action_class_reflection
        @acr
      end
    private
      def init_action_class_reflection
        @acr = Build_any_action_class_reflection__[ self ]
        true
      end
    end

    def get_action_scan
      get_lower_action_scan
    end

    def get_lower_action_scan
      acr = self.class.actn_class_reflection
      acr and acr.get_lower_action_class_scanner.map_by do |cls|
        cls.new @kernel
      end
    end

    class Build_any_action_class_reflection__

      Actor_[ self, :properties, :cls ]

      def execute
        has = @cls.const_defined? ACTIONS__, false  # #one
        has ||= @cls.entry_tree.instance_variable_get( :@h ).key? ACTIONS___
        has and work
      end
      ACTIONS__ = :Actions ; ACTIONS___ = 'actions'.freeze

      def work
        Progressive_Action_Class_Reflection__.
          new @cls, @cls.const_get( ACTIONS__, false )
      end
    end

    class Progressive_Action_Class_Reflection__
      def initialize * a
        @cls, @mod = a
      end
      def get_upper_action_class_scanner
        @did_partion ||= prttn
        Entity_[].scan_nonsparse_array @promoted_action_class_a
      end
      def get_lower_action_class_scanner
        @did_partion ||= prttn
        Entity_[].scan_nonsparse_array @non_promoted_action_class_a
      end
    private
      def prttn
        @promoted_action_class_a, @non_promoted_action_class_a =
          action_class_a.partition do |cls|
            cls.is_promoted
          end
        @non_promoted_action_class_a.length.nonzero? and
          @promoted_action_class_a.push @cls  # #two
        DONE_
      end
      def action_class_a
        @action_class_a ||= mod_constants.map { |i| @mod.const_get i, false }.freeze
      end
      def mod_constants
        @mod_constants ||= @mod.constants.freeze
      end
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

    module Action_Factory
      class << self
        def create_with *a
          Model_::Action_Factory__.new a
        end
      end
    end
  end
end
