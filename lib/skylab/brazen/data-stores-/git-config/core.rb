module Skylab::Brazen

  class Data_Stores_::Git_Config < Brazen_::Model_

    class << self

      def parse_path path_s, & oes_p
        Parse_[ :via_path, path_s, :on_event_selectively, oes_p ]
      end

      def parse_string str, & oes_p
        Parse_[ :via_string, str, :on_event_selectively, oes_p ]
      end

      def read io, & oes_p
        Parse_[ :via_stream, io, :on_event_selectively, oes_p ]
      end

      def write * a
        Git_Config_::Actors__::Write.call_via_arglist a
      end
    end

    Actions = ::Module.new

    def initialize * a, & oes_p
      case a.length
      when 1
        kernel = a.first
      when 2
        @document, kernel = a
      else
        raise ::ArgumentError
      end
      super kernel, & oes_p
    end

    def members
      [ :receive_delete_entity, :entity_stream_via_model,
          :entity_via_identifier, :receive_persist_entity,
            :property_value_via_symbol ]
    end

    def description_under expag
      if @document
        @document.description_under expag
      elsif @mutable_document
        @mutable_document.description_under expag
      else
        "«git config»"  # :+#guillemets
      end
    end

    # ~ persist

    def receive_persist_entity action, entity, & oes_p
      ok = resolve_mutable_document( & oes_p )
      ok &&= Git_Config_::Mutable::Actors::Mutate[ entity, @mutable_document, & oes_p ]
      ok and _via_mutated_mutable_document_write_file_via_persist( action, & oes_p )
    end

    # ~ retrieve (one)

    def entity_via_identifier id, & oes_p
      Git_Config_::Actors__::Retrieve[ id, @document, @kernel, & oes_p ]
    end

    # ~ retrieve (many)

    def entity_stream_via_model cls, & oes_p
      Git_Config_::Actors__::Build_stream[ cls, @document, @kernel, & oes_p ]
    end

    def to_section_stream & oes_p
      Git_Config_::Actors__::Build_stream[ nil, @document, @kernel, & oes_p ]
    end

    # ~ delete

    def receive_delete_entity action, entity, & oes_p
      ok = resolve_mutable_document
      ok &&= Git_Config_::Mutable::Actors::Delete[ entity, @mutable_document, & oes_p ]
      ok and _via_mutated_mutable_document_write_file_via_persist( action, & oes_p )  # _DOG_EAR
    end

    # ~ atomic property values

    def property_value_via_symbol sym, & oes_p
      x = @document.sections[ sym ]
      if x

        x.subsect_name_s

      elsif oes_p
        oes_p.call :info, :property_not_found do

          Callback_::Event.inline_neutral_with :property_not_found,
              :property_symbol, sym,
              :input_identifier, @document.input_id do |y, o|

            y << "no #{ nm Callback_::Name.via_variegated_symbol o.property_symbol } #{
              }property in #{ o.input_identifier.description_under self }"
          end
        end
      end
    end

  private  # ~ verb support

    def resolve_mutable_document & oes_p
      @did_resolve_mutable_document ||= rslv_mutable_document( & oes_p )
      @mutable_document_is_resolved
    end

    def rslv_mutable_document & oes_p
      if @document.is_mutable
        @mutable_document = @document
        @mutable_document_is_resolved = true
      else
        @mutable_document = Git_Config_::Mutable.parse_input_id(
          @document.input_id, & ( oes_p || @on_event_selectively ) )
        @mutable_document_is_resolved = @mutable_document ? ACHIEVED_ : UNABLE_
      end
      if @mutable_document_is_resolved
        @document = nil  # LOOK
      end
      ACHIEVED_
    end

    def _via_mutated_mutable_document_write_file_via_persist action, & oes_p  # #covered-by [tm]

      Git_Config_::Mutable::Actors::Persist.with(
        :is_dry, action.argument_box[ :dry_run ],
        :path, @mutable_document.input_id.to_path,
        :document, @mutable_document,
        & oes_p )
    end

    class Silo_Controller__ < Brazen_.model.silo_controller_class

      def provide_action_precondition _id, _g
        self
      end

      def provide_collection_controller_precon _id, _g
        self
      end

      def datastore_controller_via_entity x
        document = Parse_[ :via_path, x.existent_config_path,
                           :on_event_selectively, @on_event_selectively ]
        document and begin
          Git_Config_.new document, @kernel, & @on_event_selectively
        end
      end
    end

    class Parse_  # the [#cb-046] "any result" pattern is employed.

      class << self
        def [] *a
          new( a ).execute
        end
      end

      Brazen_.event.selective_builder_sender_receiver self

      def initialize a
        input_method_i, input_x, event_receiver_method_i, event_receiver_x = a
        @input_id = Input_Identifier_.send input_method_i, input_x
        @on_event_selectively = send event_receiver_method_i, event_receiver_x
      end

      def on_event_selectively oes_p
        if oes_p
          oes_p
        else
          -> i, *, & ev_p do
            if :info != i
              _ev = ev_p[]
              _s = ev.render_first_line_under Brazen_::API.expression_agent_instance
              raise ParseError, _s
            end
          end
        end
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
        @lines = @input_id.to_line_stream_
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

      private def recv_error_symbol sym
        receive_error_symbol_and_column_number_ sym, @column_number   # col num nil OK
      end

      def receive_error_symbol_and_column_number_ sym, col_number

        @result = @on_event_selectively.call :error, :config_parse_error do
          bld_config_parse_error sym, col_number
        end

        UNABLE_
      end

    private

      def bld_config_parse_error i, col_number

        col_number ||= @column_number || 1

        _x_a = [ :config_parse_error,
          :column_number, col_number,
          :line_number, @line_number,
          :line, @line,
          :parse_error_category_i, i,
          :reason, i.to_s.split( UNDERSCORE_ ).join( SPACE_ ),
          :input_identifier, @input_id ]

        build_not_OK_event_via_mutable_iambic_and_message_proc _x_a, -> y, o do

          _s = o.input_identifier.description_under self

          y << "#{ o.reason } in #{ _s }:#{ o.line_number }:#{ o.column_number }"

          s = "#{ o.line_number }:"
          fmt = "  %#{ s.length }s %s"

          y << fmt % [ s, o.line ]
          y << fmt % [ nil, "#{ SPACE_ * ( o.column_number - 1 ) }^" ]

        end
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
          recv_error_symbol :section_expected
        end
      end
      _NAME_RX = '[-A-Za-z0-9.]+'
      SECTION_RX__ = /\A[ ]*\[[ ]*
       (?<name>#{ _NAME_RX })
        (?:[ ]+"(?<subsect>(?:[^\n"\\]+|\\["\\])+)")?[ ]*\][ ]*\r?\n?\z/x

      def accpt_section
        ss = @md[ :subsect ]
        if ss
          Section_.mutate_subsection_name_for_unmarshal ss
        end
        @sect = Section_.new @md[ :name ], ss
        @document.sections.accept_sect @sect
        @state_i = :when_section_or_assignment
        PROCEDE_
      end

      # ~

      def when_section_or_assignment
        @md = ASSIGNMENT_LINE_RX__.match @line
        if @md
          accpt_assignment
        elsif (( @md = SECTION_RX__.match @line ))
          accpt_section
        else
          recv_error_symbol :assignment_or_section_expected
        end
      end
      ASSIGNMENT_LINE_RX__ = /\A[ ]*
        (?<name>[a-zA-Z][-a-zA-Z0-9]*)[ ]*
        (?:=[ ]*(?<unparsed_value>[^\r\n]*))?
      \r?\n?/x

      def accpt_assignment
        @sect.assignments.accept_asmt(
          Assignment_.new( * @md.captures, & @on_event_selectively ) )
        PROCEDE_
      end
    end

    module Input_Identifier_

      class << self

        def via_stream io
          Stream_Input_Identifier__.new io
        end

        def via_string s
          String_Input_Identifier__.new s
        end

        def via_path s
          Path_Input_Identifier__.new s
        end
      end
    end

    class Stream_Input_Identifier__

      def initialize io
        @io = io
      end

      def description_under expag
        if @io.respond_to? :path
          path = @io.path
          expag.calculate do
            pth path
          end
        else
         "«input stream»"  # :+#guillemets
        end
      end

      def to_line_stream_
        @io
      end
    end

    class String_Input_Identifier__

      def initialize s
        @s = s
      end

      def description_under _expr_
        LIB_.ellispsify( @s ).inspect
      end

      def to_line_stream_
        String_Input_Adapter_.new @s
      end
    end

    class Path_Input_Identifier__

      def initialize s
        @path_s = s
      end

      def members
        [ :to_path, :to_pathname, :description_under, :to_line_stream_ ]
      end

      def to_path
        @path_s
      end

      def to_pathname
        @path_s and ::Pathname.new @path_s
      end

      def description_under expr
        Brazen_.lib_.basic::Pathname.description_under_of_path expr, @path_s
      end

      def to_line_stream_
        Path_Input_Adapter_.new @path_s
      end
    end

    class String_Input_Adapter_
      def initialize str
        @scn = LIB_.string_scanner.new str
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

    class Document_

      def initialize input_id
        @input_id = input_id
        @sections = Sections__.new
      end

      def members
        Document_.public_instance_methods( false ) - [ :members ]
      end

      attr_reader :input_id, :sections

      def is_mutable
        false
      end

      def description_under expag
        @input_id.description_under expag
      end

      def to_section_stream & oes_p
        @sections.to_stream( & oes_p )
      end
    end

    class Box__
      def initialize
        @a = [] ; @h = {}
      end
      def members
        [ :length, :first, :to_stream ]
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
      def to_stream
        Callback_.stream.via_nonsparse_array @a
      end
      def each_pair
        @a.each do | ast |
          :assignment == ast.nonterminal_symbol or next
          yield ast.external_normal_name_symbol, ast.value_x
        end
      end
      def map & p
        @a.map( & p )
      end
    end

    class Sections__ < Box__
      def accept_sect sect
        @h[ sect.external_normal_name_symbol ] = @a.length
        @a.push sect ; nil
      end
    end

    class Section_

      class << self

        def mutate_subsection_name_for_marshal s
          s.gsub! BACKSLASH_, BACKSLASH_BACKSLASH_  # do this first
          s.gsub! QUOTE_, BACKSLASH_QUOTE_ ; nil
        end

        def mutate_subsection_name_for_unmarshal s
          s.gsub! BACKSLASH_QUOTE_, QUOTE_
          s.gsub! BACKSLASH_BACKSLASH_, BACKSLASH_ ; nil
        end
      end

      def initialize name_s, subsect_name_s
        @internal_normal_name_string = name_s.freeze
        @subsect_name_s = ( subsect_name_s.freeze if subsect_name_s )
        @assignments = Assignments__.new
        @external_normal_name_symbol = @internal_normal_name_string.downcase.intern
      end

      def members
        [ :assignments, :external_normal_name_symbol,
          :internal_normal_name_string, :subsect_name_s ]
      end

      attr_reader :assignments,
        :external_normal_name_symbol,
        :internal_normal_name_string,
        :subsect_name_s
    end

    class Assignments__ < Box__

      def members
        [ * super, :each_normalized_pair, :to_pair_stream ]
      end

      def accept_asmt asmt
        @h[ asmt.internal_normal_name_symbol ] = @a.length
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
          st = to_pair_stream
          pair = st.gets
          while pair
            yield pair.name_i, pair.value_x
            pair = st.gets
          end
        else
          to_enum :each_normalized_pair
        end
      end

      def to_pair_stream
        d = -1 ; last = @a.length - 1
        Callback_.stream do
          while d < last
            d += 1
            ast = @a.fetch d
            x = Actual_Property__.new( ast.value_x, ast.external_normal_name_symbol )
            break
          end
          x
        end
      end
    end

    Actual_Property__ = Brazen_.model.actual_property

    class Assignment_

      def initialize name_s, marshaled_s, & oes_p
        @internal_normal_name_string = name_s
        @marshaled_s = marshaled_s
        @did_unmarshal = false
        @on_event_selectively = oes_p
      end

      def members
        [ :internal_normal_name_string, :external_normal_name_symbol, :value_x ]
      end

      def nonterminal_symbol
        :assignment
      end

      attr_reader :internal_normal_name_string, :marshaled_s

      def external_normal_name_symbol
        # uppercase is OK but convert dashes to underscores
        @enn_i ||= @internal_normal_name_string.gsub( DASH_, UNDERSCORE_ ).intern
      end

      def internal_normal_name_symbol
        # per spec but might change
        @inn_i ||= @internal_normal_name_string.downcase.intern
      end

      def value_x
        @did_unmarshal or unmarshal
        @value_x
      end

      def unmarshal
        @did_unmarshal = true
        if Q__ == @marshaled_s.getbyte( 0 )
          unmarshal_quoted_string
        elsif (( @md = INTEGER_RX__.match @marshaled_s ))
          @value_x = @md[ 0 ].to_i
        elsif TRUE_RX__ =~ @marshaled_s
          @value_x = true
        elsif FALSE_RX__ =~ @marshaled_s
          @value_x = false
        else
          @md = ALL_OTHERS_RX__.match @marshaled_s
          @md or fail "sanity: #{ @marshaled_s.inspect }"
          s = @md[ 0 ]
          if self.class.mutate_value_string_for_unmarshal s, @on_event_selectively
            @value_x = s
          end
        end ; nil
      end
      Q__ = '"'.getbyte 0
      _REST_OF_LINE_ = '(?=[ ]*(?:[;#]|\z))'
      INTEGER_RX__ = /\A-?[0-9]+#{ _REST_OF_LINE_ }/
      TRUE_RX__ = /\A(?:yes|true|on)#{ _REST_OF_LINE_ }/i
      FALSE_RX__ = /\A(?:no|false|off)#{ _REST_OF_LINE_ }/i
      ALL_OTHERS_RX__ = /\A[^ ;#]+(?:[ ]+[^ ;#]+)*#{ _REST_OF_LINE_ }/i

      def unmarshal_quoted_string
        @md = QUOTED_STRING_RX__.match @marshaled_s
        @md or raise ParseError, "huh? #{ @marshaled_s.inspect }"
        s = @md[ 0 ]
        if self.class.mutate_value_string_for_unmarshal s, @on_event_selectively
          @value_x = s
        end
        nil
      end
      QUOTED_STRING_RX__ = /(?<=\A")(?:\\"|[^"])*(?="[ ]*(?:[;#]|\z))/

      class << self

        def mutate_value_string_for_marshal s
          # this logic is lifted term-by-term from the git config manpage
          _quotes_are_necessary = QUOTES_ARE_NECESSARY_RX__ =~ s
          s.gsub! ESCAPE_THESE_SOMEOHOW_RX__ do
            ESCAPE_STRATEGY_MAP__.fetch( $~[ 0 ].getbyte( 0 ) )[ $~[ 0 ] ]
          end
          if _quotes_are_necessary
            s[ 0, 0 ] = '"'
            s[ s.length ] = '"'
          end
          nil
        end

        QUOTES_ARE_NECESSARY_RX__ = %r(
          \A[[:space:]]   |  # if any leading whitespace
            [[:space:]]\z |  # if any trailing whitespace
             [#;]            # if the variable contains comment characters
        )x

        ESCAPE_THESE_SOMEOHOW_RX__ = /["\\\n\t\b]/

        backslash = -> s do
          "\\#{ s }"
        end

        ESCAPE_STRATEGY_MAP__ = {
          '"'.getbyte( 0 ) => backslash,
          '\\'.getbyte( 0 ) => backslash,
          "\n".getbyte( 0 ) => backslash,  # spec offers 2 ways, we chose 1
          "\t".getbyte( 0 ) => -> _ { '\t' },
          "\b".getbyte( 0 ) => -> _ { '\b' }
        }.freeze

        def mutate_value_string_for_unmarshal string, oes
          ok = true
          string.gsub! UNESCAPE_THESE_SOMEHOW_RX__ do
            s = $~[ 1 ]  # is empty string IFF backslash was at end of line
            p = UNESCAPE_STRAEGY_MAP__[ s.getbyte 0 ]
            if p
              _otr = p[ s ]
              _otr
            else
              oes.call :error, :invalid_escape_sequence do
                build_invalid_escape_sequence_event $~[ 0 ]  # #todo - unimplemented error cse
              end
              ok = false
              s  # put the string "back in" as-is
            end
          end
          ok
        end

        UNESCAPE_THESE_SOMEHOW_RX__ = /\\(.?)/

        UNESCAPE_STRAEGY_MAP__ = {
          '"'.getbyte( 0 ) => IDENTITY_,
          '\\'.getbyte( 0 ) => IDENTITY_,
          'n'.getbyte( 0 ) => -> _ { "\n" },
          't'.getbyte( 0 ) => -> _ { "\t" },
          'b'.getbyte( 0 ) => -> _ { "\b" }
        }.freeze
      end
    end

    BACKSLASH_ = '\\'.freeze
    BACKSLASH_BACKSLASH_ = '\\\\'.freeze
    BACKSLASH_QUOTE_ = '\\"'.freeze
    CEASE_ = false
    Git_Config_ = self
    ParseError = ::Class.new ::RuntimeError
    PROCEDE_ = true
    QUOTE_= '"'.freeze

  end
end
