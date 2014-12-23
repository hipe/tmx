module Skylab::Brazen

  class Model_

  class Action  # see [#024]

    class << self

      def is_actionable
        true
      end

      def is_branch
        false  # for now, every action node is always a terminal (leaf) node
      end

      attr_accessor :after_i, :description_block, :is_promoted,
        :precondition_controller_i_a

      def process_some_customized_inflection_behavior upstream
        Process_customized_action_inflection_behavior__.new( upstream, self ).execute
      end

      def preconditions
        @did_resolve_pcia ||= resolve_precondition_controller_identifer_a
        @preconditions
      end

      attr_reader :did_resolve_pcia

      def resolve_precondition_controller_identifer_a
        @preconditions = if precondition_controller_i_a
          @precondition_controller_i_a.map do |i|
            Node_Identifier_.via_symbol i
          end
        else
          mc = model_class
          if mc
            if mc.respond_to? :preconditions
              mc.preconditions
            end
          end
        end
        true
      end

      def model_class
        name_function.parent
      end

      def custom_action_inflection
      end

    private
      def name_function_class
        Action_Name_Function__
      end
    end  # >>

    extend Brazen_.name_library.name_function_proprietor_methods
    NAME_STOP_INDEX = 2  # sl br models

    # [#013]:#note-A the below order

    include Callback_::Actor.methodic_lib.iambic_processing_instance_methods

    include Brazen_::Entity::Instance_Methods

    Brazen_.event.selective_builder_sender_receiver self

    include Interface_Element_Instance_Methdods__

    def initialize boundish, & oes_p

      oes_p or raise ::ArgumentError

      accept_selective_listener_via_channel_proc( -> i_a, & ev_p do  # #note-100

        # when the action receives a potential event (eg from one of its
        # collaborating actors), we call our received selective listener
        # with the same channel, and if it wants the event we wrap it.

        oes_p.call( * i_a ) do
          _sign_event ev_p[]
        end
      end )

      @kernel = boundish.to_kernel
    end

  public

    def ___bound_call_via_iambic_stream_and_modality_adapter___ st, modality_action

      # this goes away in [#078]

      @hs_modality_action = true
      @modality_action = modality_action
      bound_call_against_iambic_stream st
    end

    def bound_call_against_iambic_stream st
      @argument_box = Box_.new
      bc = _any_bound_call_via_processing_iambic_stream st
      bc || via_arguments_produce_bound_call
    end

  private

    def _any_bound_call_via_processing_iambic_stream st

      # the result semantics here are reverse what is normal: something
      # true-ish means early return, and is assumed to be a bound call.
      # this step does not include calling normalize, that happens next

      ok = process_iambic_stream_fully st

      if ! ok
        Brazen_.bound_call.via_value ok
      end
    end

    def via_arguments_produce_bound_call  # :+#public-API [ts]
      subsume_external_arguments
      ok = normalize
      if ok
        prdc_bound_call_when_valid
      else
        prdc_bound_call_when_invalid
      end
    end

    def subsume_external_arguments  # :+#public-API #hook-over

      # after arguments are parsed but before they are normalized, your
      # action may want to hand-write logic here to default arguments
      # via e.g some zero config e.g environment facility. you cannot fail

    end

    def prdc_bound_call_when_invalid
      Brazen_.bound_call.via_value UNABLE_
    end

    def prdc_bound_call_when_valid
      bc = prdc_any_bound_call_from_establish_preconditions
      bc || prdc_bound_call_when_preconditions_are_met
    end

    def prdc_any_bound_call_from_establish_preconditions
      a = self.class.preconditions
      if a && a.length.nonzero?
        prdc_any_bc_when_preconds a
      end
    end

    def prdc_any_bc_when_preconds a  # see #action-preconditions

      oes_p = handle_event_selectively

      _g = Model_::Preconditions_::Graph.new self, @kernel, & oes_p

      _id = model_class.node_identifier

      box = Model_::Preconditions_.establish_box_with(
        :self_identifier, _id,
        :identifier_a, a,
        :on_self_reliance, method( :self_as_precondition ),
        :graph, _g,
        :level_i, :action_prcn,
        :on_event_selectively, oes_p )

      if box
        @preconditions = box
        CONTINUE_
      else
        Brazen_.bound_call.via_value box
      end
    end

    def self_as_precondition id, g, silo
      g.touch :collection_controller_prcn, id, silo
    end

    def prdc_bound_call_when_preconditions_are_met
      Brazen_.bound_call nil, self, :produce_any_result
    end

    def to_actual_argument_stream  # used by [tm]
      LIB_.stream.via_nonsparse_array( formal_properties.get_names ).map_by do |i|
        Actual_Property_.new any_argument_value( i ), i
      end
    end

    def _sign_event ev
      Brazen_.event.wrap.signature name, ev
    end

  public  # public accessors for arguments & related experimentals

    def get_bound_argument i
      get_bound_property_via_property formal_properties.fetch i
    end

    def any_argument_value_at_all i
      if formal_properties.has_name i
        any_argument_value i
      end
    end

    def any_argument_value i
      @argument_box[ formal_properties.fetch( i ).name_i ]
    end

    def argument_value i
      @argument_box.fetch formal_properties.fetch( i ).name_i
    end

    def argument_box
      @argument_box
    end

    def modality_adapter  # #experimental
      if hs_modality_action
        @modality_action
      end
    end

    attr_reader :hs_modality_action

  private

    def primary_box
      @argument_box
    end

    def any_secondary_box  # #todo - after universal integration, get rid of secondary box of action
      Callback_::Box.the_empty_box
    end

    def actual_property_box
      @argument_box
    end

    def model_class
      self.class.model_class
    end

  public

    def accept_parent_node_ x
      @parent_node = x ; nil
    end

    def controller_nucleus  # :+#experimental
      [ @kernel, handle_event_selectively ]
    end

    def preconditions  # for a collaborator that knows they exist & what they are
      @preconditions
    end

    # (was #note-160)

    class Process_customized_action_inflection_behavior__

      def initialize * a
        @upstream, @cls = a
      end

      def execute
        @inflection = Customized_Action_Inflection__.new
        process_iambic_stream_passively @upstream
        acpt @inflection
      end

      include Callback_::Actor.methodic_lib.iambic_processing_instance_methods

    private

      def noun=
        parse :noun
      end

      def verb=
        parse :verb
      end

      def verb_as_noun=
        parse :verb_as_noun
      end

      def parse i
        x = @upstream.gets_one
        take_one x, i
        take_any_others i
      end

      def take_one x, i
        if x.respond_to? :id2name
          if :with_lemma == x
            @inflection.set_lemma @upstream.gets_one, i
          else
            @inflection.set_comb x, i
          end
        else
          @inflection.set_lemma x, i
        end
        KEEP_PARSING_
      end

      def take_any_others i
        while @upstream.unparsed_exists
          x = @upstream.current_token
          if x.respond_to? :ascii_only?
            @inflection.set_lemma @upstream.gets_one, i
          elsif :with_lemma == x
            @upstream.advance_one
            @inflection.set_lemma @upstream.gets_one, i
          else
            break
          end
        end
        KEEP_PARSING_
      end

      def acpt _ACTION_INFLECTION_
        @cls.send :define_singleton_method, :custom_action_inflection do
          _ACTION_INFLECTION_
        end
        KEEP_PARSING_
      end
    end

    class Customized_Action_Inflection__

      attr_reader :has_verb_exponent_combination, :has_verb_lemma,
        :verb_exponent_combination_i, :verb_lemma,

        :has_noun_exponent_combination, :has_noun_lemma,
        :noun_exponent_combination_i, :noun_lemma,

        :has_verb_as_noun_lemma,
        :verb_as_noun_lemma

      def set_lemma s, i
        instance_variable_set :"@has_#{ i }_lemma", true
        instance_variable_set :"@#{ i }_lemma", s ; nil
      end

      def set_comb i, i_
        instance_variable_set :"@has_#{ i_ }_exponent_combination", true
        instance_variable_set :"@#{ i_ }_exponent_combination_i", i ; nil
      end
    end

    class Action_Name_Function__ < Model_Name_Function_

      def inflected_verb
        inflection_kernel.inflected_verb
      end

      def verb_lexeme
        inflection_kernel.verb_lexeme
      end

      def verb_as_noun_lexeme
        inflection_kernel.verb_as_noun_lexeme
      end

    private
      def inflection_kernel
        @inflection_kernel ||= Model_::Inflection_Kernel__.for_action self
      end
    end

  end
  end
end
