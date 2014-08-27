module Skylab::Brazen

  class Model_

  class Action

    class << self

      attr_accessor :description_block, :is_promoted

      def process_some_customized_inflection_behavior scanner
        Process_customized_action_inflection_behavior__[ scanner, self ] ; nil
      end

      def custom_action_inflection
      end

    private
      def name_function_class
        Action_Name_Function__
      end
    end
    extend Lib_::Name_function[].name_function_methods

    include Brazen_::Model_::Entity  # so we can override its behavior near events

    Entity_[]::Event::Merciless_Prefixing_Sender[ self ]  # experimental default

    include Interface_Element_Instance_Methdods__

    def initialize
    end

    def is_branch
      false
    end

    def to_even_iambic
      scn = get_property_scanner ; x_a = []
      while (( prop = scn.gets ))
        x_a.push prop.name.as_lowercase_with_underscores_symbol,
          instance_variable_get( prop.as_ivar )
      end
      x_a
    end

    def get_property_scanner
      props = self.class.properties
      if props
        props.to_value_scanner
      else
        Callback_::Scn.the_empty_scanner
      end
    end

    def resolve_any_executable_via_iambic_and_adapter x_a, adapter
      @client_adapter = adapter
      @error_count = 0
      process_iambic_fully x_a
      notificate :iambic_normalize_and_validate
      if @error_count.zero?
        adapter.executable_wrapper_class.new self, :execute
      end
    end

    def receive_missing_required_props ev
      receive_negative_event ev
    end

    def receive_error_event ev  # e.g ad-hoc normalization failure from spot [#012]
      ev_ = sign_event ev
      receive_negative_event ev_
    end

    def receive_negative_event ev
      @error_count += 1
      @client_adapter.receive_negative_event ev ; nil
    end

    private

    # ~

    def listener
      @listener ||= bld_listener
    end

    def bld_listener
      if self.class.const_defined? :Listener
        self.class::Listener.new @client_adapter, self.class
      else
        self
      end
    end

    # ~

    def execute
      ok = expect_workspace_exists
      ok and if_workspace_exists
    end

    def expect_workspace_exists
      _path = Brazen_::CLI::Property__.new :path, :argument_arity, :one
      Brazen_::Models_::Workspace.status [ :client, :_FOO_, :listener, self,
        :channel, :workspace_expectation,
        :max_num_dirs, 1, :path, '.', :verbose, true, :prop, _path ]
    end

  public

    def receive_workspace_expectation_resource_exists ev
      if @verbose
        ev_ = sign_event ev
        @client_adapter.receive_positive_event ev_
      end
      ACHEIVED_
    end

    def receive_workspace_expectation_file_not_found ev
      x_a = ev.to_iambic
      x_a.push :invite_to_action, [ :init ]
      ev_ = build_event_via_iambic_and_proc x_a, nil
      ev__ = sign_event ev_
      send_structure_on_channel_to_listener ev__,
        :workspace_expectation, @client_adapter
      UNABLE_
    end

    def receive_workspace_expectation_event ev
      receive_error_event ev
      UNABLE_
    end


    class Process_customized_action_inflection_behavior__

      Actor[ self, :properties, :scanner, :cls ]

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
