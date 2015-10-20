module Skylab::Brazen

  class CLI

    class Expression_Agent

      class << self

        def instance  # see #note-br-10 in [#br-093]. this is for hacks
          @inst ||= Singleton_instance__[]
        end

        def pretty_path x
          self::Pretty_Path__[ x ]
        end
      end  # >>

      def initialize cp
        @categorized_properties = cp
      end

      attr_writer :current_property

      alias_method :calculate, :instance_exec

      def and_ a
        _NLP_agent.and_ a
      end

      def app_name
        @categorized_properties.adapter.bound_.to_kernel.app_name  # ick/meh
      end

      def both x
        _NLP_agent.both x
      end

      GREEN__ = 32
      STRONG__ = 1

      def code string
        "'#{ styl CODE_STYLE__, string }'"
      end
      CODE_STYLE__ = [ GREEN__ ].freeze

      def hdr s

        # (trailing colon must not happen here but at [#072])

        styl HIGHLIGHT_STYLE__, "#{ s }"
      end

      def highlight string
        styl HIGHLIGHT_STYLE__, string
      end
      HIGHLIGHT_STYLE__ = [ STRONG__, GREEN__ ].freeze

      def ick s
        code s
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

        m, * a = @categorized_properties.expression_strategy_for_property prp

        _unstyled = send m, prp, * a

        highlight _unstyled
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

      def property_default
        @current_property.default_value_
      end

      def pth s
        if s.respond_to? :to_path
          s = s.to_path
        end
        if FILE_SEPARATOR_BYTE_ == s.getbyte( 0 )
          CLI::Expression_Agent::Pretty_Path__[ s ]
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

      alias_method :render_property_as_argument_, :render_property_as__argument__

      def render_property_as__environment_variable__ prp
        @categorized_properties.adapter.environment_variable_name_string_via_property prp
      end

      def custom_property_expression_strategy prp, p, * a
        calculate( prp, * a, & p )
      end

      def s * x_a
        _NLP_agent.s( * x_a )
      end

      def sp_ * x_a
        _NLP_agent.sentence_phrase_via_mutable_iambic x_a
      end

      public def stylize s, * i_a
        Home_::CLI::Styling.stylify i_a, s
      end

      def val s
        s.inspect
      end

      # ~ support

      def styl style_d_a, string
        "\e[#{ style_d_a.map( & :to_s ).join( ';' ) }m#{ string }\e[0m"
      end

      def _NLP_agent
        @NLP_agent ||= Home_::API.expression_agent_class.NLP_agent.new
      end

      # ~ begin :+#experiment

      def new_expression_context
        ::String.new
      end

      def modality_const
        :CLI
      end

      def intern  # what expression  adapter should be used?
        :Event
      end

      # ~ end

      Singleton_instance__ = Callback_.memoize do

        _categorized_properties = LIB_.basic::Proxy::Inline.new(

          :expression_strategy_for_property, -> prp do
            :render_property_as_unknown
          end,
        )

        new _categorized_properties
      end
    end
  end
end
