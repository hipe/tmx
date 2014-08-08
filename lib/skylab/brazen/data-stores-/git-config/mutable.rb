module Skylab::Brazen

  module Data_Stores_::Git_Config

    module Mutable

      class << self
        def parse_string str, & p
          Parse_Context__.new( p ).
            with_input( String_Input_Adapter_, str ).parse
        end
      end

      class Parse_Context__ < Parse_Context_

        attr_reader :parse_error_handler_p, :scn

        public :error_event

        def parse
          prepare_for_parse
          while @line = @lines.gets
            @line_number += 1
            if BLANK_LINE_OR_COMMENT_RX_ =~ @line
              @active_nonterminal_node.accept_blank_line_or_comment_line @line
            else
              @scn.string = @line
              send @state_i or break
            end
          end
          @document
        end

      private
        def prepare_for_parse
          @column_number = 1
          @did_error = false
          @document = Document__.new
          @active_nonterminal_node = @document
          @scn = Lib_::String_scanner[].new EMPTY_S_
          @state_i = :when_before_section
        end

        def when_before_section
          sect = Section_Or_Subsection__.new self
          if sect.parse
            @active_nonterminal_node.accept_sect sect
            PROCEDE_
          end
        end
      end

      class Document__
        def initialize
          @a = []
          @sections = Sections__.new self
        end
        attr_reader :sections

        def unparse
          @a.map( & :unparse ).join EMPTY_S_
        end

        # ~ for child agents only:

        def count_number_of_nodes i
          @a.count do |x|
            i == x.symbol_i
          end
        end

        def first_node i
          @a.detect do |x|
            i == x.symbol_i
          end
        end

        def map_nodes i, p
          get_node_enum( i ).map( & p )
        end

        def get_node_enum i
          if block_given?
            x = nil ; scn = get_node_scanner i
            yield x while (( x = scn.gets )) ; nil
          else
            to_enum :get_node_enum, i
          end
        end

        def get_node_scanner i
          d = 0 ; length = @a.length
          Callback_::Scn.new do
            while d < length
              if i == @a[ d ].symbol_i
                x = @a[ d ]
                d += 1
                break
              end
              d += 1
            end
            x
          end
        end

        def accept_blank_line_or_comment_line line_s
          @a.push Blank_Line_Or_Comment_Line__.new line_s ; nil
        end

        def accept_sect section
          @a.push section ; nil
        end
      end

      class Sections__
        def initialize parent
          @parent = parent
        end
        def length
          @parent.count_number_of_nodes :section_or_subsection
        end
        def first
          @parent.first_node :section_or_subsection
        end
        def map & p
          @parent.map_nodes :section_or_subsection, p
        end
      end

      class Section_Or_Subsection__
        def initialize parse
          @column_number = 0
          @parse = parse
          @scn = parse.scn
        end
        def symbol_i
          :section_or_subsection
        end
        def normalized_name_i
          @nn_i ||= name_s.downcase.intern
        end
        def name_s
          @n_s ||= @line[ @name_start_index, @name_width ]
        end
        def subsect_name_s
          @ss_n_s ||= bld_ss_n
        end
        def bld_ss_n
          s = @line[
            @name_start_index + @name_width + @subsection_leader_width,
            @subsection_name_width ]
          Parse_Context_.unescape_two_escape_sequences s
          s
        end
        def unparse
          @line
        end
        def parse
          d = @scn.skip OPEN_BRACE_RX__
          d ? parse_name( d ) : error_event( :expected_open_square_bracket )
        end
        OPEN_BRACE_RX__ = /[ ]*\[[ ]*/
        def parse_name d
          @column_number += d
          @name_start_index = d
          d = @scn.skip SECTION_NAME_RX__
          d ? parse_rest( d ) : error_event( :expected_section_name )
        end
        SECTION_NAME_RX__ = /[-A-Za-z0-9.]+/
        def parse_rest d
          @column_number += d
          @name_width = d
          d = @scn.skip OPEN_QUOTE_RX__
          if d
            @column_number += d
            @subsection_leader_width = d
            d = @scn.skip QUOTED_REST_RX__
            d ? parse_subsection_rest( d ) :
              error_event( :expected_subsection_name )
          else
            @subsection_leader_width = nil
            parse_close_square
          end
        end
        OPEN_QUOTE_RX__ = /[ ]+"/
        SPACE_RX__ = /[ ]*/
        QUOTED_REST_RX__ = /(?:\\"|\\\\|[^"\n])+"/

        def parse_subsection_rest d
          @column_number += d
          @subsection_name_width = d - 1
          parse_close_square
        end

        def parse_close_square
          @pre_close_square_bracket_white = @scn.skip SPACE_RX__
          d = @scn.skip CLOSE_SQUARE_BRACET_RX__
          if d
            finish_parse
          else
            error_event( :expected_close_square_bracket )
          end
        end
        CLOSE_SQUARE_BRACET_RX__ = /[ ]*\][ ]*(?:[;#]|\r?\n?\z)/

        def finish_parse
          @line = @scn.string
          @column_number = @parse = @scn = nil ; PROCEDE_
        end

        def error_event i
          @parse.error_event i
        end
      end

      class Blank_Line_Or_Comment_Line__
        def initialize line
          @line_s = line.freeze
        end

        def symbol_i
          :blank_line_or_comment_line
        end

        def unparse
          @line_s
        end
      end
    end
  end
end
