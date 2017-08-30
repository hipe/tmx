module Skylab::Zerk

  module CLI::InterfaceExpressionAgent

    class THE_LEGACY_CLASS

      class << self

        # --
        #   - for the legacy (but probably enduring) style of expag, to use
        #     a singleton like this comes with [#040.15] costs.
        #
        #   - this is a fallback implementation that does ugly, placeholder
        #     styling, if you haven't yet or don't care to do a complicated
        #     expag-bound-to-action and [#br-002.5] association classification)
        #

        def instance
          @___instance ||= __instance
        end

        def __instance
          proc_based_by do |o|

            o.render_property_by do |asc, _expag|
              _slug = if asc.respond_to? :name
                self._HELLO__easy_etc__  # #todo
              else
                asc.name_symbol.id2name.gsub UNDERSCORE_, DASH_
              end
              "«[ze]#{ _slug }»"  # #guillemets
            end
          end
        end

        def proc_based_by & p
          _inj = ProcBasedArgumentElementExpresser___.define( & p )
          via_expression_agent_injection _inj
        end

        alias_method :via_expression_agent_injection, :new
        undef_method :new
      end  # >>

      # --

      def initialize inj
        @_injection = inj
      end

      # --

    private

      alias_method :calculate, :instance_exec

      public def simple_inflection & p
        o = dup
        o.extend Home_.lib_.human::NLP::EN::SimpleInflectionSession::Methods
        o.calculate( & p )
      end

      # --

      def and_ a
        _NLP_agent.and_ a
      end

      def app_name_string
        @_injection.app_name_string
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

        # (trailing colon must not happen here but at [#051.1])

        _stylize HIGHLIGHT_STYLE__, "#{ s }"
      end

      def highlight string
        _stylize HIGHLIGHT_STYLE__, string
      end
      HIGHLIGHT_STYLE__ = [ STRONG__, GREEN__ ].freeze

      def ick x
        Home_.lib_.basic::String.via_mixed x
      end
      alias_method :ick_mixed, :ick

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

      def par asc  # referenced by :[#115].
        if asc
          highlight parameter_in_black_and_white asc
        else
          asc
        end
      end

      def parameter_in_black_and_white asc

        m, * a = @_injection.expression_strategy_for_property asc

        send m, asc, * a
      end

      rx = nil
      define_method :singularize do | s |  # #open [#hu-045]
        rx ||= /\A.+(?=s\z)/
        rx.match( s )[ 0 ]
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

        if Home_.lib_.system.path_looks_absolute s

          @___pather ||= Home_.lib_.system.new_pather
          @___pather.call s
        else
          s
        end
      end

      def render_property_in_black_and_white_customly asc
        @_injection.render_property_in_black_and_white_customly asc, self
      end

      def render_property_as__option__ asc
        "--#{ _name_of( asc ).as_slug }"
      end

      def render_property_as__argument__ asc
        "<#{ _name_of( asc ).as_slug }>"
      end

      alias_method :render_property_as_argument, :render_property_as__argument__

      def render_property_as__environment_variable__ asc
        @_injection.environment_variable_name_string_via_property_ asc
      end

      def render_propperty_without_styling asc
        _name_of( asc ).as_slug
      end

      def s * x_a
        _NLP_agent.s( * x_a )
      end

      def sp_ * x_a
        _NLP_agent.sentence_phrase_via_mutable_iambic x_a
      end

      def stylize s, * i_a
        CLI::Styling.stylify i_a, s
      end
      public :stylize

      def mixed_primitive s
        # (this method is to replace `val` eventually)
        s.inspect
      end

      def val x  # assume "primitive"
        x.inspect
      end

      # -- while we don't know what we're doing

      def ick_oper sym
        oper( sym ).inspect
      end

      def oper sym
        self._WRONG
        "--#{ sym.id2name.gsub UNDERSCORE_, DASH_ }"
      end

      def ick_prim sym
        prim( sym ).inspect
      end

      def prim sym
        "-#{ sym.id2name.gsub UNDERSCORE_, DASH_ }"
      end

      # -- support

      def _stylize style_d_a, string
        "\e[#{ style_d_a.map( & :to_s ).join( ';' ) }m#{ string }\e[0m"
      end

      def _NLP_agent
        @___NLP_agent ||= Home_::Expresser::NLP_EN_ExpressionAgent.new
      end

      def _name_of asc
        if asc.respond_to? :name
          asc.name
        else
          Common_::Name.via_lowercase_with_underscores_symbol asc.name_symbol
        end
      end

      # -- #experiment

    public

      def begin_handler_expresser
        Home_::Expresser.via_expression_agent self
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
        @_injection
      end

      # ==

      class ProcBasedArgumentElementExpresser___ < Common_::SimpleModel

        # instead of subclassing your expag..

        def render_property_by & two_p

          self.expression_strategy_for_property = -> _prp do
            :render_property_in_black_and_white_customly
          end

          self.render_property_in_black_and_white_customly = -> asc, expag do
            two_p[ asc, expag ]  # hi.
          end
          NIL
        end

        attr_writer(
          :expression_strategy_for_property,
          :render_property_in_black_and_white_customly,
        )

        # -- read:

        def expression_strategy_for_property asc
          @expression_strategy_for_property[ asc ]
        end

        def render_property_in_black_and_white_customly asc, expag
          @render_property_in_black_and_white_customly[ asc, expag ]
        end
      end

      # ==
      # ==
    end  # the legacy class
  end  # module "interface expression agent"
end
# #history: beginning hopefully final unification into [ze]
