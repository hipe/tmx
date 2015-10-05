module Skylab::BeautySalon

  module Models_::Search_and_Replace

    class Actors_::Build_replace_function

      class << self
        def [] * a
          new( a ).execute
        end
      end

      def initialize a
        string, @work_dir, @on_event_selectively = a
        @scn = Home_.lib_.string_scanner.new string
        @a = []
      end

      def execute
        @ok = true
        @result = nil
        until @scn.eos?
          normal = @scn.scan NORMAL_RX__
          open = @scn.skip OPEN_RX__
          if normal
            process_normal_mutable_string normal or break
          end
          if open
            parse_replacement_expression or break
          elsif ! normal
            self._SANITY
          end
        end
        @ok and flush
        @result
      end

      NORMAL_RX__ = /(?:(?!\{\{).)+/m

      OPEN_RX__ = /{{/

      def process_normal_mutable_string string
        ok = true
        string.gsub! ETC_RX__ do
          s = $~[ 1 ]
          s and p = UNESCAPE_OK_MAP__[ s.getbyte 0 ]
          if p
            p[ s ]
          else
            @on_event_selectively.call :error, :invalid_escape_sequence, s  # #open :+[#br-066]
            ok = false
            break
          end
        end
        if ok
          @a.push Normal_String__.new string
          ACHIEVED_
        else
          @ok = ok
        end
      end

      ETC_RX__ = /\\(.)?/

      UNESCAPE_OK_MAP__ = {
        '\\'.getbyte( 0 ) => -> _ { '\\' },
        'n'.getbyte( 0 ) => -> _ { "\n" },
        't'.getbyte( 0 ) => -> _ { "\t" } }

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
            ok and accept_thing d, m_a  # sets @ok
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
          :work_dir, @work_dir,
          :when_replace_expression, -> x do
            @a.push x
            ACHIEVED_
          end

        ) do | * i_a, & ev_p |
          @result = @on_event_selectively[ * i_a, & ev_p ]
          @ok = UNABLE_
        end
      end

      def expected * x_a
        @result = @on_event_selectively.call :replace_function_parse_error do
          Self_::Parse_error__[ * x_a, @scn ]
        end
        @ok = UNABLE_
      end

      def flush
        @result = Self_::Replace_Function__.new @a, @on_event_selectively
        nil
      end

      DIGIT_RX__ = /\d+/

      class Normal_String__

        def initialize s
          @string = s
          @as_text = s.gsub ESCAPE_RX__ do
            ESCAPE_OK_MAP__.fetch $~[ 1 ].getbyte 0
          end
        end

        ESCAPE_RX__ = /([\n\t\\])/

        ESCAPE_OK_MAP__ = {
          '\\'.getbyte( 0 ) => "\\\\",
          "\n".getbyte( 0 ) => "\\n",
          "\t".getbyte( 0 ) => "\\t" }

        attr_reader :as_text

        def call md
          @string
        end

        def marshal_dump
          @as_text
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
