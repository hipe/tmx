module Skylab::Snag

  class CLI

    class InterfaceExpressionAgent

      # subclass Home_.lib_.CLI_lib::Pen::Minimal for less DIY

      def initialize action_reflection

        @_action_reflection = action_reflection

        @_up =
          Home_::Models_::NodeCollection::ExpressionAdapters::ByteStream.
            build_default_expression_agent
      end

      alias_method :calculate, :instance_exec

      # ~

      def code s
        _technical s
      end

      def em s
        _strongly_emphasized s
      end

      def h2 s
        _somewhat_emphasized s
      end

      def hdr s
        _somewhat_emphasized s
      end

      define_method :ick, -> do
        p = -> x do
          p = Home_.lib_.strange.to_proc.curry[ LIB_.a_short_length ]
          p[ x ]
        end
        -> x { p[ x ] }
      end.call

      def kbd s
        _technical s
      end

      # ~~ (

      def par x  # :+[#br-115]

        _m = @_action_reflection.expression_strategy_for_property x
        _unstyled = send _m, x
        _strongly_emphasized _unstyled
      end

      def render_property_as__argument__ asc
        "<#{ _name_of( asc ).as_slug }>"
      end

      def render_property_as__option__ asc
        "--#{ _name_of( asc ).as_slug }"
      end

      def render_property_as_unknown asc
        "«#{ _name_of( asc ).as_slug }»"  # :+#guillemets
      end

      # ~~ )

      def pth x

        if x.respond_to? :to_path
          x = x.to_path
        end

        if ::File::SEPARATOR == x[ 0 ]
          @___pather ||= Home_.lib_.system.new_pather
          @___pather.call x
        else
          x
        end
      end

      def val x
        _strongly_emphasized x
      end

      # ~

      h = { strong: 1, green: 32 }.freeze
      o = -> * i_a do
        fmt = "\e[#{ i_a.map { |i| h.fetch i } * ';' }m"
        -> x do
          "#{ fmt }#{ x }\e[0m"
        end
      end

      define_method :_somewhat_emphasized, o[ :green ]  # no effect on my term

      define_method :_strongly_emphasized, o[ :strong, :green ]

      def _technical x
        _somewhat_emphasized "'#{ x }'"
      end

      # ~

      def and_ a
        _NLP_agent.and_ a
      end

      def indefinite_noun s
        _NLP_agent.indefinite_noun s
      end

      def or_ a
        _NLP_agent.or_ a
      end

      def plural_noun d=nil, s
        _NLP_agent.plural_noun d, s
      end

      def s * a
        _NLP_agent.s( * a )
      end

      def _NLP_agent
        @___NLP_agent ||= Zerk_lib_[]::Expresser::NLP_EN_ExpressionAgent.new
      end

      # ~ suport

      def _name_of asc
        if asc.respond_to? :name
          asc.name
        else
          Common_::Name.via_lowercase_with_underscores_symbol asc.name_symbol
        end
      end

      def identifier_integer_width
        @_up.identifier_integer_width
      end

      # ~

      def modality_const
        :CLI
      end

      def intern
        :Event
      end
    end
  end
end
# #tombstone-A: there was a counterpart expression agent for API, not used, orphanic
