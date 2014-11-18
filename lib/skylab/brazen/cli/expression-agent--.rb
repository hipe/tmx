module Skylab::Brazen

  class CLI

    class Expression_Agent__

      class << self

        def instance  # see #note-br-10 in [#fa-052]. this is for hacks
          @inst ||= Singleton_instance__[]
        end

        def pretty_path x
          self::Pretty_Path__[ x ]
        end
      end

      def initialize partitions
        @partitions = partitions
      end

      attr_writer :current_property

      alias_method :calculate, :instance_exec

      def and_ a
        _NLP_agent.and_ a
      end

      def app_name
        Brazen_.name_function.as_human
      end

      def s * x_a
        _NLP_agent.s( * x_a )
      end

      GREEN__ = 32
      STRONG__ = 1

      def code string
        "'#{ styl CODE_STYLE__, string }'"
      end
      CODE_STYLE__ = [ GREEN__ ].freeze

      def hdr string
        styl HIGHLIGHT_STYLE__, "#{ string }:"
      end

      def highlight string
        styl HIGHLIGHT_STYLE__, string
      end
      HIGHLIGHT_STYLE__ = [ STRONG__, GREEN__ ].freeze

      def ick s
        code s
      end

      def indefinite_noun * a
        _NLP_agent.indefinite_noun.via_arglist a
      end

      def or_ x
        _NLP_agent.or_ x
      end

      def par prop
        _unstyled = send @partitions.rendering_method_name_for( prop ), prop
        highlight _unstyled
      end

      def plural_noun * a
        _NLP_agent.plural_noun.via_arglist a
      end

      def preterite_verb lemma_i
        _NLP_agent.preterite_verb[ lemma_i.id2name ]
      end

      def progressive_verb lemma_i
        _NLP_agent.progressive_verb[ lemma_i ]
      end

      def property_default
        @current_property.default
      end

      def pth s
        if s.respond_to? :to_path
          s = s.to_path
        end
        if DIR_SEP__ == s.getbyte( 0 )
          self.class::Pretty_Path__[ s ]
        else
          s
        end
      end
      DIR_SEP__ = '/'.getbyte 0

      def render_prop_as_option prop
        "--#{ prop.name.as_slug }"
      end

      def render_prop_as_argument prop
        "<#{ prop.name.as_slug }>"
      end

      def render_prop_as_environment_variable prop
        prop.upcase_environment_name_i.id2name
      end

      def render_prop_as_unknown prop
        "« #{ prop.name.as_human } »"  # :+#guillemets
      end

      public def stylize s, * i_a
        Brazen_::Lib_::Old_CLI_lib[].pen.stylify i_a, s
      end

      def val s
        s.inspect
      end

      # ~ support

      def styl style_d_a, string
        "\e[#{ style_d_a.map( & :to_s ).join( ';' ) }m#{ string }\e[0m"
      end

      def _NLP_agent
        @NLP_agent ||= Brazen_::API.expression_agent_class.NLP_agent.new
      end

      Singleton_instance__ = Callback_.memoize do
        _partitions = Brazen_::Lib_::Proxy_lib[].
          inline :rendering_method_name_for, -> prp do
            :render_prop_as_unknown
          end

        new _partitions
      end
    end
  end
end
