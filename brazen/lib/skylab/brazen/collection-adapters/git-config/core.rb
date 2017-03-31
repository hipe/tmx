module Skylab::Brazen

  class CollectionAdapters::GitConfig < Home_::Model

    class << self

      def parse_path path, & oes_p
        Document_via_[ :via_path, path, & oes_p ]
      end

      def parse_string str, & oes_p
        Document_via_[ :via_string, str, & oes_p ]
      end

      def read io, & oes_p
        Document_via_[ :via_stream, io, & oes_p ]
      end

      def via_path_and_kernel path, kernel, & p

        doc = Document_via_[ :via_path, path, & p ]
        if doc
          Here_.new doc, kernel, & p
        else
          doc
        end
      end

      def write * a
        Here_::Magnetics::PersistEntity_via_Entity_and_Collection.call_via_arglist a
      end
    end  # >>

    Actions = ::Module.new

    def initialize doc=nil, kernel

      if doc
        if doc.is_mutable
          _receive_mutable_document doc
        else
          __receive_immutable_document doc
        end
        @_has_document = true
      else
        @_has_document = false
      end

      super kernel
    end

    def description_under expag
      if @_has_document
        _with_document nil do |doc|
          doc.description_under expag
        end
      else
        "«git config»"  # :+#guillemets
      end
    end

    # ~ persist

    def persist_entity x=nil, ent, & p

      with_mutable_document p do |doc|

        ok = ent.intrinsic_persist_before_persist_in_collection( * x, & p )
        ok &&= Here_::Mutable::Magnetics::MutateDocument_via_Entity_and_Collection[ ent, doc, & p ]
        ok and _via_mutated_mutable_document_write_file_via_persist p, x, doc
      end
    end

    # ~ retrieve (one)

    def entity_via_intrinsic_key id, & p

      _with_document p do |doc|
        Here_::Magnetics::RetrieveEntity_via_EntityIdentifier_and_Document[ id, doc, @kernel, p ]
      end
    end

    # ~ retrieve (many)

    def to_entity_stream_via_model cls, & p

      _with_document p do |doc|
        Here_::Magnetics::EntityStream_via_Collection[ cls, doc, @kernel, & p ]
      end
    end

    def to_section_stream & p

      _with_document p do |doc|
        Here_::Magnetics::EntityStream_via_Collection[ nil, doc, @kernel, & p ]
      end
    end

    # ~ delete

    def delete_entity action, entity, & p

      with_mutable_document p do |doc|

        ok = entity.intrinsic_delete_before_delete_in_collection( action, & p )
        ok &&= Here_::Mutable::Magnetics::DeleteEntity_via_Entity_and_Collection[ entity, p, & p ]
        ok and _via_mutated_mutable_document_write_file_via_persist p, action.argument_box, doc
      end
    end

    # ~ atomic property values

    def property_value_via_symbol sym, & p

      _with_document p do |doc|

        x = doc.sections[ sym ]

        if x
          x.subsection_name_string
        elsif p
          __when_property_not_found p, sym, doc
        else
          NOTHING_
        end
      end
    end

    def __when_property_not_found p, sym, doc

      p.call :info, :property_not_found do

        Common_::Event.inline_neutral_with(
          :property_not_found,
          :property_symbol, sym,
          :byte_upstream_reference, doc.byte_upstream_reference,

        ) do |y, o|

          _name = Common_::Name.via_variegated_symbol o.property_symbol
          _here = o.byte_upstream_reference.description_under self

          y << "no #{ nm _name } property in #{ _here }"
        end
      end

      NOTHING_
    end

    # --

    def _via_mutated_mutable_document_write_file_via_persist p, bx, doc  # #covered-by [tm]

      Here_::Mutable::Magnetics::WriteDocument_via_Collection.via(
        :is_dry, bx[ :dry_run ],
        :path, doc.byte_upstream_reference.to_path,
        :document, doc,
        & p )
    end

    # --

    def with_mutable_document listener, & do_this  # [tm]

      send @_with_MD, listener, & do_this
    end

    def _with_document listener, & do_this

      send @_with_D, listener, & do_this
    end

    def _with_MD_as_is _listener
      yield @_mutable_document_instance
    end

    def __with_D_as_is _listener
      yield @_immutable_document_instance
    end

    def _with_MD_through_work listener, & do_this

      _idoc = remove_instance_variable :@_immutable_document_instance
      listener ||= @on_event_selectively

      mdoc = Here_::Mutable.parse_byte_upstream_reference _idoc.byte_upstream_reference, & listener
      if mdoc
        _receive_mutable_document mdoc
        send @_with_MD, listener, & do_this
      else
        # ..
        remove_instance_variable :@_with_MD
        remove_instance_variable :@_with_D
        @_has_document = false
        freeze
        mdoc
      end
    end

    # ~

    def _receive_mutable_document doc

      @_with_MD = :_with_MD_as_is
      @_with_D = :_with_MD_as_is
      @_mutable_document_instance = doc ; nil
    end

    def __receive_immutable_document doc

      @_with_MD = :_with_MD_through_work
      @_with_D = :__with_D_as_is
      @_immutable_document_instance = doc ; nil
    end

    # ==

    class Document_via_  # the [#fi-016] "any result" pattern is employed.

      class << self
        def via *a, & oes_p
          new( a, & oes_p ).execute
        end
        alias_method :[], :via
        private :new
      end  # >>

      include Common_::Event::ReceiveAndSendMethods

      def initialize a, & oes_p
        input_method_sym, input_x = a
        @byte_upstream_reference = Byte_upstream_reference_[].send input_method_sym, input_x
        @on_event_selectively = oes_p
      end

    public

      def execute
        init_for_parse_
        execute_parse
        @result
      end

      def init_for_parse_
        @column_number = nil
        @lineno = 0
        @state_symbol = :when_before_section
        @lines = @byte_upstream_reference.to_simple_line_stream
        init_appropriate_document_instance_
      end

      def execute_parse
        ok = ACHIEVED_
        while @line = @lines.gets
          @lineno += 1
          BLANK_LINE_OR_COMMENT_RX_ =~ @line and next
          ok = send @state_symbol
          ok or break
        end
        if ok
          @result = @document
        end ; nil
      end
      BLANK_LINE_OR_COMMENT_RX_ = /\A[ ]*(?:\r?\n?\z|[#;])/

      private def _receive_error_symbol sym
        receive_error_symbol_and_column_number_ sym, @column_number   # col num nil OK
      end

      def receive_error_symbol_and_column_number_ sym, col_number

        @on_event_selectively.call :error, :config_parse_error do
          __build_config_parse_error sym, col_number
        end
        @result = UNABLE_
        UNABLE_
      end

      def __build_config_parse_error sym, col_number

        col_number ||= @column_number || 1

        _x_a = [
          :config_parse_error,
          :column_number, col_number,
          :lineno, @lineno,
          :line, @line,
          :parse_error_category_symbol, sym,
          :reason, sym.to_s.split( UNDERSCORE_ ).join( SPACE_ ),
          :byte_upstream_reference, @byte_upstream_reference ]

        build_not_OK_event_via_mutable_iambic_and_message_proc _x_a, -> y, o do

          _s = o.byte_upstream_reference.description_under self

          y << "#{ o.reason } in #{ _s }:#{ o.lineno }:#{ o.column_number }"

          s = "#{ o.lineno }:"
          fmt = "  %#{ s.length }s %s"

          y << fmt % [ s, o.line ]
          y << fmt % [ nil, "#{ SPACE_ * ( o.column_number - 1 ) }^" ]

        end
      end

      # ~

      def when_before_section
        @md = SECTION_RX__.match @line
        if @md
          accpt_section
        else
          _receive_error_symbol :section_expected
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
        @state_symbol = :when_section_or_assignment
        ACHIEVED_
      end

      # ~

      def when_section_or_assignment
        @md = ASSIGNMENT_LINE_RX__.match @line
        if @md
          accpt_assignment
        elsif (( @md = SECTION_RX__.match @line ))
          accpt_section
        else
          _receive_error_symbol :assignment_or_section_expected
        end
      end
      ASSIGNMENT_LINE_RX__ = /\A[ ]*
        (?<name>[a-zA-Z][-a-zA-Z0-9]*)[ ]*
        (?:=[ ]*(?<unparsed_value>[^\r\n]*))?
      \r?\n?/x

      def accpt_assignment
        @sect.assignments.accept_asmt(
          Assignment_.new( * @md.captures, & @on_event_selectively ) )
        ACHIEVED_
      end

      # ~

      def init_appropriate_document_instance_
        @document = Document___.new @byte_upstream_reference
        NIL
      end
    end

    class Document___

      def initialize byte_upstream_reference
        @byte_upstream_reference = byte_upstream_reference
        @sections = Sections__.new
      end

      def description_under expag
        @byte_upstream_reference.description_under expag
      end

      def to_section_stream & oes_p
        @sections.to_value_stream( & oes_p )
      end

      attr_reader(
        :byte_upstream_reference,
        :sections,
      )

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

      def [] sym
        idx = @h[ sym ]
        idx && @a.fetch( idx )
      end

      def to_value_stream
        Common_::Stream.via_nonsparse_array @a
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
        @subsection_name_string = ( subsect_name_s.freeze if subsect_name_s )
        @assignments = Assignments__.new
        @external_normal_name_symbol = @internal_normal_name_string.downcase.intern
      end

      attr_reader(
        :assignments,
        :external_normal_name_symbol,
        :internal_normal_name_string,
        :subsection_name_string,
      )
    end

    class Assignments__ < Box__

      def accept_asmt asmt
        @h[ asmt.internal_normal_name_symbol ] = @a.length
        @a.push asmt ; nil
      end

      def [] sym
        idx = @h[ sym ]
        if idx
          @a.fetch( idx ).value_x
        else
          raise ::NameError, "no such assignment '#{ sym }'"
        end
      end

      def each_normalized_pair
        if block_given?
          st = to_pair_stream
          pair = st.gets
          while pair
            yield pair.name_symbol, pair.value_x
            pair = st.gets
          end
        else
          to_enum :each_normalized_pair
        end
      end

      def to_pair_stream

        d = -1
        last = @a.length - 1

        Common_.stream do

          if d < last
            d += 1
            ast = @a.fetch d
            Common_::Pair.via_value_and_name(
              ast.value_x,
              ast.external_normal_name_symbol )
          end
        end
      end
    end

    class Assignment_

      def initialize name_s, marshaled_s, & oes_p
        @internal_normal_name_string = name_s
        @marshaled_s = marshaled_s
        @did_unmarshal = false
        @on_event_selectively = oes_p
      end

      def external_normal_name_symbol
        # uppercase is OK but convert dashes to underscores
        @enn_symbol ||= @internal_normal_name_string.gsub( DASH_, UNDERSCORE_ ).intern
      end

      def internal_normal_name_symbol
        # per spec but might change
        @inn_symbol ||= @internal_normal_name_string.downcase.intern
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
                self.__TODO_build_invalid_escape_sequence_event $~[ 0 ]
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
      end  # >>

      attr_reader(
        :internal_normal_name_string,
        :marshaled_s,
      )

      def nonterminal_symbol
        :assignment
      end
    end

    BACKSLASH_ = '\\'.freeze
    BACKSLASH_BACKSLASH_ = '\\\\'.freeze
    BACKSLASH_QUOTE_ = '\\"'.freeze
    CEASE_ = false
    Here_ = self
    ParseError = ::Class.new ::RuntimeError
    ACHIEVED_ = true
    QUOTE_ = '"'.freeze
  end
end
