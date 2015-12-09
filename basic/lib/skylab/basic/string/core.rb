module Skylab::Basic

  module String

    class << self

      def [] last_op_sym, * op_sym_a, s  # silly fun
        op_sym_a.each do | op_sym |
          send op_sym, s
        end
        send last_op_sym, s
      end

      def build_proc_for_string_begins_with_string * a
        if a.length.zero?
          String_::Small_Procs__::Build_proc_for_string_begins_with_string
        else
          String_::Small_Procs__::Build_proc_for_string_begins_with_string[ * a ]
        end
      end

      def build_proc_for_string_ends_with_string * a
        if a.length.zero?
          String_::Small_Procs__::Build_proc_for_string_ends_with_string
        else
          String_::Small_Procs__::Build_proc_for_string_ends_with_string[ * a ]
        end
      end

      def build_sequence_proc * x_a
        String_::Succ__.call_via_iambic x_a
      end

      def component_model_for sym
        Require_components_models___[]
        Component_Models.const_get sym, false
      end

      def count_occurrences_in_string_of_string haystack, needle
        String_::Small_Time_Actors__::Count_occurrences_OF_string_IN_string[
          needle, haystack ]
      end

      def count_occurrences_in_string_of_regex haystack, needle_rx
        String_::Small_Time_Actors__::Count_occurrences_OF_regex_IN_string[
          needle_rx, haystack ]
      end

      def ellipsify * a  # [#032].
        String_::Small_Time_Actors__::Ellipsify.call_via_arglist a
      end

      def line_stream * a
        if a.length.zero?
          String_::Line_Scanner__
        else
          String_::Line_Scanner__.via_arglist a
        end
      end

      def looks_like_sentence * a
        if a.length.zero?
          String_::Small_Procs__::Looks_like_sentence
        else
          String_::Small_Procs__::Looks_like_sentence[ * a ]
        end
      end

      def members
        singleton_class.public_instance_methods( false ) - [ :members ]
      end

      def mustache_regexp
        MUSTACHE_RX__
      end
      MUSTACHE_RX__ = / {{ ( (?: (?!}}) [^{] )+ ) }} /x

      define_method :mutate_by_unindenting, -> do

        # use the leading whitespace in the first line as the
        # amount by which to "deindent" the whole string

        rx = nil
        -> s do

          rx ||= /\A[ \t]+/

          _rx = /^#{ ::Regexp.escape rx.match( s )[ 0 ] }/

          s.gsub! _rx, EMPTY_S_

          NIL_  # don't result a mutant
        end
      end.call

      def paragraph_string_via_message_lines * a
        if a.length.zero?
          String_::Small_Procs__::Paragraph_string_via_message_lines
        else
          String_::Small_Procs__::Paragraph_string_via_message_lines[ * a ]
        end
      end

      def a_reasonably_short_length_for_a_string
        A_REASONABLY_SHORT_LENGTH_FOR_A_STRING_
      end

      def regex_for_line_scanning
        LINE_RX__
      end
      LINE_RX__  = / [^\r\n]* \r? \n  |  [^\r\n]+ \r? \n? /x

      def reverse_scanner string, d
        String_::Small_Procs__::Build_reverse_scanner[ string, d ]
      end

      def shortest_unique_or_first_headstrings a
        h = nil
        Home_::Hash.determine_hotstrings( a ).each_with_index.map do | hs, d |
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

      def succ
        String_::Succ__
      end

      def template
        String_::Template__
      end

      def unparenthesize_message_string * a
        if a.length.zero?
          String_::Small_Time_Actors__::Unparenthesize_message_string
        else
          String_::Small_Time_Actors__::Unparenthesize_message_string[ * a ]
        end
      end

      def via_mixed * a
        String_::Via_Mixed__.call_via_arglist a
      end

      def word_wrappers
        Word_Wrappers__
      end

      def yamlizer
        String_::Yamlizer__
      end
    end  # >>

    module Word_Wrappers__  # notes in [#033]

      class << self

        def calm
          self::Calm
        end

        def crazy
          self::Crazy
        end
      end

      Autoloader_[ self ]
    end

    class N_Lines

      class << self
        alias_method :session, :new
        private :new
      end  # >>

      def initialize
        NIL_  # (hi.)
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

    Require_components_models___ = Callback_.memoize do

      module Component_Models

        module NONBLANK_TOKEN

          nb_t_rx = /\A[-A-Za-z0-9_]+\z/  # or w/e

          same = -> arg_st, & oes_p_p do

            x = arg_st.current_token

            if nb_t_rx =~ x

              Callback_::Known_Known[ arg_st.gets_one.to_sym ]

            else

              _oes_p = oes_p_p[ nil ]  # no entity

              _oes_p.call :error, :expression, :is_not, :nonblank_token do | y |
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

          o.on_failure_to_match = -> _reserved, & oes_p do

            oes_p.call :error, :expression, :is_not, :nonblank do | y |
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

    A_REASONABLY_SHORT_LENGTH_FOR_A_STRING_ = 15
    EMPTY_S_ = ''.freeze
    NEWLINE_ = "\n".freeze
    String_ = self
  end
end
