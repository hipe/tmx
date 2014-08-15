module Skylab::Snag

  module Model_

    Info_Error_Listener = Callback_::Ordered_Dictionary.new :info, :error

    THROWING_INFO_ERROR_LISTENER = Info_Error_Listener.new nil, -> ev do
      raise ev.render_under_expression_agent Snag_::API::EXPRESSION_AGENT
    end

    def self.name_function mod
      mod.extend Name_Function_Methods__ ; nil
    end

    module Name_Function_Methods__  # infects upwards
      def name_function
        @nf ||= bld_name_function
      end
    private
      def bld_name_function
        s_a = name.split Callback_::CONST_SEP_
        _i = s_a.pop.intern
        parent = ( s_a.length.nonzero? and
          s_a.reduce( ::Object ) do |m, s|
            m.const_get s, false
          end )
        if parent and ! parent.respond_to? :name_function
          parent.extend Name_Function_Methods__
        end
        Name_Function__.new _i, parent
      end
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

        def can_render_under  # :+#comport
          !! message_proc
        end

        attr_reader :message_proc

        def render_under client
          render_under_expression_agent client.expression_agent
        end

        def render_under_expression_agent expression_agent
          y = []
          expression_agent.calculate y, self, & message_proc
          y * LINE_SEP_
        end

        self
      end

      def self.from_string s, v=nil, n=nil
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

      def self.from_event ev
        Event_Inflection_Wrapper__.new ev
      end
      class Event_Inflection_Wrapper__
        def initialize ev
          @ev = ev
        end
        attr_accessor :inflected_verb, :inflected_noun
        def verb_lexeme
          @verb_lexeme ||= Snag_::Lib_::NLP[]::EN::POS::Verb[ @inflected_verb ]
        end
        attr_writer :verb_lexeme
        def can_render_under
          @ev.can_render_under
        end
        def render_under x
          @ev.render_under x
        end
      end
    end
  end
end
