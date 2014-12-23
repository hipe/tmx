module Skylab::Brazen

  class Data_Stores_::Git_Config

    module Mutable  # see [#008]

      class << self

        def new & oes_p
          _parse = Parse__.with :on_event_selectively, oes_p
          Document__.new _parse
        end

        def parse_string str, & oes_p
          Parse__[ :via_string, str, :on_event_selectively, oes_p ]
        end

        def parse_path path_s, & oes_p
          Parse__[ :via_path, path_s, :on_event_selectively, oes_p ]
        end

        def parse_input_id input_id, & oes_p
          Parse__[ :via_input_adapter, input_id,
                   :on_event_selectively, oes_p ]
        end
      end

      class Parse__ < Parse_

        class << self
          def with * x_a
            new x_a
          end
        end

        def initialize a
          a.last.nil? and self._WHERE
          absorb_even_iambic_fully a
        end

      private

        def absorb_even_iambic_fully a
          dsl = DSL__.new self
          a.each_slice 2 do |i, x|
            dsl.send i, x
          end ; nil
        end

        class DSL__
          def initialize x
            @receiver = x
          end
          def via_path x
            @receiver.accept_input_ID Input_Identifier_.via_path x
          end
          def via_string x
            @receiver.accept_input_ID Input_Identifier_.via_string x
          end
          def via_input_adapter x
            @receiver.accept_input_ID x
          end
          def via_string_for_immediate_parse s
            @receiver.accept_string_for_immediate_scan s
          end
          def on_event_selectively oes_p
            @receiver.accept_handle_event_selectively_proc oes_p
          end
        end

        def prepare_for_parse
          @scn = nil
          super
        end

        def resolve_document
          @document = Document__.new @input_id, self
          @current_nonterminal_node = @document
          PROCEDE_
        end

        def execute_parse
          ok = PROCEDE_
          while @line = @lines.gets
            @line_number += 1
            if BLANK_LINE_OR_COMMENT_RX_ =~ @line
              @current_nonterminal_node.accept_blank_line_or_comment_line @line
            else
              if @scn
                @scn.string = @line
              else
                @scn = Lib_::String_scanner[].new @line
              end
              ok = send @state_i
              ok or break
            end
          end
          if ok
            @result = @document
          end ; nil
        end

        def when_before_section  # the starting state (only), set by parent
          sect = Section_or_Subsection__.via_parse self
          sect and begin
            accept_sect sect
            PROCEDE_
          end
        end

        def when_section_or_assignment
          sect = Section_or_Subsection__.peek_via_parse self
          if sect
            sect.parse_after_peek and begin
              accept_sect sect
              PROCEDE_
            end
          else
            ast = Assignment__.via_parse self
            ast and begin
              accept_asmt ast
              PROCEDE_
            end
          end
        end

      public

        def accept_input_ID x
          @input_id = x ; nil
        end

        def accept_string_for_immediate_scan s
          @scn = Lib_::String_scanner[].new s ; nil
        end

        def accept_handle_event_selectively_proc p
          @on_event_selectively = p ; nil
        end

        def string_scanner
          @scn
        end

        def string_stream_for_freezable_current_line
          @scn
        end

        def accept_sect sect
          @document.accept_sect sect
          @current_nonterminal_node = sect
          @state_i = :when_section_or_assignment
          nil
        end

        def accept_asmt asmt
          @current_nonterminal_node.accept_asmt asmt
          nil
        end
      end

      class Pass_Thru_Parse__ < Parse__
        undef_method :execute
        class << self
          def with * x_a
            new x_a
          end
        end

        def on_event_selectively
          @on_event_selectively
        end
      end

      module Readable_Branch_Methods__  # for documents and [sub] sections, not assignment or comments

        def is_empty
          @a.length.zero?
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

        def get_body_line_stream
          nscn = get_all_node_stream
          lscn = nil
          Callback_::Scn.new do
            while true
              if lscn
                x = lscn.gets
                x and break
                lscn = nil
              end
              node = nscn.gets
              node or break
              lscn = node.to_line_stream
            end
            x
          end
        end

        def get_all_node_stream
          LIB_.stream.via_nonsparse_array @a
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
          scn = _to_node_scn_via_symbol symbol_i
          while node = scn.gets
            if norm_i == node.external_normal_name_symbol
              found = node ; break
            end
          end
          if found
            found.value_when_is_result_of_aref_lookup
          end
        end

        def get_node_enum i
          if block_given?
            x = nil ; scn = _to_node_scn_via_symbol i
            yield x while x = scn.gets ; nil
          else
            to_enum :get_node_enum, i
          end
        end

        def _to_node_stream_via_symbol sym
          _to_node_streamish Callback_::Scan, sym

        end

        def _to_node_scn_via_symbol sym
          _to_node_streamish Callback_::Scn, sym
        end

        def _to_node_streamish cls, i
          d = -1 ; last = @a.length - 1
          cls.new do
            while d < last
              d += 1
              if i == @a[ d ].symbol_i
                x = @a[ d ]
                break
              end
            end
            x
          end
        end

        def get_all_node_scan
          LIB_.stream.via_nonsparse_array @a
        end
      end

      module Mutable_Branch_Methods__

        def insert_item_y_between_x_and_z x, y, z
          if z
            insert_item_y_before_z y, z
          elsif x
            after_x_insert_item_y x, y
          else
            @a.push y
            y
          end
        end

        def insert_item_y_before_z y, z
          idx = fnd_some_index_of_item z
          @a[ idx, 0 ] = [ y ]
          y
        end

        def after_x_insert_item_y x, y
          idx = fnd_some_index_of_item x
          @a[ idx + 1, 0 ] = [ y ]
          y
        end

        def fnd_some_index_of_item x
          match_p = x.object_id.method( :== )
          idx = @a.length.times.detect do |d|
            match_p[ @a.fetch( d ).object_id ]
          end
          idx or self._SANITY
        end

        def replace_children_with_this_array a
          d = @a.length
          @a = a
          a.length - d
        end
      end

      class Document__

        include Mutable_Branch_Methods__, Readable_Branch_Methods__

        def initialize input_id=nil, parse
          @a = []
          input_id and @input_id = input_id
          @parse = parse
          @sections_shell = Sections_Facade__.new self, parse
        end

        def input_id
          @input_id
        end

        def dup_via_parse_context parse  # #when-and-how-we-duplicate
          otr = dup
          otr.init_copy_via_parse_and_other parse, self
          otr
        end

        def initialize_copy _otr_
          @a = @input_id = @parse = @sections_shell = nil
        end

      protected

        def init_copy_via_parse_and_other parse, otr
          @a = otr.a.map do |x|
            x.dup_via_parse_context parse
          end
          @parse = parse
          @sections_shell = Sections_Facade__.new self, parse
          nil
        end

        attr_reader :a

      public

        def is_mutable
          true
        end

        def sections
          @sections_shell
        end

        def to_line_stream
          get_body_line_stream
        end

        def add_comment str
          @a.push Blank_Line_Or_Comment_Line__.new "# #{ str }#{ NEWLINE_ }"
          PROCEDE_
        end

        def write_to_pathname pn, * x_a
          x_a.push :pathname, pn
          write_via_mutable_iambic x_a
        end

        def write_via_mutable_iambic x_a

          x_a.first.respond_to?( :id2name ) or raise ::ArgumentError, "where"

          x_a.push :document, self,
            :on_event_selectively, @parse.handle_event_selectively

          Mutable::Actors::Persist.via_iambic x_a do |o|
            o.did_see :pathname or o.set_pathname @input_id.to_pathname
          end
        end

        # ~ for child agents only:

        def accept_sect section
          @a.push section ; nil
        end

        def accept_blank_line_or_comment_line line_s
          @a.push Blank_Line_Or_Comment_Line__.new line_s ; nil
        end
      end

      class Mutable_Collection_Shell__  # #understanding-the-mutable-collection-shell

        def initialize kernel, parse
          @collection_kernel = kernel
          @parse = parse
        end

        def initialize_copy _otr_
        end

        def length
          @collection_kernel.count_number_of_nodes self.class::SYMBOL_I
        end

        def first
          @collection_kernel.first_node self.class::SYMBOL_I
        end

        def map & p
          @collection_kernel.map_nodes self.class::SYMBOL_I, p
        end

        def to_stream
          @collection_kernel._to_node_stream_via_symbol self.class::SYMBOL_I
        end

        def [] norm_name_i
          @collection_kernel.aref_node_with_norm_name_i(
            self.class::SYMBOL_I, norm_name_i )
        end

        # ~ the mutators

        def touch_comparable_item item, compare_p
          scn = to_stream
          while x = scn.gets
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
            @collection_kernel.insert_item_y_between_x_and_z(
              last_above_neighbor, item, first_below_neighbor )
          end
        end

        def delete_comparable_item x, compare_p, & oes_p
          do_not_delete_these = [] ; will_delete_count = 0
          scn = @collection_kernel.get_all_node_scan
          while item = scn.gets
            d = compare_p[ item ]
            if d.zero?
              will_delete_count += 1
            else
              do_not_delete_these.push item
            end
          end
          case 1 <=> will_delete_count
          when  0 ; delete_comparable_item_when_found do_not_delete_these
          when  1 ; delete_comparable_item_when_not_found x, & oes_p
          when -1 ; delete_comparable_item_when_many_matches will_delete_count, x, & oes_p
          end
        end

        def delete_comparable_item_when_found keep_these
          @collection_kernel.replace_children_with_this_array keep_these
        end
      end

      class Sections_Facade__ < Mutable_Collection_Shell__

        SYMBOL_I = :section_or_subsection

        def touch_section subsect_s=nil, sect_s
          section = bld_section subsect_s, sect_s
          section and begin
            _compare_p = bld_compare section
            touch_comparable_item section, _compare_p
          end
        end

        def bld_section subsect_s, sect_s
          Section_or_Subsection__.via_literals subsect_s, sect_s, @parse
        end

        def bld_compare section
          normalized_name_s = section.internal_normal_name_string
          subsection_name_s = section.subsect_name_s
          if subsection_name_s
            bld_compare_name_and_ss_name normalized_name_s, subsection_name_s
          else
            bld_compare_name normalized_name_s
          end
        end

        def bld_compare_name_and_ss_name normalized_name_s, subsection_name_s
          -> x do
            d = x.internal_normal_name_string <=> normalized_name_s
            if d.zero?
              if x.subsect_name_s
                x.subsect_name_s <=> subsection_name_s
              else -1 end
            else d end
          end
        end

        def bld_compare_name normalized_name_s
          -> x do
            d = x.internal_normal_name_string <=> normalized_name_s
            if d.zero?
              x.subsect_name_s ? 1 : 0
            else d end
          end
        end
      end

      class Section_or_Subsection__

        class << self

          def via_parse parse
            branch = Section_or_Subsection_Parse__.new parse
            branch.parse and begin
              new branch
            end
          end

          def peek_via_parse parse
            d = parse.string_scanner.skip OPEN_BRACE_RX_
            if d
              branch = Section_or_Subsection_Parse__.new parse
              branch.receive_peek_width d
              new branch
            end
          end

          def via_literals subsect_s, sect_s, parse=nil
            kernel = Section_or_Subsection_Literal__.new subsect_s, sect_s, parse
            kernel.resolve and begin
              new kernel
            end
          end
        end  # >>

        def initialize kernel
          @kernel = kernel
        end

        def dup_via_parse_context parse
          otr = dup
          otr.init_copy_via_parse_and_other parse, self
          otr
        end

        def initialize_copy _otr_
          @kernel = nil
        end
      protected
        def init_copy_via_parse_and_other parse, otr
          @kernel = otr.kernel.dup_via_parse_context parse ; nil
        end

        attr_reader :kernel

      public

        def is_empty
          @kernel.is_empty
        end

        def symbol_i
          :section_or_subsection
        end

        def unparse_into_yielder y
          @kernel.unparse_into_yielder y
        end

        def to_line_stream
          @kernel.to_line_stream
        end

        def external_normal_name_symbol
          @kernel.external_normal_name_symbol
        end

        def internal_normal_name_string
          @kernel.internal_normal_name_string
        end

        def subsect_name_s
          @kernel.subsect_name_s
        end

        def value_when_is_result_of_aref_lookup
          self
        end

        def assignments
          @kernel.assignments
        end

        def accept_blank_line_or_comment_line s
          @kernel.accept_blank_line_or_comment_line s
        end

        # ~ mutators

        def []= i, x
          if k = @kernel.for_edit
            @kernel = k
          end
          @kernel.aref_set i, x ; x
        end

        # ~ where available

        def parse_after_peek
          @kernel.parse_after_peek
        end

        def accept_asmt x
          @kernel.accept_asmt x
        end

        def clear_section
          @kernel.clear_section
        end
      end
      OPEN_BRACE_RX_ = /[ ]*\[[ ]*/

      Event_Sending_Node__ = ::Class.new

      Section_or_Subsection_Kernel__ = ::Class.new Event_Sending_Node__

      class Section_or_Subsection_Parse__ < Section_or_Subsection_Kernel__

        include Mutable_Branch_Methods__, Readable_Branch_Methods__

        def initialize parse
          @a = []
          @assignments_shell = Assignments_Facade__.new self, parse
          @parse = parse
          @scn = parse.string_stream_for_freezable_current_line
        end

        def dup_via_parse_context parse
          otr = dup
          otr.init_copy_via_parse_and_other parse, self
          otr
        end

        def initialize_copy _otr_
          @a = @assignments_shell = @parse = @scn = nil
        end

      protected

        def init_copy_via_parse_and_other parse, otr
          @a = otr.a.map do |x|
            x.dup_via_parse_context parse
          end
          @assignments_shell = Assignments_Facade__.new self, parse
          @parse = parse ; nil
        end

        attr_reader :a

      public

        def is_empty
          @a.length.zero?
        end

        def assignments
          @assignments_shell
        end

        def parse
          @column_number = 1
          d = @scn.skip OPEN_BRACE_RX_
          if d
            parse_name d
          else
            recv_error_symbol :expected_open_square_bracket
          end
        end

        def receive_peek_width d
          @column_number = d + 1
        end

        def parse_after_peek
          parse_name @column_number - 1
        end

      private

        def parse_name d
          @column_number += d
          @name_start_index = d
          d = @scn.skip SECTION_NAME_RX_
          if d
            parse_rest d
          else
            recv_error_symbol :expected_section_name
          end
        end

        def parse_rest d
          @column_number += d
          @name_width = d
          d = @scn.skip OPEN_QUOTE_RX__
          if d
            @column_number += d
            @subsection_leader_width = d
            d = @scn.skip QUOTED_REST_RX__
            if d
              parse_subsection_rest d
            else
              recv_error_symbol :expected_subsection_name
            end
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
          d = @scn.skip CLOSE_SQUARE_BRACKET_RX__
          if d
            finish_parse
          else
            recv_error_symbol :expected_close_square_bracket
          end
        end
        CLOSE_SQUARE_BRACKET_RX__ = /[ ]*\][ ]*(?:[;#]|\r?\n?\z)/

        def finish_parse
          @line = @scn.string.freeze
          @column_number = @scn = nil
          # keep @parse around for any subsequent events we may emit!
          rslv_names
          PROCEDE_
        end

        def rslv_names
          @sect_s = @line[ @name_start_index, @name_width ]
          @normalized_sect_s = @sect_s.downcase
          @normalized_sect_i = @normalized_sect_s.intern
          @subsect_s = @subsection_leader_width && prdc_ss_s
          nil
        end

        def prdc_ss_s
          s = @line[
            @name_start_index + @name_width + @subsection_leader_width,
            @subsection_name_width ]
          Section_.mutate_subsection_name_for_unmarshal s
          s
        end

      public

        def accept_asmt asmt
          @a.push asmt ; nil
        end

        def accept_blank_line_or_comment_line line_s
          @a.push Blank_Line_Or_Comment_Line__.new line_s ; nil
        end

        def unparse_into_yielder y
          y << @line
          @a.each do |x|
            x.unparse_into_yielder y
          end ; nil
        end

        def to_line_stream
          p = -> do
            x = @line
            p = -> do
              scn = get_body_line_stream
              p = -> do
                scn.gets
              end
              scn.gets
            end
            x
          end
          Callback_::Scn.new do
            p[]
          end
        end

        # ~ mutators

        def for_edit
        end

        def clear_section
          d = @a.length ; @a.clear ; d
        end

        def aref_set i, x
          ast = Assignment__.via_literal i, x, @parse
          ast and aref_set_via_assignment ast
        end

      private

        def aref_set_via_assignment ast
          _compare_p = bld_compare ast
          otr = @assignments_shell.touch_comparable_item ast, _compare_p
          if ast.object_id == otr.object_id
            maybe_send_added_value_event ast
          else
            apply_change_and_maybe_send_event otr, ast
          end
        end

        def maybe_send_added_value_event ast
          maybe_send_event :info, :related_to_assignment_change do
            build_OK_event_with :added_value, :new_assignment, ast
          end
        end

        def bld_compare ast
          norm_s = ast.internal_normal_name_string
          -> x do
            x.internal_normal_name_string <=> norm_s
          end
        end

        def apply_change_and_maybe_send_event otr, ast
          _x = ast.value_x
          _x_ = otr.value_x
          if _x_ == _x
            maybe_send_assignment_no_change_event otr
          else
            prev_x = otr.value_x
            otr.value_x = ast.value_x
            maybe_send_assignment_change_event otr, prev_x
          end
        end

        def maybe_send_assignment_no_change_event otr
          maybe_send_event :info, :related_to_assignment_change do
            build_OK_event_with :no_change_in_value, :existing_assignment, otr
          end
        end

        def maybe_send_assignment_change_event otr, prev_x
          maybe_send_event :info, :related_to_assignment_change do
            build_OK_event_with :value_changed, :existing_assignment, otr,
              :previous_value, prev_x
          end
        end
      end

      class Section_or_Subsection_Literal__ < Section_or_Subsection_Kernel__

        def initialize subsect_s, sect_s, parse
          @parse = parse
          @unsanitized_sect_s = sect_s
          @unsanitized_subsect_s = subsect_s
        end

        def is_empty
          true
        end

        def for_edit

          unparse_into_yielder y=[]

          _parse = Parse__.with :via_string_for_immediate_parse,
            y * EMPTY_S_,
            :on_event_selectively,
            @parse.handle_event_selectively

          otr = Section_or_Subsection_Parse__.new _parse
          otr.parse or self._SYNTAX_MISMATCH
          otr
        end

        def unparse_into_yielder y  # :+#arbitrary-styling
          scn = to_line_stream
          while line = scn.gets
            y << line
          end ; nil
        end

        def to_line_stream
          p = -> do
            line = rndr_line
            p = EMPTY_P_
            line
          end
          Callback_::Scn.new do
            p[]
          end
        end
      private
        def rndr_line
          if @subsect_s
            s = @subsect_s.dup
            Section_.mutate_subsection_name_for_marshal s
            "[#{ @sect_s } \"#{ s }\"]#{ NEWLINE_ }"
          else
            "[#{ @sect_s }]#{ NEWLINE_ }"
          end
        end
      public

        def resolve
          if ANCHORED_SECTION_NAME_RX_ =~ @unsanitized_sect_s
            @sect_s = @unsanitized_sect_s ; @unsanitized_sect_s = nil
            rslv_subsect_s
          else
            maybe_send_invalid_section_name_error
            UNABLE_
          end
        end

      private

        def maybe_send_invalid_section_name_error
          maybe_send_event :error, :invalid_section_name do
            bld_invalid_section_name_event
          end
        end

        def bld_invalid_section_name_event
          build_not_OK_event_with :invalid_section_name, :invalid_section_name,
            @unsanitized_sect_s
        end

        def rslv_subsect_s
          ok = if @unsanitized_subsect_s
            if @unsanitized_subsect_s.include? NEWLINE_
              maybe_send_invalid_subsection_name_error
              UNABLE_
            else
              @subsect_s = @unsanitized_subsect_s ; @unsanitized_subsect_s = nil
              PROCEDE_
            end
          else
            @subsect_s = @unsanitized_subsect_s ; @unsanitized_subsect_s = nil
            PROCEDE_
          end
          ok and begin
            rslv_names
            ok
          end
        end

        def maybe_send_invalid_subsection_name_error
          maybe_send_event :error, :invalid_subsection_name do
            bld_invalid_subsection_name_event
          end
        end

        def bld_invalid_subsection_name_event
          build_not_OK_event_with :invalid_subsection_name, :invalid_subsection_name,
            @unsanitized_subsect_s do |y, o|
              s = o.invalid_subsection_name
              d = s.index NEWLINE_
              d_ = d - 4
              _excerpt = case 0 <=> d_
              when -1 ; "[..]#{ s[ d_ .. d ] }"
              when  0 ; s[ d_ .. d ]
              when  1 ; s[ 0 .. d ]
              end
              y << "subsection names #{
                }can contain any characters except newline (#{ ick _excerpt })"
          end
        end

        def rslv_names
          @normalized_sect_s = @sect_s.downcase
          @external_normal_name_symbol = @normalized_sect_s.intern ; nil
        end
      end

      SECTION_NAME_RX_ = /[-A-Za-z0-9.]+/
      ANCHORED_SECTION_NAME_RX_ = /\A#{ SECTION_NAME_RX_.source }\z/

      class Section_or_Subsection_Kernel__

        def external_normal_name_symbol
          @normalized_sect_i
        end

        def internal_normal_name_string
          @normalized_sect_s
        end

        def subsect_name_s
          @subsect_s
        end

      private

        def recv_error_symbol sym
          @parse.receive_error_symbol_and_column_number_ sym, @column_number
          UNABLE_
        end
      end

      class Assignments_Facade__ < Mutable_Collection_Shell__
        SYMBOL_I = :assignment
      end

      class Assignment__

        class << self
          def via_parse parse
            ast = Assignment_Parse__.new parse
            ast.parse and begin
              new ast
            end
          end

          def via_literal i, x, parse
            ast = Assignment_Literal__.new i, x, parse
            ast.resolve and begin
              new ast
            end
          end
        end

        def initialize kernel
          @kernel = kernel
        end

        def dup_via_parse_context parse
          otr = dup
          otr.init_copy_via_parse_and_other parse, self
          otr
        end

        def initialize_copy _otr_
          @kernel = nil
        end
      protected
        def init_copy_via_parse_and_other parse, otr
          @kernel = otr.kernel.dup_via_parse_context parse ; nil
        end

        attr_reader :kernel
      public

        def symbol_i
          :assignment
        end

        def description
          "(name: #{ internal_normal_name_string } value: #{ value_x.inspect })"
        end

        def external_normal_name_symbol
          @kernel.external_normal_name_symbol
        end

        def unparse_into_yielder y
          @kernel.unparse_into_yielder y
        end

        def to_line_stream
          @kernel.to_line_stream
        end

        def internal_normal_name_string
          @kernel.internal_normal_name_string
        end

        def value_when_is_result_of_aref_lookup
          @kernel.value_x
        end

        def value_x
          @kernel.value_x
        end

        # ~ mutator

        def value_x= x
          @kernel.set_value x
        end
      end

      AST_NAME_RX_ = /[A-Za-z][-0-9A-Za-z]*/

      Assignment_Kernel__ = ::Class.new Event_Sending_Node__

      class Assignment_Parse__ < Assignment_Kernel__

        def initialize parse
          @parse = parse
          @value_is_converted = false
        end

        def dup_via_parse_context parse
          otr = dup
          otr.init_copy_via_parse_and_other parse, self
          otr
        end

        def initialize_copy _otr_
          @parse = @scn = nil
        end
      protected
        def init_copy_via_parse_and_other parse, _otr_
          # at this writing there are 13 ivars we keep as-is as copy-by-reference
          @parse = parse ; nil
        end
      public

        def parse
          @scn = @parse.string_stream_for_freezable_current_line
          @name_start_index = @scn.skip SPACE_RX_
          @column_number = 1 + @name_start_index
          d = @scn.skip AST_NAME_RX_
          if d
            parse_any_value d
          else
            recv_error_symbol :expected_variable_name
          end
        end

      private

        def parse_any_value d
          @name_width = d
          @column_number += d
          d = @scn.skip EQUALS_RX__
          if d
            parse_value d
          else
            d = @scn.skip THE_REST_RX_
            d or recv_error_symbol :expected_equals_sign_or_end_of_line
          end
        end
        EQUALS_RX__ = /[ ]*=/

        def parse_value d
          @equals_width = d
          @column_number += d
          @post_equals_space_width = @scn.skip ANY_WHITESPACE_RX__
          @column_number += @post_equals_space_width
          @value_start_index = @column_number - 1  # might contain open quote!
          d = @scn.skip INTEGER_RHS_RX__
          if d
            parse_integer d
          elsif (( d = @scn.skip BOOLEAN_TRUE_RHS_RX__ ))
            parse_boolean_true d
          elsif (( d = @scn.skip BOOLEAN_FALSE_RHS_RX__ ))
            parse_boolean_false d
          else
            parse_string
          end
        end
        ANY_WHITESPACE_RX__ = /[ ]*/
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
            if ok.nil?
              finish_parse_string
            else
              ok
            end
          elsif parse_any_quoted_string
            begin
              ok = parse_any_non_quoted_string
              ok or break
              ok = parse_any_quoted_string
            end while ok
            if ok.nil?
              finish_parse_string
            else
              ok
            end
          else
            recv_error_symbol(
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
              s = @scn.string[ @column_number - 1, d ]
              @column_number += ( d + 1 )  # skip over the close quote
              if Assignment_.mutate_value_string_for_unmarshal(
                  s, @parse.handle_event_selectively )
                @seg_s_a.push s
                PROCEDE_
              else
                UNABLE_
              end
            else
              recv_error_symbol :end_quote_not_found_anywhere_before_end_of_line
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
            rslv_names
            if block_given?
              yield d
            else
              PROCEDE_
            end
          else
            recv_error_symbol :expected_end_of_line
          end
        end
        THE_REST_RX_ = /[ ]*(?:[#;]|\r?\n?\z)/

        def rslv_names
          _received_name_s = @line[ @name_start_index, @name_width ]
          @internal_normal_name_string = _received_name_s.downcase
          @external_normal_name_symbol = @internal_normal_name_string.intern ; nil
        end

      public

        def to_line_stream
          Single_line_scanner__[ @line ]
        end

        def unparse_into_yielder y
          y << @line ; nil
        end

        def external_normal_name_symbol
          @external_normal_name_symbol
        end

        def internal_normal_name_string
          @internal_normal_name_string
        end

        def value_x
          @value_is_converted or cnvrt_value
          @value_x
        end

      private

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

        def accept_new_value x
          d = @name_start_index + @name_width + @equals_width
          s = marshal_RHS_via_x x
          @line = @line.dup
          # we never create a line with trailing space. but if there is some
          # arbitrary number of spaces between the '=' and the value, we
          # preserve that spacing.
          if s.length.zero?
            @line[ d .. -1 ] = NEWLINE_
          else
            @line[ @value_start_index .. -1 ] = "#{ s[ 1 .. -1 ] }#{ NEWLINE_ }" # # assume #one-space
          end
          @line.freeze ; nil
        end

        def recv_error_symbol sym
          @parse.receive_error_symbol_and_column_number_ sym, @column_number
          UNABLE_
        end
      end

      class Assignment_Literal__ < Assignment_Kernel__

        def initialize variegated_i, x, parse
          parse or raise ::ArgumentError
          @parse = parse
          @unsanitized_x = x
          @variegated_i = variegated_i
        end

        def external_normal_name_symbol
          @enns ||= @variegated_i.id2name.
            gsub( DASH_, UNDERSCORE_ ).downcase.intern
        end

        def internal_normal_name_string
          @inns or raise 'not set'
        end

        def resolve
          s = @variegated_i.id2name
          if AST_NAME_RX__ =~ s
            @inns = s
            rslv_value
          else
            maybe_send_variable_name_error
            UNABLE_
          end
        end
        AST_NAME_RX__ = /\A#{ AST_NAME_RX_.source }\z/

      private

        def rslv_value
          x = @unsanitized_x
          @unsanitized_x = nil
          set_value x
        end

        def maybe_send_variable_name_error
          maybe_send_event :error, :invalid_variable_name do
            build_not_OK_event_with :invalid_variable_name,
              :invalid_variable_name, @variegated_i.id2name
          end ; nil
        end

      public

        def value_x
          @x
        end

        def unparse_into_yielder y  # :+#arbitrary-styling, this style is covered
          y << rndr_line ; nil
        end

      private

        def rndr_line
          _s = marshal_RHS_via_x @x
          "#{ internal_normal_name_string } =#{ _s }#{ NEWLINE_ }"
        end

      public

        def accept_new_value x
          @x = x
          PROCEDE_
        end
      end

      class Assignment_Kernel__

        def to_line_stream
          _line = rndr_line
          Single_line_scanner__[ _line ]
        end

        def set_value x
          if x.nil?
            set_value_when_value_is_nil  # #open [#040]
          else
            accept_new_value x
          end
        end

      private

        def marshal_RHS_via_x x
          if x.nil?
            marshaled_RHS_when_nil  # #open [#040]
          else
            marshal_RHS_when_not_nil x
          end
        end

        def marshal_RHS_when_not_nil x
          if x.respond_to? :ascii_only?
            marshal_RHS_when_string x
          else
            marshal_RHS_when_not_nil_or_string x
          end
        end

        def marshal_RHS_when_not_nil_or_string x
          " #{ x }"  # pray for boolean, integer or float
        end

        def marshal_RHS_when_string s  # :#one-space
          s = s.dup
          Assignment_.mutate_value_string_for_marshal s
          if s.length.zero?
            s
          else
            " #{ s }"
          end
        end
      end

      class Event_Sending_Node__
      private

        Brazen_.event.selective_builder_sender_receiver self

        def maybe_send_event * i_a, & ev_p
          @parse.maybe_receive_event_via_channel i_a, & ev_p
        end
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

        def to_line_stream
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
