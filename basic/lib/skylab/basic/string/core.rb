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

      def succ
        String_::Succ__
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
          rx ||= /\A[[:space:]]+/
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
        A_REASONABLY_SHORT_LENGTH_FOR_A_STRING__
      end
      A_REASONABLY_SHORT_LENGTH_FOR_A_STRING__ = 15

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

    EMPTY_S_ = ''.freeze
    NEWLINE_ = "\n".freeze
    String_ = self
  end
end