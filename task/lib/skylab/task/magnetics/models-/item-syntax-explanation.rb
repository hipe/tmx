class Skylab::Task

  module Magnetics

    Models_::ItemSyntaxExplanation = Common_::Event.prototype_with(

      :item_syntax_explanation,
      :word, nil,
      :unexpected_token_category, nil,
      :state, nil,
      :FSA, nil,
      :token_category_symbols, nil,

    ) do |y, o|
      o.dup.__init_for_explanation( y, self ).__explain
    end

    class Models_::ItemSyntaxExplanation

      class << self
        def begin
          new do
            NOTHING_  # #[#co-070.1] (empty `new` makes malleable mutable)
          end
        end
      end  # >>

      attr_writer( * properties.a_ )

      attr_reader(
        :expected_token_categories,
      )

      def finish
        @expected_token_categories = @FSA.fetch( @state ).keys
        freeze
      end

      def get_channel
        [ :error, :item_syntax_explanation ]  # (or `terminal_channel_symbol`)
      end

      def express_into_under y, expag=nil  # ONLY while we don't use expags
        nil.instance_exec y, self, & message_proc
      end

      def __init_for_explanation y, expag
        @_expag = expag
        @_y = y
        self
      end

      def __explain

        yielder = @_y

        tcat = token_describer_for @unexpected_token_category, @word

        _md = HACK_MATCH_GENERAL_CATEGORY_OF_STATE_RX___.match @state

        _cat = _md[ 1 ].intern

        scat = State_category_object__[ _cat ]

        scat = scat.for @expected_token_categories

        _token_desc = tcat.say_encounter

        _state_desc = scat.say_when_at

        y = ::Enumerator::Yielder.new do |s|
          yielder << "#{ s }#{ NEWLINE_ }"
        end

        y << "#{ _token_desc } #{ _state_desc }."  # #period

        scat.explain_expecting_into_for y, self

        yielder
      end

      def token_describer_for sym, word=nil

        @___tdb ||= Token_Describer_Builder___.new self
        @___tdb.for sym, word
      end

      # == state describing

      HACK_MATCH_GENERAL_CATEGORY_OF_STATE_RX___ = /\A(BT|IT)\d+\z/  # local idiom :/

      State_category_object__ = -> sym do
        case sym
        when :BT
          s = "when expecting the beginning of a term"
        when :IT
          s = "at this point"
        else
          Here_._MISSING_CASE
        end
        State___.new s
      end

      class State___

        def initialize s
          @when_at = s
        end

        def for x
          dup.___for x
        end

        def ___for x
          @expecting_token_category_symbols = x ; self
        end

        def say_when_at
          @when_at
        end

        def explain_expecting_into_for y, exp

          s_a = @expecting_token_category_symbols.map do |sym|
            exp.token_describer_for( sym ).say_short
          end

          # the below is a crude way of avoiding some natural language
          # ambiguities that may arise:
          #
          #   the utterance "A of B, C or D" is amgiguous.
          #   there are two ways for the reader to interpret this:
          #
          #   it could mean this: "(A of B) or (A of C) or (A of D)"
          #
          #   or it could mean this: "(A of B) or (C) or (D)"
          #
          #   if we mean it in the second sense, maybe putting the
          #   longer/more complex item towards the end is better:
          #
          #   "C, D or A of B" is *perhaps* better, but this is hard
          #   to justify fully here.

          this = ' of '
          s_a.sort! do |s, s_|
            if s.include? this
              if s_.include? this
                s <=> s_
              else
                1
              end
            elsif s_.include? this
              -1
            else
              s <=> s_
            end
          end

          # (for now we don't bother with loading [hu] EN..)

          st = Stream_[ s_a ]
          buffer = "expected #{ st.gets }"
          s = st.gets
          if s
            begin
              s_ = st.gets or break
              buffer << ", #{ s }"
              s = s_
              redo
            end while nil
            buffer << " or #{ s }"
          end
          buffer << '.'  # #period

          y << buffer
        end
      end

      # == token describing

      class Token_Describer_Builder___

        def initialize explainer

          @_symbol_is_keyword = ::Hash[ explainer.token_category_symbols.map { |x| [x,true] } ]
          @_keyword_cache = {}
        end

        def for sym, word
          if @_symbol_is_keyword[ sym ]
            # keywords never need to note the actual word
            @_keyword_cache.fetch sym do
              x = Keyword___.new sym
              @_keyword_cache[ sym ] = x
              x
            end
          else
            send :"__describer_for__#{ sym }__", word
          end
        end

        def __describer_for__end__ _
          @___end_o ||= End_token_describer___[]
        end

        def __describer_for__other__ w
          if w
            Other_Token__.new w
          else
            @___generic_other_o ||= Generic_other_token_describer___[]
          end
        end
      end

      # == token describers

      class Keyword___

        def initialize sym
          @symbol = sym
        end

        def say_encounter
          "did not expect to encounter keyword #{ say_short }"
        end

        def say_short
          "'#{ @symbol }'"
        end
      end

      Custom_Token_Category__ = ::Class.new

      class Other_Token__ < Custom_Token_Category__
        def initialize word
          @say_short = "business word \"#{ word }\""
        end
      end

      End_token_describer___ = -> do
        Custom_Token_Category__.new "end of input"
      end

      Generic_other_token_describer___ = -> do
        Custom_Token_Category__.new "a business word"
      end

      class Custom_Token_Category__
        def initialize s
          @say_short = s
        end
        def say_encounter
          "did not expect to encounter #{ say_short }"
        end
        attr_reader(
          :say_short,
        )
      end

      # ==
    end
  end
end
