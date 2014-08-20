module Skylab::Snag

  module Model_  # [#067].

    Listener = Callback_::Ordered_Dictionary.curry :suffix, nil

    Info_Error_Listener = Listener.new :info_event, :error_event

    THROWING_INFO_ERROR_LISTENER = Info_Error_Listener.new nil, -> ev do
      y = []
      ev.render_all_lines_into_under y, Snag_::API::EXPRESSION_AGENT
      raise y * SPACE_
    end

    # ~

    class Controller

      def initialize listener, _API_client
        @API_client = _API_client
        @listener = listener
      end

      attr_reader :listener
    end

    # ~

    module Actor  # [#066]
      class << self
        def [] cls, * i_a
          cls.extend MM__ ; cls.include self
          while i_a.length.nonzero?
            case i_a.first
            when :properties
              i_a.shift
              cls.const_set :IVAR_I_A__, i_a.map { |i| :"@#{ i }" }
              break
            else
              raise ::ArgumentError, i_a.first
            end
          end ; nil
        end
      end
      module MM__
        def [] * x_a
          new( x_a ).execute
        end
      end
      def initialize x_a
        ivar_i_a = self.class::IVAR_I_A__
        x_a.length.times do |d|
          instance_variable_set ivar_i_a.fetch( d ), x_a.fetch( d )
        end ; nil  # #etc
      end
    private

      def send_info_event * x_a, & p
        _ev = build_and_sign_inline_event x_a, p
        @listener.receive_info_event _ev
        NEUTRAL_
      end

      def send_error_event * x_a, & p
        _ev = build_and_sign_inline_event x_a, p
        @listener.receive_error_event _ev
        UNABLE_
      end

      def build_and_sign_inline_event x_a, p
        sign_event Event.inline_via_x_a_and_p x_a, p
      end

      def sign_event ev
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
          Callback_::Name.from_variegated_symbol( s.intern ).as_slug
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

    class << self
      def name_function mod
        mod.extend Name_Function_Methods__ ; nil
      end
    end

    module Name_Function_Methods__  # infects upwards
      def name_function
        @nf ||= bld_name_function
      end
      def full_name_function
        @fnf ||= bld_full_name_function
      end
    private
      def bld_full_name_function
        y = [ nf = name_function ]
        y.unshift nf while (( parent = nf.parent and nf = parent.name_function ))
        y.freeze
      end
      def bld_name_function
        s_a = name.split Callback_::CONST_SEP_
        i = s_a.pop.intern
        x_a = ::Array.new s_a.length
        mod = ::Object
        s_a.each_with_index do |s, d|
          mod = mod.const_get s, false
          x_a[ d ] = mod
        end
        d = s_a.length
        until STOP_INDEX__ == ( d -= 1 )
          mod = x_a.fetch d
          if ! mod.respond_to? :name_function
            TAXONOMIC_MODULE_RX__ =~ s_a.fetch( d ) and next
            mod.extend Name_Function_Methods__
          end
          parent = mod
          break
        end
        Name_Function__.new i, parent
      end
      STOP_INDEX__ = 3  # skylab snag cli actions foo actions bar
      TAXONOMIC_MODULE_RX__ = /\A(?:Actions)\z/  # meh / wee
    end

    class Name_Function__ < Callback_::Name
      class << self
        public :new
      end
      def initialize const_i, parent
        @parent = parent
        initialize_with_const_i const_i
      end
      attr_reader :parent
    end

    Actor::MM__.include Name_Function_Methods__

    # ~

    class Event < ::Struct

      Snag_::Lib_::Model_event[ self ]

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

        def render_all_lines_into_under y, expression_agent
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
          @verb_lexeme ||= Snag_::Lib_::NLP[]::EN::POS::Verb[ inflected_verb ]
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
          @verb_lexeme ||= Snag_::Lib_::NLP[]::EN::POS::Verb[ @inflected_verb ]
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
