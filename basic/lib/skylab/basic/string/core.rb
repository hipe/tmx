# frozen_string_literal = true

module Skylab::Basic

  module String  # notes in [#029]

    class << self

      def build_proc_for_string_begins_with_string * a
        if a.length.zero?
          Here_::Small_Procs__::Build_proc_for_string_begins_with_string
        else
          Here_::Small_Procs__::Build_proc_for_string_begins_with_string[ * a ]
        end
      end

      def build_proc_for_string_ends_with_string * a
        if a.length.zero?
          Here_::Small_Procs__::Build_proc_for_string_ends_with_string
        else
          Here_::Small_Procs__::Build_proc_for_string_ends_with_string[ * a ]
        end
      end

      def component_model_for sym
        Require_components_models___[]
        Component_Models.const_get sym, false
      end

      def count_occurrences_in_string_of_string haystack, needle
        Here_::Magnetics__::OccurrenceCount_via_Needle_in_Haystack.call(
          needle, haystack )
      end

      def count_occurrences_in_string_of_regex haystack, needle_rx
        Here_::Magnetics__::OccurrenceCount_via_Regex_in_String.call(
          needle_rx, haystack )
      end

      def ellipsify * a  # [#032].
        Here_::Magnetics__::Ellipsify_via_String.call_via_arglist a
      end

      def looks_like_sentence * a
        if a.length.zero?
          Here_::Small_Procs__::Looks_like_sentence
        else
          Here_::Small_Procs__::Looks_like_sentence[ * a ]
        end
      end

      def members
        singleton_class.public_instance_methods( false ) - [ :members ]
      end

      def mustache_regexp
        MUSTACHE_RX___
      end

      MUSTACHE_RX___ = / {{ ( (?: (?!}}) [^{] )+ ) }} /x

      define_method :mutate_by_unindenting, -> do  # see [#here.B]

        say = nil ; rx = nil
        p = -> s do

          rx ||= /^(?<leading_whitespace>[ \t]+)(?=[^[:space:]])/
          md = rx.match s
          md or fail say[s]

          _rx = /^#{ ::Regexp.escape md[ :leading_whitespace ] }/

          s.gsub! _rx, EMPTY_S_

          NIL_  # don't result a mutant
        end
        say = -> _s do
          "found no line that had both nonzero-width leading whitespace and content"
        end
        p
      end.call

      def paragraph_string_via_message_lines * a
        if a.length.zero?
          Here_::Small_Procs__::Paragraph_string_via_message_lines
        else
          Here_::Small_Procs__::Paragraph_string_via_message_lines[ * a ]
        end
      end

      def quoted_string_literal_library
        Quoted_string_literal_library___[]
      end

      def a_reasonably_short_length_for_a_string
        A_REASONABLY_SHORT_LENGTH_FOR_A_STRING_
      end

      def regex_for_line_scanning
        LINE_RX_
      end

      def reverse_scanner string, d
        Here_::Small_Procs__::Build_reverse_scanner[ string, d ]
      end

      def shortest_unique_or_first_headstrings a
        h = nil
        Home_::Hash::Hotstrings[ a ].each_with_index.map do | hs, d |
          if hs
            hs.hotstring
          else
            h ||= {}
            s = a.fetch d
            h.fetch s do
              h[ s ] = nil
              s
            end
          end
        end
      end

      def unparenthesize_message_string * a
        if a.length.zero?
          Here_::Magnetics__::UnparenthesizedPieces_via_MessageString
        else
          Here_::Magnetics__::UnparenthesizedPieces_via_MessageString[ * a ]
        end
      end

      def via_mixed * a
        Here_::ViaMixed__.call_via_arglist a
      end
    end  # >>

    class N_Lines  # :[#030].

      class << self
        alias_method :session, :new
        private :new
      end  # >>

      def initialize
        NOTHING_  # (hi.)
      end

      attr_writer(
        :description_proc,
        :downstream_line_yielder,
        :expression_agent,
        :number_of_lines,
      )

      def describe_by & p
        @description_proc = p ; nil
      end

      def execute * a
        ___prepare
        __execute a
      end

      def ___prepare

        @downstream_line_yielder ||= []

        n = @number_of_lines

        if n
          if 0 < n
            @_allow_at_least_one_line = true
            d = 0
            stop_p = -> do
              d += 1
              n == d
            end
          else
            @_allow_at_least_one_line = false
          end
        else
          @_allow_at_least_one_line = true
          stop_p = NILADIC_FALSEHOOD_
        end

        @_receive_line = -> line do

          @downstream_line_yielder << line
          _stop = stop_p[]
          if _stop
            throw :__done_with_N_lines__
          end
          NIL_
        end

        NIL_
      end

      def __execute user_x_a

        if @_allow_at_least_one_line

          y = ::Enumerator::Yielder.new do | line |
            # (hi.)
            @_receive_line[ line ]
          end

          catch :__done_with_N_lines__ do

            @expression_agent.calculate y, * user_x_a, & @description_proc
          end
        end

        @downstream_line_yielder
      end
    end

    Require_components_models___ = Common_.memoize do

      module Component_Models

        module NONBLANK_TOKEN

          nb_t_rx = /\A[-A-Za-z0-9_]+\z/  # or w/e

          same = -> arg_st, & p_p do

            x = arg_st.head_as_is

            if nb_t_rx =~ x

              Common_::KnownKnown[ arg_st.gets_one.to_sym ]

            else

              _p = p_p[ nil ]  # no entity

              _p.call :error, :expression, :is_not, :nonblank_token do | y |
                y << "must be a valid nonblank token (had #{ ick x })"
              end

              UNABLE_
            end
          end

          define_singleton_method :[], same
          define_singleton_method :call, same
        end

        NONBLANK = Home_::Regexp.build_component_model do | o |

          o.matcher = /[^[:space:]]/

          o.on_failure_to_match = -> _reserved, & p do

            p.call :error, :expression, :is_not, :nonblank do | y |
              y << "cannot be blank"
            end

            UNABLE_
          end
        end
      end
      NIL_
    end

    class Receiver

      # (a base class to make proxies that receive strings)

      def initialize
        yield self
        freeze
      end

      define_method :[]=, -> do

        h = {
          :receive_line_args => :"@receive_line_args",
          :receive_string => :"@receive_string",
        }

        -> k, p do
          instance_variable_set h.fetch( k ), p
        end
      end.call
    end

    class Receiver::As_IO < Receiver

      # a bespoke #[#sy-039.1] one of many such proxies

      def << s
        @receive_string[ s ]
        self
      end

      def puts * line_a
        @receive_line_args[ line_a ]
        NIL_
      end

      def write s
        @receive_string[ s ]
        s.length
      end
    end

    Quoted_string_literal_library___ = Lazy_.call do

      module QUOTED_LITERAL_STRING_LIBRARY____

        _this = -> scn do

          md = SCANNER_MATCH_RX___.match scn.string, scn.pos
          if md
            scn.pos = md.offset( 0 ).last
            Unescape_matchdata[ md ]
          end
        end

        say_etc = nil
        Unescape_matchdata = -> md, & l do

          s = md[ :double_quoted_bytes ]
          if s
            schema = DOUBLE_UNESCAPING_SCHEMA___
          else
            s = md[ :single_quoted_bytes ]
            schema = SINGLE_UNESCAPING_SCHEMA___
          end

          s.gsub schema.rx do

            # (once you get inside here, it means that yes the string
            #  probably had ostensible escape sequences in it.)

            char = $~[ :special_char ]  # a string one character in length
            map = schema.escape_map
            had = true
            x = map.fetch char do
              had = false
            end
            if had
              x
            elsif l
              l.call :error, :expression, :unsupported_escape_sequence do |y|
                y << say_etc[ char, schema ]
              end
              UNABLE_
            else
              raise say_etc[ char, schema ]
            end
          end
        end

        say_etc = -> char, schema do  # #covered-by [dt]

          _s_a = schema.escape_map.keys.map do |s|
            s.inspect
          end

          _these = Common_::Oxford_and[ _s_a ]

          "in a #{ schema.adjective }-quoted string, #{
            }we don't know how to unescape #{ char.inspect } #{
            }(this is only a hack). #{
            }we only know how to unescape #{ _these }."
        end

        Unescaping_Schema__ = ::Struct.new :rx, :escape_map, :adjective

        bslash = '\\'
        dquote = '"'
        squote = "'"

        DOUBLE_UNESCAPING_SCHEMA___ = Unescaping_Schema__.new(
          / \\ (?<special_char> . ) /x,
          {
            bslash => bslash,
            dquote => dquote,
            'n'    => NEWLINE_,
          },
          "double",
        )

        SINGLE_UNESCAPING_SCHEMA___ = Unescaping_Schema__.new(
          / \\ (?<special_char> . ) /x,  # should probably tighten this
          {
            squote => squote,
            bslash => bslash,
          },
          "single",
        )

        # --

        quoted_string_part = %q<
          (?:
            " (?<double_quoted_bytes> (?: [^\\\\"] | \\\\. )* ) " |
            ' (?<single_quoted_bytes> (?: [^\\\\'] | \\\\. )* ) '
          )
        >
        # #coverpoint4.3 (in [dt]!): we need those four (or three :/) backslashes.)

        QUOTED_STRING_REGEX_PART = quoted_string_part
        SCANNER_MATCH_RX___ = /\G#{ quoted_string_part }/x

        define_singleton_method :unescape_quoted_literal_at_scanner_head, _this

        self
      end
    end

    # ==

    class CharacterEscapingPolicy < Common_::SimpleModel

      #   - character escaping is often something we call a vendor function
      #     for; where it "just works" and we don't have to think about it.
      #
      #   - but when implementing your own encoding policy (for whatever
      #     reason), you *do* have to think about it.
      #
      #   - a shotgun approach won't work. we can't do a one-size fits most.
      #     e.g `'\n'` and `"\n"` represent two different strings. failure
      #     to model the policy correctly corrupts data.
      #
      #   - although a switch statement or similar is a reasonable approach
      #     for a standalone use-case, it does not lend itself well to re-use
      #     across different policies with only slight variation. copy-paste-
      #     modify leads to logical redundancy.
      #
      #   - this arrangement allows us to dup-and-mutate policies, if desired.
      #     (for while we typically want newline to be backslash-n, in one
      #     place we want it to be backslash newline.)

      def initialize  # (in effect, redefine `define`)
        @default_by = nil
        yield self, FUNCTION_FUNCTIONS__
        freeze
      end

      def redefine  # compare Common_::SimpleModel::DEFINITION_FOR_THE_METHOD_CALLED_REDEFINE
        otr = dup
        yield otr, FUNCTION_FUNCTIONS__
        otr.freeze
      end

      def default_by & p
        @default_by = p ; nil
      end

      attr_writer(
        # (in order of common-ness)
        :double_quote,
        :single_quote,
        :newline,
        :backslash,
        :carriage_return,
        :tab,
        :forward_slash,
        :ASCII_escape,
        :alert_bell,
      )

      def call single_char_s
        # #todo benchmark etc
        p = case single_char_s
        when '"'   ; @double_quote
        when %q(') ; @single_quote
        when "\n"  ; @newline
        when "\\"  ; @backslash
        when "\r"  ; @carriage_return
        when "\t"  ; @tab
        when "\e"  ; @ASCII_escape
        when "\b"  ; @alert_bell
        when '/'   ; @forward_slash
        else
          pp = @default_by
          if pp
            pp
          else
            fail Exception, "not (yet) policy-able: #{ single_char_s.inspect }"
          end
        end
        ( p || Undefined_escaping_function___ )[ single_char_s ]
      end

      alias_method :[], :call
    end

    module FUNCTION_FUNCTIONS__ ; class << self

      def use_this_string_instead s
        -> _ do
          s
        end
      end

      def escape_it_with_a_backslash
        Escape_it_with_a_backslash___
      end
    end ; end

    Escape_it_with_a_backslash___ = -> s do
      "\\#{ s }"
    end

    Undefined_escaping_function___ = -> s do
      fail Exception, "no escaping policy is defined for #{ s.inspect }"
    end

    # ==

    Tailerer_via_separator = -> sep do

      # a "tail" is the second half of a string (e.g path) split meaningfully
      # in two. a "tailer" is a function that produces tails. so a "tailerer"..

      # this is a supertreatment of [ba]::Pathname::Localizer

      -> head, & els do
        head_len = head.length
        head_plus_sep = "#{ head }#{ sep }"
        head_plus_sep_len = head_plus_sep.length
        r = head_plus_sep_len .. -1

        -> s, & els_ do

          len = s.length
          case head_len <=> len
          when -1
            if head_plus_sep == s[ 0, head_plus_sep_len ]
              s[ r ]
            else
              ( els || els_ )[]
            end
          when 0
            if head == s
              EMPTY_S_
            else
              ( els || els_ )[]
            end
          else
            ( els || els_ )[]
          end
        end
      end
    end

    # ==

    Autoloader_[ self ]
    lazily :ByteDownstreamReference do
      const_get :ByteUpstreamReference, false
      const_defined? :ByteDownstreamReference, false or fail
      NIL
    end

    # ==

    A_REASONABLY_SHORT_LENGTH_FOR_A_STRING_ = 15
    EMPTY_S_ = ''.freeze
    Here_ = self
    LINE_RX_  = / [^\r\n]* \r? \n  |  [^\r\n]+ \r? \n? /x
  end
end
# #tombstone: sunset "silly fun map chain" - new HEREDOC `~>` obviates this somewhat
# #history: "tailer via separator" moved here from [cm]
# #history: quoted string literal library moved here from [dt] models/string
