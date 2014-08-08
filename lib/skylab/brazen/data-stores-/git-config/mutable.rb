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

        def parse
          prepare_for_parse
          while @line = @lines.gets
            @line_number += 1
            if BLANK_LINE_OR_COMMENT_RX_ =~ @line
              @active_nonterminal_node.accept_blank_line_or_comment_line @line
            else
              send @state_i or break
            end
          end
          @document
        end
      private
        def prepare_for_parse
          @did_error = false
          @document = Document__.new
          @active_nonterminal_node = @document
          @state_i = :when_before_section
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

        def accept_blank_line_or_comment_line line_s
          @a.push Blank_Line_Or_Comment_Line__.new line_s ; nil
        end
      end

      class Sections__
        def initialize parent
          @parent = parent
        end
        def length
          @parent.count_number_of_nodes :section
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
