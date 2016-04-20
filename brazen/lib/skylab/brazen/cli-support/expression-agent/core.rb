module Skylab::Brazen

  module CLI_Support

    class Expression_Agent
    private

      class << self

        def instance  # see #note-br-10 in [#br-093]. this is for hacks
          @inst ||= Singleton_instance___[]
        end
      end  # >>

      def initialize ar
        @_action_reflection = ar
      end

      alias_method :calculate, :instance_exec

      def and_ a
        _NLP_agent.and_ a
      end

      def app_name
        @_action_reflection.app_name
      end

      def both x
        _NLP_agent.both x
      end

      GREEN__ = 32
      STRONG__ = 1

      def code string
        "'#{ _stylize CODE_STYLE__, string }'"
      end
      CODE_STYLE__ = [ GREEN__ ].freeze

      def hdr s

        # (trailing colon must not happen here but at [#072])

        _stylize HIGHLIGHT_STYLE__, "#{ s }"
      end

      def highlight string
        _stylize HIGHLIGHT_STYLE__, string
      end
      HIGHLIGHT_STYLE__ = [ STRONG__, GREEN__ ].freeze

      def ick x
        Home_.lib_.basic::String.via_mixed x
      end

      def indefinite_noun lemma_s
        _NLP_agent.indefinite_noun lemma_s
      end

      def nm name
        "'#{ name.as_slug }'"
      end

      def np_ d, s
        _NLP_agent.noun_phrase :subject, d, :subject, s
      end

      def or_ x
        _NLP_agent.or_ x
      end

      def par prp  # referenced by :[#115].

        highlight parameter_in_black_and_white prp
      end

      def parameter_in_black_and_white prp

        m, * a = @_action_reflection.expression_strategy_for_property prp

        send m, prp, * a
      end

      def plural_noun * a
        _NLP_agent.plural_noun( * a )
      end

      def preterite_verb lemma_i
        _NLP_agent.preterite_verb[ lemma_i.id2name ]
      end

      def progressive_verb lemma_i
        _NLP_agent.progressive_verb[ lemma_i ]
      end

      def pth s
        if s.respond_to? :to_path
          s = s.to_path
        end
        if FILE_SEPARATOR_BYTE == s.getbyte( 0 )
          CLI_Support::Expression_Agent::Pretty_Path[ s ]
        else
          s
        end
      end

      def render_property_as__option__ prop
        "--#{ prop.name.as_slug }"
      end

      def render_property_as__argument__ prop
        "<#{ prop.name.as_slug }>"
      end

      alias_method :render_property_as_argument, :render_property_as__argument__

      def render_property_as__environment_variable__ prp
        @_action_reflection.environment_variable_name_string_via_property_ prp
      end

      def s * x_a
        _NLP_agent.s( * x_a )
      end

      def sp_ * x_a
        _NLP_agent.sentence_phrase_via_mutable_iambic x_a
      end

      def stylize s, * i_a
        Home_::CLI_Support::Styling.stylify i_a, s
      end
      public :stylize

      def val x  # assume "primitive"
        x.inspect
      end

      # -- support

      def _stylize style_d_a, string
        "\e[#{ style_d_a.map( & :to_s ).join( ';' ) }m#{ string }\e[0m"
      end

      def _NLP_agent
        @NLP_agent ||= Home_::API.expression_agent_class.NLP_agent.new
      end

      # -- #experiment

    public

      def begin_handler_expresser
        This_::Handler_Expresser.new self
      end

      def new_expression_context
        ::String.new
      end

      def modality_const
        :CLI
      end

      def intern  # what expression adapter should be used?
        :Event
      end
    private

      # --

      def action_reflection  # [bs], [cme]
        @_action_reflection
      end

      Singleton_instance___ = Callback_.memoize do

        _action_reflection = LIB_.basic::Proxy::Inline.new(

          :expression_strategy_for_property, -> prp do
            :render_property_as_unknown
          end,
        )

        new _action_reflection
      end

      This_ = self
    end
  end
end
