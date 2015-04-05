module Skylab::Snag

  module Model_  # [#067].

    Delegate = Callback_::Ordered_Dictionary.curry :suffix, nil

    Info_Error_Delegate = Delegate.new :info_event, :error_event

    THROWING_INFO_ERROR_delegate = Info_Error_Delegate.new nil, -> ev do
      y = []
      ev.express_into_under y, Snag_::API::EXPRESSION_AGENT
      raise y * SPACE_
    end

    # ~

    class Controller

      def initialize delegate, _API_client
        @API_client = _API_client
        @delegate = delegate
      end

      attr_reader :delegate
    end

    # ~

    module Actor

    private

      def send_info_event * x_a, & p
        _ev = build_and_sign_inline_event x_a, p
        @delegate.receive_info_event _ev
        NEUTRAL_
      end

      def send_error_event * x_a, & p
        _ev = build_and_sign_inline_event x_a, p
        @delegate.receive_error_event _ev
        UNABLE_
      end

      def build_and_sign_inline_event x_a, p
        sign_event Event.inline_via_x_a_and_p x_a, p
      end

      def sign_event ev  # :[#069].
        ev_ = Event.inflectable_via_event ev
        ev_.inflected_verb = inflected_verb
        ev_.inflected_noun = inflected_noun
        ev_
      end

      def inflected_noun
        inferred_stems.noun
      end

      def inflected_verb
        inferred_stems.verb
      end

      def inferred_stems
        @inferred_stems ||= bld_infered_stems
      end

      def bld_infered_stems  # #note-80 (of [#066]
        s_a = self.class.name_function.as_const.to_s.split( /_+/ ).map do |s|
          Callback_::Name.via_variegated_symbol( s.intern ).as_slug
        end
        if 1 == s_a.length
          noun_s = s_a.first
          verb_s = DEFAULT_INFERRED_VERB__
        else
          verb_s = s_a.shift
          noun_s = s_a * SPACE_
        end
        Inferred_Stems__.new verb_s, noun_s
      end
      DEFAULT_INFERRED_VERB__ = 'build'.freeze
      Inferred_Stems__ = ::Struct.new :verb, :noun
    end

    # ~

    class Event < ::Struct

      Snag_.lib_.model_event self

      EVENTS_ANCHOR_MODULE = Snag_::Models

      class << self
        def message_proc & p
          define_method :message_proc do
            p
          end
        end
      end

      include module Event_Instance_Methods__

        def is_event  # :+#comport
          true
        end

        attr_reader :message_proc

        def to_exception  # ick this inspired #open [#066]
          _expag = Snag_.lib_.brazen::API.expression_agent_instance
          _a = express_into_under [], _expag
          ::RuntimeError.new _a * SPACE_
        end

        def express_into_under y, expression_agent
          expression_agent.calculate y, self, & message_proc
        end

        self
      end

      def self.inflectable_via_string s, v=nil, n=nil
        String__.new s, v, n
      end
      String__ = new :message_s, :inflected_verb, :inflected_noun do
        message_proc do |y, o|
          y << o.message_s
        end
        def verb_lexeme
          @verb_lexeme ||= Snag_.lib_.NLP::EN::POS::Verb[ inflected_verb ]
        end
        attr_writer :verb_lexeme
      end

      # ~

      class << self

        def inline * x_a, & p
          Inline__.new x_a, p
        end

        def inline_via_x_a_and_p x_a, p
          Inline__.new x_a, p
        end
      end

      class Inline__
        include Event_Instance_Methods__
        def initialize x_a, p
          @message_proc = p
          @terminal_channel_i = x_a.fetch 0
          d = -1 ; last = x_a.length - 2 ; sc = singleton_class
          while d < last
            d += 2 ; i = x_a.fetch d
            sc.send :attr_reader, i
            instance_variable_set :"@#{ i }", x_a.fetch( d + 1 )
          end ; nil
        end
        attr_reader :terminal_channel_i
      end

      def self.inflectable_via_event ev
        Event_Inflection_Wrapper__.new ev
      end
      class Event_Inflection_Wrapper__
        def initialize ev
          @ev = ev
        end
        attr_reader :ev
        attr_accessor :inflected_verb, :inflected_noun
        def verb_lexeme
          @verb_lexeme ||= Snag_.lib_.NLP::EN::POS::Verb[ @inflected_verb ]
        end
        attr_writer :verb_lexeme
        def message_proc
          @ev.message_proc
        end

        def terminal_channel_i
          @ev.terminal_channel_i
        end
      end
    end
  end
end
