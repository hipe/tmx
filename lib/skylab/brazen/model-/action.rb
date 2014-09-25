module Skylab::Brazen

  class Model_

  class Action  # see [#024]

    class << self

      def is_actionable
        true
      end

      attr_accessor :after_i, :description_block, :is_promoted,
        :precondition_controller_i_a

      def process_some_customized_inflection_behavior scanner
        Process_customized_action_inflection_behavior__[ scanner, self ] ; nil
      end

      def preconditions
        @did_resolve_pcia ||= resolve_precondition_controller_identifer_a
        @preconditions
      end

      def resolve_precondition_controller_identifer_a
        @preconditions = if precondition_controller_i_a
          @precondition_controller_i_a.map do |i|
            Entity_Identifier__.via_symbol i
          end
        else
          model_class.preconditions
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
    end

    extend Lib_::Name_function[].name_function_methods
    NAME_STOP_INDEX = 2  # sl br models

    # whether or not you define properties we need to override methods

    include Brazen_::Model_::Entity

    include Interface_Element_Instance_Methdods__

    def initialize kernel
      @kernel = kernel
    end

    def is_branch
      false
    end

  public

    def bound_call_via_call x_a, ev_rcvr
      @error_count ||= 0
      @event_receiver = ev_rcvr
      @argument_box = Box_.new
      bc = any_bound_call_via_processing_iambic x_a
      bc || via_arguments_produce_bound_call
    end

  private

    def any_bound_call_via_processing_iambic x_a
      process_iambic_fully x_a ; nil
    end

    def via_arguments_produce_bound_call
      notificate :iambic_normalize_and_validate
      if @error_count.zero?
        prdc_bound_call_when_valid
      else
        prdc_bound_call_when_invalid
      end
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

    def prdc_any_bc_when_preconds a  # eventually see #action-preconditions

      _g = Model_::Preconditions_::Graph.new self, self, @kernel

      _id = model_class.node_identifier

      box = Model_::Preconditions_.establish_box_with(
        :self_identifier, _id,
        :identifier_a, a,
        :on_self_reliance, method( :self_as_precondition ),
        :graph, _g,
        :level_i, :action_prcn,
        :event_receiver, self )

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
      Brazen_.bound_call self, :produce_any_result
    end

  public

    def receive_event ev
      if ev.has_tag :ok
        if ev.ok
          recv_OK_event ev
        else
          recv_not_OK_event ev
        end
      else
        recv_neutral_evnt ev
      end
    end

  private

    def recv_OK_event ev
      _ev_ = sign_event ev
      send_event _ev_
    end

    def recv_not_OK_event ev  # e.g ad-hoc normalization failure from spot [#012]
      @error_count += 1
      _ev_ = sign_event ev
      send_event _ev_
    end

    def recv_neutral_evnt ev
      send_event ev
    end

    def wrap_event ev
      sign_event ev
    end

  public
    def any_argument_value i
      @argument_box[ self.class.properties.fetch( i ).name_i ]
    end

    def argument_value i
      @argument_box.fetch self.class.properties.fetch( i ).name_i
    end
  private

    def actual_property_box
      @argument_box
    end

    def model_class
      self.class.model_class
    end

  public

    def controller_nucleus  # :+#experimental
      [ @event_receiver, @kernel ]
    end

    def argument_box
      @argument_box
    end

    def accept_parent_node x
      @parent_node = x ; nil
    end

    def payload_output_line_yielder  # #note-160
      @event_receiver.payload_output_line_yielder
    end

    # ~ just in support of workspaces - will build out later

    def start_path_for_workspace_search_when_precondition
      ::Dir.pwd  # this should never happen in pure API land
    end

    def max_num_dirs_to_search_when_precondition
    end

    class Process_customized_action_inflection_behavior__

      Actor_[ self, :properties, :scanner, :cls ]

      def execute
        @inflection = Customized_Action_Inflection__.new
        via_scanner_process_some_iambic
        acpt @inflection
      end

      def parse i
        x = @scanner.gets_one
        take_one x, i
        take_any_others i ; nil
      end

      def take_one x, i
        if x.respond_to? :id2name
          if :with_lemma == x
            @inflection.set_lemma @scanner.gets_one, i
          else
            @inflection.set_comb x, i
          end
        else
          @inflection.set_lemma x, i
        end ; nil
      end

      def take_any_others i
        while @scanner.unparsed_exists
          x = @scanner.current_token
          if x.respond_to? :ascii_only?
            @inflection.set_lemma @scanner.gets_one, i
          elsif :with_lemma == x
            @scanner.advance_one
            @inflection.set_lemma @scanner.gets_one, i
          else
            break
          end
        end ; nil
      end

      def acpt _ACTION_INFLECTION_
        @cls.send :define_singleton_method, :custom_action_inflection do
          _ACTION_INFLECTION_
        end ; nil
      end

      Entity_[][ self, -> do

        o :iambic_writer_method_name_suffix, :'='

        def noun=
          parse :noun
        end

        def verb=
          parse :verb
        end
      end ]
    end

    class Customized_Action_Inflection__

      attr_reader :has_verb_exponent_combination, :has_verb_lemma,
        :verb_exponent_combination_i, :verb_lemma,

        :has_noun_exponent_combination, :has_noun_lemma,
        :noun_exponent_combination_i, :noun_lemma

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

    private
      def inflection_kernel
        @inflection_kernel ||= Model_::Inflection_Kernel__.for_action self
      end
    end

  end
  end
end
