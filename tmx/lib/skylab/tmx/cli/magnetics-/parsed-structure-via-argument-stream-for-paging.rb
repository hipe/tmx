module Skylab::TMX

  class CLI

    class Magnetics_::ParsedStructure_via_ArgumentStream_for_Paging

      DESCRIPTION___ = -> y do
        y << "for use under test-directory-oriented operations, is syntactic"
        y << "sugar that expands expressions like:"
        y << nil
        y << "    -slice first half"
        y << nil
        y << "to something like:"
        y << nil
        y << "  -page-by item-count -page-offset 0 -page-size-denominator 2"
      end

      def initialize cli
        @CLI = cli
      end

      def execute
        as = @CLI.selection_stack.last.argument_scanner
        as.advance_one
        @argument_scanner = as
        if ! as.no_unparsed_exists && HELP_RX =~ as.head_as_is
          DESCRIPTION___[ @CLI.line_yielder_for_info ]
          NOTHING_  # stop normal flow
        elsif __parse_ordinal
          if __parse_denominator
            __money
          else
            UNABLE_
          end
        else
          UNABLE_
        end
      end

      def __money
        remove_instance_variable :@CLI
        remove_instance_variable :@argument_scanner
        freeze
      end

      def __parse_ordinal
        _parse_trueish_and :__do_parse_ordinal
      end

      def __parse_denominator
        _parse_trueish_and :__do_parse_denominator
      end

      def __do_parse_ordinal s

        en_ord_rx = /\A(?:
          (first)|(second)|(third)|(fourth)|(fifth)|(sixth)  # etc
        )\z/x

        md = en_ord_rx.match s
          # (we have a more complete version of the above somewhere but meh)

        if md
          _receive_ordinal_counting_integer ( 1..10 ).detect { |d| md[ d ] }
        else

          easy_ord_rx = /\A(?<digits>[0-9]+)(?:st|nd|rd|th)\z/

          md = easy_ord_rx.match s

          if md
            _receive_ordinal_counting_integer md[ :digits ].to_i
          else
            __whine_about_ordinal s, en_ord_rx, easy_ord_rx
          end
        end
      end

      def __whine_about_ordinal s, en_ord_rx, easy_ord_rx

        say = method :_say_regexp
        _emit :error, :expression, :operator_parse_error, :unrecognized_ordinal do |y|

          y << "unrecognized ordinal #{ s.inspect } - #{
            }expecting #{ say[ en_ord_rx ] } or #{ say[ easy_ord_rx ] }"
        end
        UNABLE_
      end

      def __do_parse_denominator s

        # BE CAREFUL

        x = '(?:th|nd)'
        en_denom_rx = /\A(?:
          (half)             |   ( 3rd | third )     |  ( 4#{x} | quarter )  |
          ( 6#{x} | sixth )  |   ( 8#{x} | eighth )  |   ( 10#{x} | tenth )  |
          ( 16#{x} | sixteenth )         |       ( 32#{x} | thirty-second )
        )\z/x

        md = en_denom_rx.match s

        if md
          _d = ( 1..8 ).detect { |d| md[ d ] }
          _denom = case _d
          when 1 ; 2 ; when 2 ; 3 ; when 3 ; 4
          when 4 ; 6 ; when 5 ; 8 ; when 6 ; 10
          when 7 ; 16         ; when 8 ; 32
          end
          __receive_denominator _denom
        else
          __whine_about_denominator s, en_denom_rx
        end
      end

      def __whine_about_denominator s, en_denom_rx

        say = method :_say_regexp
        _emit :error, :expression, :operator_parse_error, :unrecognized_denominator do |y|

          y << "unrecognized denominator #{ s.inspect } - #{
            }expecting #{ say[ en_denom_rx ] }"
        end
        UNABLE_
      end

      # --

      def _receive_ordinal_counting_integer d
        @ordinal_offset = d - 1 ; true
      end

      def __receive_denominator d
        @denominator = d ; true
      end

      def _parse_trueish_and m
        s = @argument_scanner.parse_primary_value :must_be_trueish
        if s
          send m, s
        else
          s
        end
      end

      def _emit * sym_a, & msg_p
        @argument_scanner.listener[ * sym_a, & msg_p ]
        NIL
      end

      def _say_regexp rx
        buff = rx.source
        buff.gsub! %r([[:space:]]+), SPACE_  # for now
        buff = "/#{ buff }/"
        s = Basic_[]::Regexp.options_via_regexp( rx ).to_string
        s and buff << s
        buff
      end

      attr_reader(
        :denominator,
        :ordinal_offset,
      )
    end
  end
end
# #history: rename & rewrite of "use the greenlist"
