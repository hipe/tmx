module Skylab::TanMan

  module API

    # (track what is now boilerplate here with #[#ze-002.1] (might dry))

    class << self

      def call * a, & p
        bc = invocation_via_argument_array( a, & p ).to_bound_call_of_operator
        bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
      end

      def invocation_via_argument_array a=nil, & p  # #testpoint
        Require_microservice_toolkit_[]
        _nar = if a
          MTk_::API_ArgumentScanner.narrator_for a, & p
        elsif p
          ListenerOnly___.new p
        end
        MicroserviceInvocation___.new InvocationResources___.new _nar
      end

      def expression_agent_instance  # :+[#051]
        InterfaceExpressionAgent___.instance
      end
    end  # >>

    # ==

    class MicroserviceInvocation___

      def initialize invo_rsx
        @invocation_resources = invo_rsx
      end

      def execute
        bc = to_bound_call_of_operator
        bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
      end

      def to_bound_call_of_operator
        MTk_::BoundCall_of_Operation_via[ self, Operator_branch___[] ]
      end

      # -- experimental "kernel killer"

      # ~ this one is called many times. dicussion under #[#007.C].

      def generated_grammar_dir__
        send( @_generated_grammar_dir ||= :__generated_grammar_dir_initially )
      end

      def __generated_grammar_dir_initially

        _ = __call_sub_invocation(
          :paths,
          :path, :generated_grammar_dir,
          :verb, :retrieve,
          & @invocation_resources.listener )  # ??

        @_generated_grammar_dir = :__generated_grammar_dir
        @__generated_grammar_dir = _
        _
      end

      def __generated_grammar_dir
        @__generated_grammar_dir
      end

      # --

      def __call_sub_invocation * sym_a, & p

        # (currently nothing fancy here, but this gives us room for stuff
        # that the "kernel" (monolith) used to be responsible for.
        # see #[#007.C] throughout lib.)

        _nar = MTk_::API_ArgumentScanner.narrator_for sym_a, & @invocation_resources.listener
        _rsx = @invocation_resources.__dup_invocation_resources_ _nar
        _invo = self.class.new _rsx
        _invo.execute
      end

      attr_reader(
        :invocation_resources,  # [pl], here
      )

      def HELLO_INVOCATION  # #todo
        NIL
      end
    end

    # ==

    class InvocationResources___

      def initialize nar
        @argument_scanner_narrator = nar
        freeze
      end

      def __dup_invocation_resources_ as
        self.class.new as  # CAREFUL
      end

      def application_moniker
        # (#todo this is the thing that's redundant with `app_name_string`)
        "tannimous mannimous"
      end

      def listener
        @argument_scanner_narrator.listener
      end

      attr_reader(
        :argument_scanner_narrator,
      )

      def filesystem
        _ = Home_.lib_.system.filesystem
        _  # hi. #todo
      end
    end

    # ==

    Operator_branch___ = Lazy_.call do

      MTk_::ModelCentricFeatureBranch.define do |o|

        # (every imaginable detail of the below is explained at [#pl-011.1])

        # (every action has a file whether or not it needs it per [#pl-011.2])

        same = 'actions'

        o.add_actions_module_path_tail ::File.join 'ping', same

        o.add_model_modules_glob GLOB_STAR_, same

        o.models_branch_module = Home_::Models_

        o.bound_call_when_operation_with_definition_by = -> oo do
          Home_::Model_::Bound_call_via_action_with_definition[ oo.operation ]
        end

        o.filesystem = ::Dir
      end
    end

    class InterfaceExpressionAgent___

      # follows #[#ze-040.8] "the semantic markup guidelines"

      class << self
        def instance
          @___instance ||= new
        end
        private :new
      end  # >>

      alias_method :calculate, :instance_exec

      def simple_inflection & p
        o = dup
        o.extend Home_.lib_.human::NLP::EN::SimpleInflectionSession::Methods
        o.calculate( & p )
      end

      # ~ new stuff to compat with whatever

      def ick_mixed x
        x.inspect
      end

      def ick_oper sym
        ick_prim sym
      end

      def ick_prim sym
        _slug_via_symbol( sym ).inspect
      end

      def prim sym
        symbol_as_identifier_ sym
      end

      def _slug_via_symbol sym
        sym  # oops i'm in API
      end

      def mixed_primitive s  # (probably replaces `val`)
        s.inspect
      end

      # ~ custom stuff

      def sentence_phrase__ * x_a
        _NLP_agent.sentence_phrase_via_mutable_iambic x_a
      end

      def pth s
        if DOT_ == ::File.dirname(s)
          s
        else
          ::File.basename s
        end
      end

      def component_label s  # (to replace `lbl` #todo)
        s.ascii_only?  # hi.
        s.inspect
      end

      def code s
        # (used e.g for showing a snipped of dot language for a digraph)
        "'#{ s }'"
      end

      def app_name_string
        Home_.name_function.as_human
      end

      def symbol_as_identifier_ sym
        "'#{ sym.id2name.gsub UNDERSCORE_, DASH_ }'"
      end

      # ~

      def _NLP_agent
        NLP_agent_instance___[]
      end

      NLP_agent_instance___ = Lazy_.call do
        self::NLP_Agent___.new
      end

      Autoloader_[ self ]
      lazily :NLP_Agent___ do

        cls = ::Class.new

        Home_.lib_.human::NLP::EN::SimpleInflectionSession.edit_module cls,
          :public,
          [ :and_, :indefinite_noun,
            :or_, :plural_noun,
            :s, :sentence_phrase_via_mutable_iambic ]

        cls
      end
    end

    # ==

    ListenerOnly___ = ::Struct.new :listener

    # ==

    DOT_ = '.'
    GLOB_STAR_ = '*'

    # ==
  end
end
# #tombstone-A.1: got rid of remaining unused methods from [br] era
