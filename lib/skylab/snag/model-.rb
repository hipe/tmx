module Skylab::Snag

  module Model_

    Listener = Callback_::Ordered_Dictionary.curry :suffix, nil

    Info_Error_Listener = Listener.new :info_event, :error_event

    THROWING_INFO_ERROR_LISTENER = Info_Error_Listener.new nil, -> ev do
      y = []
      ev.render_all_lines_into_under y, Snag_::API::EXPRESSION_AGENT
      raise y * SPACE_
    end

    class Controller

      def initialize listener, _API_client
        @API_client = _API_client
        @listener = listener
      end

      attr_reader :listener
    end

    # ~

    def self.name_function mod
      mod.extend Name_Function_Methods__ ; nil
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

      def self.inline * x_a, & p
        Inline__.new x_a, p
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
      end
    end
  end
end
