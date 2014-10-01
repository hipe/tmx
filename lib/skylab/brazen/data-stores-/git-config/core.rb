module Skylab::Brazen

  class Data_Stores_::Git_Config < Brazen_::Model_

    class << self

      def parse_path path_s, & p
        Parse_[ :via_path, path_s, :receive_events_via_proc, p ]
      end

      def parse_string str, & p
        Parse_[ :via_string, str, :receive_events_via_proc, p ]
      end
    end

    Actions = ::Module.new

    def initialize *a
      case a.length
      when 1
        kernel = a.first
      when 3
        @document, @event_receiver, kernel = a
      end
      super kernel
    end

    # ~ persist

    def persist_entity entity, _event_receiver
      ok = resolve_mutable_document
      ok &&= Git_Config_::Mutable::Actors::Mutate[ entity, @mutable_document ]
      ok and via_mutated_mutable_document_write_file_via_persisted_entity entity
    end

    # ~ retrieve (one)

    def entity_via_identifier id, evr
      Git_Config_::Actors__::Retrieve[ id, @document, evr, @kernel ]
    end

    # ~ retrieve (many)

    def entity_scan_via_class cls, evr
      Git_Config_::Actors__::Scan[ cls, @document, evr, @kernel ]
    end

    # ~ delete

    def delete_entity entity, evr
      ok = resolve_mutable_document
      ok &&= Git_Config_::Mutable::Actors::Delete[ entity, @mutable_document, evr ]
      ok and via_mutated_mutable_document_write_file_via_persisted_entity entity
    end

  private  # ~ verb support

    def resolve_mutable_document
      @did_resolve_mutable_document ||= rslv_mutable_document
      @mutable_document_is_resolved
    end

    def rslv_mutable_document
      if @document.is_mutable
        @mutable_document = @document
        @mutable_document_is_resolved = true
      else
        @mutable_document = Git_Config_::Mutable.
          parse_input_id @document.input_id, self
        @mutable_document_is_resolved = @mutable_document ? ACHEIVED_ : UNABLE_
      end
      if @mutable_document_is_resolved
        @document = nil  # LOOK
      end
      ACHEIVED_
    end

    def via_mutated_mutable_document_write_file_via_persisted_entity entity
      _is_dry = entity.any_parameter_value :dry_run
      _pn = @mutable_document.input_id.to_pathname
      Git_Config_::Mutable::Actors::Persist[ _is_dry, _pn, @mutable_document, entity ]
    end

    class Silo_Controller__ < Brazen_.model.silo_controller
      def controller_as_datastore_via_entity x
        document = Parse_[ :via_path, x.to_path,
          :receive_events_via_event_receiver, @event_receiver ]
        document and begin
          Git_Config_.new document, @event_receiver, @kernel
        end
      end
    end

    class Parse_  # the [#cb-046] "any result" pattern is employed.

      class << self
        def [] *a
          new( a ).execute
        end
      end

      Entity_[].event.sender self

      def initialize a
        input_method_i, input_x, event_receiver_method_i, event_receiver_x = a
        @input_id = Input_Identifier_.send input_method_i, input_x
        @event_receiver = send event_receiver_method_i, event_receiver_x
      end

    private
      def receive_events_via_proc p
        build_evt_rcvr_via_p p
      end

      public def build_evt_rcvr_via_p p
        if p
          p.respond_to?( :[] ) or raise ::ArgumentError, "[]: #{ p.class }"
        else
        p = -> ev do
          _s = ev.render_first_line_under Brazen_::API::EXPRESSION_AGENT
          raise ParseError, _s
        end
        end
        Event_[].receiver.via_proc p
      end

      def receive_events_via_event_receiver evr
        evr
      end
    public

      def execute
        ok = prepare_for_parse
        ok && execute_parse
        @result
      end

      def prepare_for_parse
        @column_number = nil
        @line_number = 0
        @state_i = initial_state_i
        @lines = @input_id.input_lines_adapter
        resolve_document
      end

      def execute_parse
        ok = PROCEDE_
        while @line = @lines.gets
          @line_number += 1
          BLANK_LINE_OR_COMMENT_RX_ =~ @line and next
          ok = send @state_i
          ok or break
        end
        if ok
          @result = @document
        end ; nil
      end
      BLANK_LINE_OR_COMMENT_RX_ = /\A[ ]*(?:\r?\n?\z|[#;])/

    private

      def recv_error_i i, col_number=nil

        col_number ||= @column_number || 1

        _x_a = [ :config_parse_error,
          :column_number, col_number,
          :line_number, @line_number,
          :line, @line,
          :parse_error_category_i, i,
          :reason, i.to_s.split( UNDERSCORE_ ).join( SPACE_ ) ]

        _ev = build_not_OK_event_via_mutable_iambic_and_message_proc _x_a, -> y, o do
          y << "#{ o.reason } #{
           }(#{ o.line_number }:#{ o.column_number })"
        end

        # @result = @event_receiver.receive_event _ev  # #todo


        @result = send_event _ev

        UNABLE_
      end

      # ~ business

      def initial_state_i
        :when_before_section
      end

      def resolve_document
        @document = Document_.new @input_id
        PROCEDE_
      end

      # ~

      def when_before_section
        @md = SECTION_RX__.match @line
        if @md
          accpt_section
        else
          recv_error_i :section_expected
        end
      end
      _NAME_RX = '[-A-Za-z0-9.]+'
      SECTION_RX__ = /\A[ ]*\[[ ]*
       (?<name>#{ _NAME_RX })
        (?:[ ]+"(?<subsect>(?:[^\n"\\]+|\\["\\])+)")?[ ]*\][ ]*\r?\n?\z/x

      def accpt_section
        if (( ss = @md[ :subsect ] ))
          Section_.unescape_subsection_name ss
        end
        @sect = Section_.new @md[ :name ], ss
        @document.sections.accept_sect @sect
        @state_i = :when_section_or_assignment
        PROCEDE_
      end

      # ~

      def when_section_or_assignment
        if (( @md = ASSIGNMENT_LINE_RX__.match @line ))
          accpt_assignment
        elsif (( @md = SECTION_RX__.match @line ))
          accpt_section
        else
          recv_error_i :assignment_or_section_expected
        end
      end
      ASSIGNMENT_LINE_RX__ = /\A[ ]*
        (?<name>[a-zA-Z][-a-zA-Z0-9]*)[ ]*
        (?:=[ ]*(?<unparsed_value>[^\r\n]*))?
      \r?\n?/x

      def accpt_assignment
        @sect.assignments.accept_asmt Assignment_.new( * @md.captures )
        PROCEDE_
      end
    end

    module Input_Identifier_
      class << self
        def via_string s
          String_Input_Identifier__.new s
        end

        def via_path s
          Path_Input_Identifier__.new s
        end
      end
    end

    class String_Input_Identifier__
      def initialize s
        @s = s
      end

      def description_under _expr_
        Lib_::Ellispify[ @s ].inspect
      end

      def input_lines_adapter
        String_Input_Adapter_.new @s
      end
    end

    class Path_Input_Identifier__
      def initialize s
        @path_s = s
      end

      def to_pathname
        @path_s and ::Pathname.new @path_s
      end

      def description_under expr
        s = @path_s
        expr.calculate do
          pth s
        end
      end

      def input_lines_adapter
        Path_Input_Adapter_.new @path_s
      end
    end

    class String_Input_Adapter_
      def initialize str
        @scn = Lib_::String_scanner[].new str
      end

      def gets
        @scn.scan RX__
      end

      RX__ = /[^\r\n]*\r?\n|[^\r\n]+/
    end

    class Path_Input_Adapter_
      def initialize path_s
        @IO = ::File.open path_s, 'r'
      end

      def gets
        @IO.gets
      end
    end

    module Lib_
      memoize = -> p { p_ = -> { x = p[] ; p_ = -> { x } ; x } ; -> { p_[] } }

      String_scanner = memoize[ -> do
        require 'strscan' ; ::StringScanner
      end ]
    end

    class Document_
      def initialize input_id
        @input_id = input_id
        @sections = Sections__.new
      end
      attr_reader :input_id, :sections

      def is_mutable
        false
      end
    end

    class Box__
      def initialize
        @a = [] ; @h = {}
      end
      def length
        @a.length
      end
      def first
        @a.first
      end
      def [] i
        idx = @h[ i ]
        idx && @a.fetch( idx )
      end
      def to_scan
        Scan_[].nonsparse_array @a
      end
      def map & p
        @a.map( & p )
      end
    end

    class Sections__ < Box__
      def accept_sect sect
        @h[ sect.normalized_name_i ] = @a.length
        @a.push sect ; nil
      end
    end

    class Section_

      def self.escape_subsection_name s
        s.gsub! BACKSLASH_, BACKSLASH_BACKSLASH_  # do this first
        s.gsub! QUOTE_, BACKSLASH_QUOTE_ ; nil
      end

      def self.unescape_subsection_name s
        s.gsub! BACKSLASH_QUOTE_, QUOTE_
        s.gsub! BACKSLASH_BACKSLASH_, BACKSLASH_ ; nil
      end

      def initialize name_s, subsect_name_s
        @name_s = name_s.freeze
        @subsect_name_s = ( subsect_name_s.freeze if subsect_name_s )
        @assignments = Assignments__.new
        @normalized_name_i = @name_s.downcase.intern
      end

      attr_reader :name_s, :subsect_name_s
      attr_reader :normalized_name_i
      attr_reader :assignments
    end

    class Assignments__ < Box__
      def accept_asmt asmt
        @h[ asmt.normalized_name_i ] = @a.length
        @a.push asmt ; nil
      end

      def [] i
        idx = @h[ i ]
        if idx
          @a.fetch( idx ).value_x
        else
          raise ::NameError, "no such assignment '#{ i }'"
        end
      end

      def each_normalized_pair
        if block_given?
          scn = to_normalized_actual_property_scan
          while pair = scn.gets
            yield( * pair.to_a )
          end ; nil
        else
          to_enum :each_normalized_pair
        end
      end

      def to_normalized_actual_property_scan
        d = -1 ; last = @a.length - 1
        Scan_[].new do
          while d < last
            d += 1
            ast = @a.fetch d
            # no 'symbol_i' here yet
            x = Actual_Property__.new( ast.value_x, ast.normalized_name_i )
            break
          end
          x
        end
      end
    end

    Actual_Property__ = Brazen_.model.actual_property

    class Assignment_
      def initialize name_s, unparsed_value_s
        @name_s = name_s ; @unparsed_value_s = unparsed_value_s
        @normalized_name_i = @name_s.downcase.intern
        @is_parsed = false
      end
      attr_reader :name_s, :unparsed_value_s
      attr_reader :normalized_name_i

      def value_x
        @is_parsed or parse
        @value_x
      end

      def parse
        @is_parsed = true
        if Q__ == @unparsed_value_s.getbyte( 0 )
          parse_quoted_string
        elsif (( @md = INTEGER_RX__.match @unparsed_value_s ))
          @value_x = @md[ 0 ].to_i
        elsif TRUE_RX__ =~ @unparsed_value_s
          @value_x = true
        elsif FALSE_RX__ =~ @unparsed_value_s
          @value_x = false
        else
          @md = ALL_OTHERS_RX__.match @unparsed_value_s
          @md or fail "sanity: #{ @unparsed_value_s.inspect }"
          @value_x = @md[ 0 ]
        end ; nil
      end
      Q__ = '"'.getbyte 0
      _REST_OF_LINE_ = '(?=[ ]*(?:[;#]|\z))'
      INTEGER_RX__ = /\A-?[0-9]+#{ _REST_OF_LINE_ }/
      TRUE_RX__ = /\A(?:yes|true|on)#{ _REST_OF_LINE_ }/i
      FALSE_RX__ = /\A(?:no|false|off)#{ _REST_OF_LINE_ }/i
      ALL_OTHERS_RX__ = /\A[^ ;#]+(?:[ ]+[^ ;#]+)*#{ _REST_OF_LINE_ }/i

      def parse_quoted_string
        @md = QUOTED_STRING_RX__.match @unparsed_value_s
        @md or raise ParseError, "huh? #{ @unparsed_value_s.inspect }"
        @value_x = @md[0]
        self.class.unescape_quoted_value_string @value_x
        nil
      end
      QUOTED_STRING_RX__ = /(?<=\A")(?:\\"|[^"])*(?="[ ]*(?:[;#]|\z))/

      def self.escape_value_string s
        s.gsub! BACKSLASH_, BACKSLASH_BACKSLASH_BACKSLASH__  # do first else etc
        s.gsub! QUOTE_, BACKSLASH_QUOTE_
        s.gsub! NEWLINE_, BACKSLASH_N__
        s.gsub! TAB__, BACKSLASH_T__
        s.gsub! BACKSPACE__, BACKSLASH_B__ ; nil
      end
      BACKSLASH_BACKSLASH_BACKSLASH__ = '\\\\\\'  # the gsub arg uses '\' too :(

      def self.unescape_quoted_value_string s
        s.gsub! BACKSLASH_QUOTE_, QUOTE_
        s.gsub! BACKSLASH_N__, NEWLINE_
        s.gsub! BACKSLASH_T__, TAB__
        s.gsub! BACKSLASH_B__, BACKSPACE__
        s.gsub! BACKSLASH_BACKSLASH_, BACKSLASH_ ; nil # do this last, else etc
      end
      BACKSLASH_N__ = '\n'.freeze
      BACKSLASH_T__ = '\t'.freeze ; TAB__ = "\t".freeze
      BACKSLASH_B__ = '\b'.freeze ; BACKSPACE__ = "\b".freeze
    end

    BACKSLASH_ = '\\'.freeze
    BACKSLASH_BACKSLASH_ = '\\\\'.freeze
    BACKSLASH_QUOTE_ = '\\"'.freeze
    CEASE_ = false
    Git_Config_ = self
    NEWLINE_ = "\n".freeze
    ParseError = ::Class.new ::RuntimeError
    PROCEDE_ = true
    QUOTE_= '"'.freeze

  end
end
