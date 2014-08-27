module Skylab::Brazen

  class Data_Stores_::Git_Config

    module Mutable  # see [#008]

      class << self
        def new
          Document__.new
        end
        def parse_string str, & p
          Parse_Context__.new( p ).
            with_input( String_Input_Adapter_, str ).parse
        end
      end

      module Autonomously_Parsing_Node_Methods__
      private

        def init_by_parsing_string line_s
          prepare_for_autonomous_parse_of_line line_s
          parse
        end

        def prepare_for_autonomous_parse_of_line line_s
          @column_number = 1
          @parse = Parse_Context__.new.for_single_line line_s
          @scn = Lib_::String_scanner[].new line_s ; nil
        end

        def error_event i
          @parse.error_event i, @column_number
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
              @current_nonterminal_node.accept_blank_line_or_comment_line @line
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
          @current_nonterminal_node = @document
          @scn = Lib_::String_scanner[].new EMPTY_S_
          @state_i = :when_before_section
        end

        def when_before_section
          sect = Section_Or_Subsection__.new.with_parse self
          if sect.parse
            accept_sect sect
          end
        end

        def when_section_or_assignment
          @sect ||= Section_Or_Subsection__.new.with_parse self
          if @sect.begin_parse
            if @sect.execute_parse
              sect = @sect ; @sect = nil
              accept_sect sect
            end
          else
            ast = Assignment__.new.with_parse self
            if ast.parse
              accept_asmt ast
            end
          end
        end
        def accept_sect sect
          @document.accept_sect sect
          @current_nonterminal_node = sect
          @section = sect
          @state_i = :when_section_or_assignment
          PROCEDE_
        end
        def accept_asmt asmt
          @section.accept_asmt asmt
        end
      end

      class Mutable_Collection_Kernel__

        def initialize
          @a = []
        end

        def initialize_copy _otr_
          a = ::Array.new @a.length
          @a.length.times.each do |d|
            a[ d ] = @a[ d ].dup
          end
          @a = a ; nil
        end

        def unparse
          unparse_into_yielder y=[]
          y.join EMPTY_S_
        end

        def unparse_into_yielder y
          @a.each do |x|
            x.unparse_into_yielder y
          end ; nil
        end

        def get_body_line_scanner
          nscn = get_all_node_scanner
          lscn = nil
          Callback_::Scn.new do
            begin
              if lscn
                x = lscn.gets
                x and break
                lscn = nil
              end
              node = nscn.gets
              node or break
              lscn = node.get_line_scanner
            end while true
            x
          end
        end

        def get_all_node_scanner
          Entity_[].scan_nonsparse_array @a
        end

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

        def aref_node_with_norm_name_i symbol_i, norm_i
          scn = get_node_scanner symbol_i
          while (( node = scn.gets ))
            if norm_i == node.normalized_name_i
              found = node ; break
            end
          end
          if found
            found.value_when_is_result_of_aref_lookup
          end
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

        # ~ the mutators

        def insert_item_y_between_x_and_z x, y, z
          if z
            insert_item_y_before_z y, z
          elsif x
            after_x_insert_item_y x, y
          else
            @a.push y
          end ; nil
        end

        def insert_item_y_before_z y, z
          idx = fnd_some_index_of_item z
          @a[ idx, 0 ] = [ y ] ; nil
        end

        def after_x_insert_item_y x, y
          idx = fnd_some_index_of_item x
          @a[ idx + 1, 0 ] = [ y ] ; nil
        end

        def fnd_some_index_of_item x
          match_p = x.object_id.method( :== )
          idx = @a.length.times.detect do |d|
            match_p[ @a.fetch( d ).object_id ]
          end
          idx or self._SANITY
        end

        # ~ more business-y, but still shared:

        def accept_blank_line_or_comment_line line_s
          @a.push Blank_Line_Or_Comment_Line__.new line_s ; nil
        end
      end

      class Document__ < Mutable_Collection_Kernel__
        def initialize
          super
          @sections = Sections__.new self
        end
        attr_reader :sections

        def initialize_copy _otr_
          super
          @sections = Sections__.new self ; nil
        end

        def get_line_scanner
          get_body_line_scanner
        end

        def add_comment str
          @a.push Blank_Line_Or_Comment_Line__.new "# #{ str }\n" ; nil
        end

        def write_to_pathname pn, listener, * x_a
          Mutable::Actors__::Write.new( pn, self, listener, x_a ).write
        end

        # ~ for child agents only:

        def accept_sect section
          @a.push section ; nil
        end
      end

      class Mutable_Collection_Shell__

        def initialize parent
          @parent = parent
        end
        def length
          @parent.count_number_of_nodes self.class::SYMBOL_I
        end
        def first
          @parent.first_node self.class::SYMBOL_I
        end
        def map & p
          @parent.map_nodes self.class::SYMBOL_I, p
        end
        def get_scanner
          @parent.get_node_scanner self.class::SYMBOL_I
        end
        def [] norm_name_i
          @parent.aref_node_with_norm_name_i(
            self.class::SYMBOL_I, norm_name_i )
        end

        # ~ the mutators

        def touch_comparable_item item, compare_p
          scn = get_scanner
          while (( x = scn.gets ))
            d = compare_p[ x ]
            case d
            when -1 ; last_above_neighbor = x
            when  0 ; exact_match = x ; break
            when  1 ; first_below_neighbor = x ; break
            end
          end
          if exact_match
            exact_match
          else
            item.finish_initialize
            @parent.insert_item_y_between_x_and_z(
              last_above_neighbor, item, first_below_neighbor )
            item
          end
        end
      end

      class Sections__ < Mutable_Collection_Shell__
        SYMBOL_I = :section_or_subsection

        def touch_section section_name_s, subsection_name_s=nil
          section = Section_Or_Subsection__.new.
            with_names section_name_s, subsection_name_s
          _compare_p = bld_compare section
          touch_comparable_item section, _compare_p
        end

        def bld_compare section
          normalized_name_s = section.normalized_name_s
          subsection_name_s = section.subsect_name_s
          if subsection_name_s
            bld_compare_name_and_ss_name normalized_name_s, subsection_name_s
          else
            bld_compare_name normalized_name_s
          end
        end

        def bld_compare_name_and_ss_name normalized_name_s, subsection_name_s
          -> x do
            d = x.normalized_name_s <=> normalized_name_s
            if d.zero?
              if x.subsect_name_s
                x.subsect_name_s <=> subsection_name_s
              else -1 end
            else d end
          end
        end

        def bld_compare_name normalized_name_s
          -> x do
            d = x.normalized_name_s <=> normalized_name_s
            if d.zero?
              x.subsect_name_s ? 1 : 0
            else d end
          end
        end
      end

      class Section_Or_Subsection__ < Mutable_Collection_Kernel__
        def initialize
          super()
        end

        def initialize_copy _otr_
          super
          @assignments = Assignments__.new self ; nil
        end

        def with_parse parse
          finish_initialize
          @column_number = 1
          @parse = parse
          @scn = parse.scn
          self
        end
        attr_reader :assignments
        def with_names name_s, subsection_name_s
          ANCHORED_SECTION_NAME_RX__.match( name_s ) or  # see #note-1
            raise ParseError, "invalid section name: #{ name_s.inspect }"
          _line = if subsection_name_s
            subsection_name_s = subsection_name_s.dup
            Section_.escape_subsection_name subsection_name_s
            "[#{ name_s } \"#{ subsection_name_s }\"]\n"
          else
            "[#{ name_s }]\n"
          end
          init_by_parsing_string _line
          self
        end
        def finish_initialize
          @assignments = Assignments__.new self ; nil
        end
        def symbol_i
          :section_or_subsection
        end
        def normalized_name_i
          @nn_i ||= normalized_name_s.intern
        end
        def normalized_name_s
          @nn_s ||= name_s.downcase
        end
        def name_s
          @n_s ||= @line[ @name_start_index, @name_width ]
        end
        def subsect_name_s
          @did_parse_ss_name ||= begin
            @ss_n_s = ( bld_ss_n if @subsection_leader_width )
            true
          end
          @ss_n_s
        end
        def bld_ss_n
          s = @line[
            @name_start_index + @name_width + @subsection_leader_width,
            @subsection_name_width ]
          Section_.unescape_subsection_name s
          s
        end
        def value_when_is_result_of_aref_lookup
          self
        end
        def unparse_into_yielder y
          y << @line
          @a.each do |x|
            x.unparse_into_yielder y
          end ; nil
        end
        def get_line_scanner
          line = @line ; scn = nil
          Callback_::Scn.new do
            if line
              r = line ; line = nil
              scn = get_body_line_scanner
              r
            else
              scn.gets
            end
          end
        end
        def begin_parse
          d = @scn.skip OPEN_BRACE_RX__
          if d
            @began_parse_index = d
            PROCEDE_
          end
        end
        def execute_parse
          d = @began_parse_index ; @began_parse_index = nil
          parse_name d
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
        ANCHORED_SECTION_NAME_RX__ = /\A#{ SECTION_NAME_RX__.source }\z/
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
        QUOTED_REST_RX__ = /(?:\\"|\\\\|[^"\n])+"/

        def parse_subsection_rest d
          @column_number += d
          @subsection_name_width = d - 1
          parse_close_square
        end

        def parse_close_square
          @pre_close_square_bracket_white = @scn.skip SPACE_RX_
          d = @scn.skip CLOSE_SQUARE_BRACET_RX__
          if d
            finish_parse
          else
            error_event( :expected_close_square_bracket )
          end
        end
        CLOSE_SQUARE_BRACET_RX__ = /[ ]*\][ ]*(?:[;#]|\r?\n?\z)/

        def finish_parse
          @line = @scn.string.freeze
          @column_number = @parse = @scn = nil ; PROCEDE_
        end

        def accept_asmt asmt
          @a.push asmt
          PROCEDE_
        end

        # ~ mutators

        def []= i, x
          touch_assignment i, x
          x
        end

        def touch_assignment i, x, listener=nil
          ast = Assignment__.new.with_normal_name_and_value i, x
          otr = @assignments.touch_comparable_item ast, bld_compare( ast )
          if ast.object_id == otr.object_id
            listener and listener.call :added
          else
            _x = otr.value_x
            if x == _x
              listener and listener.call :no_change
            else
              otr.value_x = x
              listener and listener.call :changed
            end
          end
        end

        def bld_compare ast
          norm_s = ast.normalized_name_s
          -> x do
            x.normalized_name_s <=> norm_s
          end
        end

        include Autonomously_Parsing_Node_Methods__
      end

      class Assignments__ < Mutable_Collection_Shell__
        SYMBOL_I = :assignment
      end

      class Assignment__

        def initialize
        end

        def finish_initialize
        end

        def initialize_copy _otr_
          # amazingly, nothing to do
          @line.frozen? or self._SANITY
        end

        def symbol_i
          :assignment
        end

        def with_parse parse
          @column_number = 1
          @parse = parse
          @scn = @parse.scn
          @value_is_converted = false
          self
        end

        def with_normal_name_and_value i, x
          NAME_RX__ =~ i.to_s or raise ParseError, say_invalid_name( i )
          x.nil? and self._DO_ME
          s = marshal_value x
          init_by_parsing_string "#{ i } = #{ s }\n"
          self
        end

        def value_x= x
          x.nil? and raise ::ArgumentError, "cannot be nil"
          s = marshal_value x
          line = @line.dup
          line[ @value_start_index, @value_width ] = s
          prepare_for_autonomous_parse_of_line line
          @value_is_converted = false
          # #hack pretend we just parsed the equals non-terminal
          @scn.pos = @name_start_index + @name_width + @equals_width
          @column_number = @name_start_index + @name_width + 1
          parse_value @equals_width
          x
        end

        def say_invalid_name i
          "invalid assignment name: #{ i.inspect }"
        end

        def marshal_value x
          case x
          when ::TrueClass, ::FalseClass, ::Fixnum ; x.inspect
          else marshal_string_value x
          end
        end

        def marshal_string_value s
          if LEADING_WS_RX__ =~ s || TRAILING_WS_RX__ =~ s ||
            SPECIAL_VALUE_CHARACTERS_RX__ =~ s
            s = s.dup
            Assignment_.escape_value_string s
            "\"#{ s }\""
          else
            s
          end
        end
        LEADING_WS_RX__ = /\A[ \t]+/ ; TRAILING_WS_RX__ = /[ \t]+\z/
        SPECIAL_VALUE_CHARACTERS_RX__ = /[#;"\\\n\t\b]/

        def parse
          @name_start_index = @scn.skip SPACE_RX_
          @column_number += @name_start_index
          d = @scn.skip NAME_RX__
          d ? parse_any_value( d ) : error_event( :expected_variable_name )
        end
        NAME_RX__ = /[A-Za-z][-0-9A-Za-z]*/

        def parse_any_value d
          @name_width = d
          @column_number += d
          d = @scn.skip EQUALS_RX__
          if d
            parse_value d
          else
            d = @scn.skip THE_REST_RX_
            d or error_event( :expected_equals_sign_or_end_of_line )
          end
        end
        EQUALS_RX__ = /[ ]*=[ ]*/

        def parse_value d
          @equals_width = d
          @column_number += d
          @value_start_index = @column_number - 1  # might contain open quote!
          if (( d = @scn.skip INTEGER_RHS_RX__ ))
            parse_integer d
          elsif (( d = @scn.skip BOOLEAN_TRUE_RHS_RX__ ))
            parse_boolean_true d
          elsif (( d = @scn.skip BOOLEAN_FALSE_RHS_RX__ ))
            parse_boolean_false d
          else
            parse_string
          end
        end
        _REST_ = '(?=[ ]*(?:[#;]|\r?\n?\z))'
        INTEGER_RHS_RX__ = /-?[0-9]+#{ _REST_ }/
        BOOLEAN_TRUE_RHS_RX__ = /(?i:yes|true|on)#{ _REST_ }/
        BOOLEAN_FALSE_RHS_RX__ = /(?i:no|false|off)#{ _REST_ }/

        def parse_integer d
          @value_conversion_method_i = :convert_integer
          @value_width = d
          finish_line
        end

        def parse_boolean_true d
          @value_conversion_method_i = :convert_true
          @value_width = d
          finish_line
        end

        def parse_boolean_false d
          @value_conversion_method_i = :convert_false
          @value_width = d
          finish_line
        end

        def parse_string
          @seg_s_a = [] ; ok = false
          if parse_any_non_quoted_string
            begin
              ok = parse_any_quoted_string
              ok or break
              ok = parse_any_non_quoted_string
            end while ok
            ok.nil? ? finish_parse_string : ok
          elsif parse_any_quoted_string
            begin
              ok = parse_any_non_quoted_string
              ok or break
              ok = parse_any_quoted_string
            end while ok
            ok.nil? ? finish_parse_string : ok
          else
            error_event(
              :expected_integer_or_boolean_or_quoted_or_non_quoted_string )
          end
        end

        def parse_any_non_quoted_string
          d = @scn.skip NON_QUOTED_STRING_RX__
          if d
            @seg_s_a.push @scn.string[ @column_number - 1, d ]
            @column_number += d
            PROCEDE_
          end
        end
        NON_QUOTED_STRING_RX__ = /[^ \t\r\n#;"]+(?:[ \t]+[^ \t\r\n#;"]+)*/

        def parse_any_quoted_string
          if @scn.skip QUOTE_RX__
            @column_number += 1  # skip over the open quote
            d = @scn.skip QUOTED_REST_RX__
            if d
              @scn.pos += 1  # because the rx doesn't include the close quote
              contents_s = @scn.string[ @column_number - 1, d ]
              @column_number += ( d + 1 )  # skip over the close quote
              Assignment_.unescape_quoted_value_string contents_s
              @seg_s_a.push contents_s
              PROCEDE_
            else
              error_event :end_quote_not_found_anywhere_before_end_of_line
            end
          end
        end
        QUOTE_RX__ = /"/
        QUOTED_REST_RX__ = /(?:\\"|\\\\|[^"])*(?=")/

        def finish_parse_string
          @value_width = @column_number - 1 - @value_start_index
          finish_line do |d|
            @value_is_converted = true
            @value_x = @seg_s_a.join EMPTY_S_ ; @seg_s_a = nil
            PROCEDE_
          end
        end

        def finish_line
          d = @scn.skip THE_REST_RX_
          if d
            @line = @scn.string.freeze
            @parse = @scn = @column_number = nil
            if block_given?
              yield d
            else
              PROCEDE_
            end
          else
            error_event :expected_end_of_line
          end
        end

        def normalized_name_i
          @nn_i ||= normalized_name_s.intern
        end

        def normalized_name_s
          @nn_s ||= name_s.downcase
        end

        def name_s
          @n_s ||= @line[ @name_start_index, @name_width ]
        end

        def value_when_is_result_of_aref_lookup
          value_x
        end

        def value_x
          @value_is_converted or cnvrt_value
          @value_x
        end

        def cnvrt_value
          @value_is_converted = true
          send @value_conversion_method_i
        end

        def convert_integer
          @value_x = @line[ @value_start_index, @value_width ].to_i ; nil
        end

        def convert_true
          @value_x = true
        end

        def convert_false
          @value_x = false
        end

        def unparse_into_yielder y
          y << @line ; nil
        end

        def get_line_scanner
          Single_line_scanner__[ @line ]
        end

        include Autonomously_Parsing_Node_Methods__

        THE_REST_RX_ = /[ ]*(?:[#;]|\r?\n?\z)/
      end

      class Blank_Line_Or_Comment_Line__
        def initialize line
          @line = line.freeze
        end

        def initialize_copy _otr_
          self._DO_ME  # todo
        end

        def symbol_i
          :blank_line_or_comment_line
        end

        def unparse_into_yielder y
          y << @line ; nil
        end

        def get_line_scanner
          Single_line_scanner__[ @line ]
        end
      end

      Single_line_scanner__ = -> line do
        Callback_::Scn.new do
          if line
            r = line ; line = nil ; r
          end
        end
      end

      SPACE_RX_ = /[ ]*/
    end
  end
end
