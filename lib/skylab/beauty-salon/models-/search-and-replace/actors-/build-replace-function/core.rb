module Skylab::BeautySalon

  class Models_::Search_and_Replace

    class Actors_::Build_replace_function

      class << self
        def [] s, p
          new( s, p ).execute
        end
      end

      def initialize string, p
        @on_event_selectively = p
        @scn = BS_::Lib_::String_scanner[].new string
        @a = []
      end

      def execute
        @result = nil
        until @scn.eos?
          normal = @scn.scan NORMAL_RX__
          open = @scn.scan OPEN_RX__
          if normal
            add_normal_string normal
          end
          if open
            parse_replacement_expression or break
          elsif ! normal
            self._SANITY
          end
        end
        @scn.eos? and flush
        @result
      end

      NORMAL_RX__ = /(?:(?!\{\{).)+/

      OPEN_RX__ = /{{/

      def add_normal_string s
        @a.push Normal_String__.new s ; nil
      end

      def parse_replacement_expression
        @scn.skip WHITE_RX_
        if @scn.skip DOLLA_RX__
          parse_substitution_or_etc
        elsif @scn.skip LITERAL_OPEN_EXPRESSION_RX__
          parse_literal_open_expression
        else
          expected :capture_reference, OPEN_BRACE_EXPRESSON__
        end
      end

      DOLLA_RX__ = /\$/

      LITERAL_OPEN_EXPRESSION_RX__ = /"\{\{"/

      def parse_literal_open_expression
        @scn.skip WHITE_RX_
        if @scn.skip CLOSE_RX_
          @a.push Normal_String__.new OPEN_BRACE_EXPRESSON__
          ACHIEVED_
        else
          expected CLOSE_BRACE_EXPRESSION__
        end
      end

      def parse_substitution_or_etc  # meh
        d = @scn.scan DIGIT_RX__
        if d
          m_a = []
          ok = true
          while @scn.skip DOT_RX__
            name_s = @scn.scan METHOD_NAME_RX__
            if name_s
              m_a.push name_s
            else
              ok = expect :method_name
              break
            end
          end
          if ok
            @scn.skip WHITE_RX_
            if ! @scn.skip CLOSE_RX_
              ok = expected '.', CLOSE_BRACE_EXPRESSION__
            end
            ok and accept_thing d, m_a
          end
          ok
        else
          expected :digit
        end
      end

      DOT_RX__ = /\./

      METHOD_NAME_RX__ = /[a-z_]+/

      def accept_thing d, s_a
        Self_::Build_replace_expression__.with(
          :capture_identifier, d,
          :method_call_chain, s_a,
          :as_normal_value, -> x do
            @a.push x
            ACHIEVED_
          end,
          :on_event_selectively, -> * i_a, & ev_p do
            @result = @on_event_selectively[ * i_a, & ev_p ]
            UNABLE_
          end )
      end

      def expected * x_a
        @result = @on_event_selectively.call :replace_function_parse_error do
          Self_::Parse_error__[ * x_a, @scn ]
        end
        UNABLE_
      end

      def flush
        @result = Self_::Replace_Function__.new @a, @on_event_selectively
        nil
      end

      ACHIEVED_ = true

      DIGIT_RX__ = /\d+/

      class Normal_String__

        def initialize s
          @string = s
        end

        def call md
          @string
        end
      end

      CLOSE_BRACE_EXPRESSION__ = '}}'.freeze

      CLOSE_RX_ = /}}/

      OPEN_BRACE_EXPRESSON__ = '{{'.freeze

      Self_ = self

      WHITE_RX_ = /[[:space:]]+/

    end
  end
end
