module Skylab::Snag

  class CLI

    class Action_

      ACTIONS_ANCHOR_MODULE = -> { CLI::Actions }

      Home_.lib_.CLI_lib.action self, :DSL

      extend Home_.lib_.NLP::EN::API_Action_Inflection_Hack

      inflection.inflect.noun :singular

      def initialize client=nil
        if client
          super client
        else
          super()
        end
        @param_h = {}
      end

    protected  # or public, whatever

      # ~ comport #hook-out's

      def program_name
        @request_client.program_name
      end

      def rtrv_unbound_action x
        @request_client.rtrv_unbound_action x
      end

      def receive_UI_line s
        delegate.receive_UI_line s
      end

    private

      def retrieve_param_for_expression_agent i
        if @option_parser.top.long.key?( i.to_s  )
          Home_.lib_.CLI::Option.on "--#{ i }"
        else
          _fp = Fake_Formal_Parameter__.new Callback_::Name.via_variegated_symbol i
          Home_.lib_.CLI_lib.argument _fp, :req
        end
      end
      Fake_Formal_Parameter__ = ::Struct.new :name

      def send_UI_line s
        delegate.receive_UI_line s
      end

      def handle_payload_line
        method :receive_payload_line
      end

      protected def receive_payload_line s
        send_payload_line s
      end

      def send_payload_line s
        delegate.receive_payload_line s
      end

      def handle_info_line
        method :receive_info_line
      end

      def handle_inside_info_string
        method :receive_inside_info_string
      end

      protected def receive_info_line s
        send_info_line s
      end

      def send_info_line s
        delegate.receive_info_line s
      end

      def handle_info_string
        method :receive_info_string
      end

      def receive_inside_info_string s
        ev = Home_::Model_::Event.inflectable_via_string s
        inflect_inflectable_event ev
        receive_info_event ev
      end

      def receive_info_string s
        delegate.receive_info_string s
      end

      def handle_info_event
        method :receive_inside_info_event
      end

      def receive_inside_info_event ev
        _ev_ = sign_event ev
        delegate.receive_info_event _ev_
      end

      protected def receive_info_event ev
        delegate.receive_info_event ev
      end

      def handle_error_line
        method :receive_error_line
      end

      def receive_error_line s
        delegate.receive_error_line s
      end

      def handle_error_string
        method :receive_error_string
      end

      def receive_error_string s
        ev = Home_::Model_::Event.inflectable_via_string s
        inflect_inflectable_event ev
        delegate.receive_error_event ev
      end

      def handle_error_event
        method :receive_inside_error_event
      end

      def receive_inside_error_event ev
        _ev_ = sign_event ev
        delegate.receive_error_event _ev_
      end

      protected def receive_error_event ev
        delegate.receive_error_event ev
      end

      def delegate
        @request_client
      end

      def invite_to_self
        if @is_engaged
          invite_via_bound_action @bound_downtree_action
        else
          invite_via_bound_action self
        end
      end

      # ~ inflection ("signing")

      def inflect_inflectable_event ev
        verb_class = if @is_engaged
          @bound_downtree_action.class
        else
          self.class
        end
        vnf = verb_class.name_function
        if vnf
          ev.inflected_verb = vnf.as_human
          inflect_inflectable_event_with_any_noun ev, verb_class
        end
      end

      def inflect_inflectable_event_with_any_noun ev, verb_class
        noun_cls = verb_class.name_function.parent
        noun_cls and nnf = noun_cls.name_function
        nnf and inflect_inflectable_event_with_noun ev, nnf,
          verb_class.inflection ; nil
      end

      def inflect_inflectable_event_with_noun ev, nnf, inflection
        inflected_noun_s = nnf.as_human
        looks_plural = HACK_DETERMINE_IS_PLURAL_RX__.match inflected_noun_s
        case inflection.inflect.noun
        when :singular
          if looks_plural
            inflected_noun_s = looks_plural.pre_match
          end
        when :plural
          if ! looks_plural
            inflected_noun_s = "#{ inflected_noun_s }s"
          end
        else self._DO_ME
        end
        ev.inflected_noun = inflected_noun_s ; nil
      end

      HACK_DETERMINE_IS_PLURAL_RX__ = /s\z/


      class Leaf_Action__ < self
        extend Skylab::Headless::Action::Anchored_Name_MMs  # we will override it
        extend NF_[].name_function_proprietor_methods
      end

      extend NF_[].name_function_proprietor_methods

      class Box < self

        Home_.lib_.CLI_lib::Box[ self, :DSL,
          :leaf_action_base_class, -> { Leaf_Action__ } ]

        def self.inflection
          if crrnt_open_action_cls
            @crrnt_open_action_cls.inflection
          else
            super
          end
        end

        include Invocation_Methods_

        def initialize client_x, _=nil  # (namespace sheet, not interesting)
          super client_x
        end

        # ~ framework-specific comportments (for [po] "legacy" f.w)

        def resolve_argv argv
          [ nil, method( :invoke ), [ argv ] ]  # compat legacy
        end

        Adapter = Home_::Lib_::Porcelain__[]::Legacy::Adapter
      end

      include Invocation_Methods_  # after box above
    end
  end
end
