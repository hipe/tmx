module Skylab::Brazen

  class CollectionAdapters::GitConfig < Home_::Model  # introduction at :[#009]

    class << self

      def via_path_and_kernel path, kernel, & p

        doc = parse_document_by do |o|
          o.upstream_path = path
          o.listener = p
        end

        doc and Here_.new doc, kernel, & p
      end

      def parse_document_by
        ImmutableDocument_via___.call_by do |o|
          yield o
        end
      end
    end  # >>

    CommonDocumentParse_ = ::Class.new Common_::MagneticBySimpleModel

    class ImmutableDocument_via___ < CommonDocumentParse_

      def init_appropriate_document_instance_
        @document = Document___.new @byte_upstream_reference
        NIL
      end

      def execute_parse_

        ok = ACHIEVED_
        io = @byte_upstream_reference.TO_REWOUND_SHAREABLE_LINE_UPSTREAM_EXPERIMENT

        begin
          @line = io.gets
          @line || break
          @lineno += 1
          if BLANK_LINE_OR_COMMENT_RX_ =~ @line
            redo
          end
          ok = send @state_symbol
        end while ok

        ok && remove_instance_variable( :@document )
      end

      def when_before_section_
        md = SECTION_RX__.match @line
        if md
          _accept_section md
        else
          _receive_error_symbol :section_expected
        end
      end

      _NAME_RX = '[-A-Za-z0-9.]+'

      SECTION_RX__ = /\A[ ]*\[[ ]*
       (?<name>#{ _NAME_RX })
        (?:[ ]+"(?<subsect>(?:[^\n"\\]+|\\["\\])+)")?[ ]*\][ ]*\r?\n?\z/x

      def when_section_or_assignment_

        md = ASSIGNMENT_LINE_RX__.match @line
        if md
          __accept_assignment md
        else
          md = SECTION_RX__.match @line
          if md
            _accept_section md
          else
            _receive_error_symbol :assignment_or_section_expected
          end
        end
      end

      ASSIGNMENT_LINE_RX__ = /\A[ ]*
        (?<name>[a-zA-Z][-a-zA-Z0-9]*)[ ]*
        (?:=[ ]*(?<unparsed_value>[^\r\n]*))?
      \r?\n?/x

      def __accept_assignment md

        _asmt = Assignment_.new( * md.captures, & @listener )

        @sect.assignments.__accept_assignment_ _asmt
        ACHIEVED_
      end

      def _accept_section md
        ss = md[ :subsect ]
        if ss
          Section_::Mutate_subsection_name_for_UNmarshal[ ss ]
        end
        @sect = Section_.new md[ :name ], ss
        @document.sections.accept_section_as_sections__ @sect
        @state_symbol = :when_section_or_assignment_
        ACHIEVED_
      end

      def _receive_error_symbol sym
        receive_error_symbol_and_column_number_ sym, @column_number   # col num nil OK
      end
    end

    BLANK_LINE_OR_COMMENT_RX_ = /\A[ ]*(?:\r?\n?\z|[#;])/

    class CommonDocumentParse_   # re-open. #testpoint

      def upstream_path= path
        @byte_upstream_reference = _BUR.via_path path
        path
      end

      def upstream_string= s
        @byte_upstream_reference = _BUR.via_string s
        s
      end

      def upstream_IO= io  # [tm]
        @byte_upstream_reference = _BUR.via_open_IO io
        io
      end

      def byte_upstream_reference= bur
        @byte_upstream_reference = bur  # hi.
      end

      def _BUR
        Byte_upstream_reference_[]
      end

      attr_writer(
        :listener,
      )

      def execute
        init_for_parse_
        execute_parse_
      end

      def init_for_parse_

        @column_number = nil
        @lineno = 0
        @state_symbol = :when_before_section_
        init_appropriate_document_instance_
      end

      def receive_error_symbol_and_column_number_ sym, col_number

        @listener.call :error, :config_parse_error do
          __build_config_parse_error sym, col_number
        end

        UNABLE_
      end

      def __build_config_parse_error sym, col_number

        col_number ||= @column_number || 1

        Common_::Event.inline_not_OK_with(
          :config_parse_error,
          :column_number, col_number,
          :lineno, @lineno,
          :line, @line,
          :parse_error_category_symbol, sym,
          :reason, sym.id2name.gsub( UNDERSCORE_, SPACE_ ),
          :byte_upstream_reference, @byte_upstream_reference,

        ) do |y, o|

          _s = o.byte_upstream_reference.description_under self

          y << "#{ o.reason } in #{ _s }:#{ o.lineno }:#{ o.column_number }"

          s = "#{ o.lineno }:"
          fmt = "  %#{ s.length }s %s"

          y << fmt % [ s, o.line ]
          y << fmt % [ nil, "#{ SPACE_ * ( o.column_number - 1 ) }^" ]

        end
      end

      def listener
        @listener  # hi.
      end
    end

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
        with_document nil do |doc|
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

      with_document p do |doc|
        Here_::Magnetics::RetrieveEntity_via_EntityIdentifier_and_Document[ id, doc, @kernel, p ]
      end
    end

    # ~ retrieve (many)

    def to_entity_stream_via_model cls, & p

      with_document p do |doc|
        Here_::Magnetics::EntityStream_via_Collection[ cls, doc, @kernel, & p ]
      end
    end

    def to_section_stream & p

      with_document p do |doc|
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

      with_document p do |doc|

        x = doc.sections[ sym ]

        if x
          x.subsection_string
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

      Here_::Mutable::Magnetics::WriteDocument_via_Collection.call_by do |o|

        o.is_dry = bx[ :dry_run ]
        o.line_upstream = doc.to_line_stream
        o.path = doc.byte_upstream_reference.to_path
        o.listener = p
      end
      # always succeeds. failure is impossible
    end

    # --

    def with_mutable_document listener, & do_this  # [tm]

      send @_with_mutable_doc, listener, & do_this
    end

    def with_document listener, & do_this

      send @_with_immutable_doc, listener, & do_this
    end

    def _with_mutable_doc_as_is _listener
      yield @_mutable_doc_instance
    end

    def __with_immutable_doc_as_is _listener
      yield @_immutable_doc_instance
    end

    def __with_mutable_doc_via_immutable_doc_initially listener, & do_this

      _idoc = remove_instance_variable :@_immutable_doc_instance
      listener ||= @listener

      _bur = _idoc.byte_upstream_reference

      mdoc = Here_::Mutable.parse_document_by do |o|
        o.byte_upstream_reference = _bur
        o.listener = listener
      end

      if mdoc
        _receive_mutable_document mdoc
        send @_with_mutable_doc, listener, & do_this
      else
        # ..
        remove_instance_variable :@_with_mutable_doc
        remove_instance_variable :@_with_immutable_doc
        @_has_document = false
        freeze
        mdoc
      end
    end

    # ~

    def _receive_mutable_document doc

      @_with_mutable_doc = :_with_mutable_doc_as_is
      @_with_immutable_doc = :_with_mutable_doc_as_is
      @_mutable_doc_instance = doc ; nil
    end

    def __receive_immutable_document doc

      @_with_mutable_doc = :__with_mutable_doc_via_immutable_doc_initially
      @_with_immutable_doc = :__with_immutable_doc_as_is
      @_immutable_doc_instance = doc ; nil
    end

    # ==

    class Document___

      def initialize byte_upstream_reference
        @byte_upstream_reference = byte_upstream_reference
        @sections = Sections___.new
      end

      def description_under expag
        @byte_upstream_reference.description_under expag
      end

      def to_section_stream
        @sections.to_stream_of_sections
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
        @_elements_ = []
        @_offset_via_symbol_ = {}
      end

      def length
        @_elements_.length
      end

      def first
        @_elements_.first
      end

      def lookup_softly k  # [cu]
        d = @_offset_via_symbol_[ k ]
        if d
          @_elements_.fetch d
        end
      end

      def dereference k
        _d = @_offset_via_symbol_.fetch k
        @_elements_.fetch _d
      end

      def _to_stream_of_elements_

        Stream_[ @_elements_ ]
      end

      def each_pair
        @_elements_.each do |ast|
          :assignment == ast.nonterminal_symbol or next
          yield ast.external_normal_name_symbol, ast.value_x
        end
      end

      def map & p
        @_elements_.map( & p )
      end
    end

    class Sections___ < Box__

      def accept_section_as_sections__ sect
        @_offset_via_symbol_[ sect.external_normal_name_symbol ] = @_elements_.length
        @_elements_.push sect
        NIL
      end

      alias_method :to_stream_of_sections, :_to_stream_of_elements_
    end

    class Section_

      def initialize name_s, subsect_name_s

        @external_normal_name_symbol = name_s.downcase.gsub( DASH_, UNDERSCORE_ ).intern
        @internal_normal_name_string = name_s.freeze
        @subsection_string = ( subsect_name_s.freeze if subsect_name_s )
        @assignments = Assignments__.new
      end

      attr_reader(
        :assignments,
        :external_normal_name_symbol,  # (and the next) explained at [#008.H]
        :internal_normal_name_string,
        :subsection_string,
      )

      Mutate_subsection_name_for_marshal = -> s do
        s.gsub! BACKSLASH_, BACKSLASH_BACKSLASH_  # do this first
        s.gsub! QUOTE_, BACKSLASH_QUOTE_ ; nil
      end

      Mutate_subsection_name_for_UNmarshal = -> s do
        s.gsub! BACKSLASH_QUOTE_, QUOTE_
        s.gsub! BACKSLASH_BACKSLASH_, BACKSLASH_ ; nil
      end
    end

    class Assignments__ < Box__

      def __accept_assignment_ asmt

        @_offset_via_symbol_[ asmt.external_normal_name_symbol ] = @_elements_.length
        @_elements_.push asmt
        NIL
      end

      # #TODO - #history-A. our implementation of `[]` violated completely
      # the "principle of least surprise" ...
      #
      # after we shake the demons out, restore `[]` to work as expected
      # or we're doing it now.. :#here1

      def dereference sym

        d = @_offset_via_symbol_[ sym ]
        if d
          @_elements_.fetch( d ).value_x
        else
          raise ::NameError, "no such assignment '#{ sym }'"
        end
      end

      def lookup_softly sym

        d = @_offset_via_symbol_[ sym ]
        if d
          @_elements_.fetch( d ).value_x
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
        last = @_elements_.length - 1

        Common_.stream do

          if d < last
            d += 1
            ast = @_elements_.fetch d
            Common_::Pair.via_value_and_name(
              ast.value_x,
              ast.external_normal_name_symbol )
          end
        end
      end

      alias_method :to_stream_of_assignments, :_to_stream_of_elements_
    end

    class Assignment_

      def initialize name_s, marshaled_s, & p
        @internal_normal_name_string = name_s
        @_marshaled_string = marshaled_s
        @did_unmarshal = false
        @listener = p
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
        marshaled_s = @_marshaled_string
        if Q__ == marshaled_s.getbyte( 0 )
          unmarshal_quoted_string
        elsif (( @md = INTEGER_RX__.match marshaled_s ))
          @value_x = @md[ 0 ].to_i
        elsif TRUE_RX__ =~ marshaled_s
          @value_x = true
        elsif FALSE_RX__ =~ marshaled_s
          @value_x = false
        else
          @md = ALL_OTHERS_RX__.match marshaled_s
          @md or fail "sanity: #{ marshaled_s.inspect }"
          s = @md[ 0 ]
          if Mutate_value_string_for_UNmarshal[ s, & @listener ]
            @value_x = s
          end
        end
        NIL
      end
      Q__ = '"'.getbyte 0
      _REST_OF_LINE_ = '(?=[ ]*(?:[;#]|\z))'
      INTEGER_RX__ = /\A-?[0-9]+#{ _REST_OF_LINE_ }/
      TRUE_RX__ = /\A(?:yes|true|on)#{ _REST_OF_LINE_ }/i
      FALSE_RX__ = /\A(?:no|false|off)#{ _REST_OF_LINE_ }/i
      ALL_OTHERS_RX__ = /\A[^ ;#]+(?:[ ]+[^ ;#]+)*#{ _REST_OF_LINE_ }/i

      def unmarshal_quoted_string
        @md = QUOTED_STRING_RX__.match @_marshaled_string
        @md or raise ParseError, "huh? #{ @_marshaled_string.inspect }"
        s = @md[ 0 ]
        if Mutate_value_string_for_UNmarshal[ s, & @listener ]
          @value_x = s
        end
        nil
      end

      QUOTED_STRING_RX__ = /(?<=\A")(?:\\"|[^"])*(?="[ ]*(?:[;#]|\z))/

      Mutate_value_string_for_marshal = -> s do  # 1x

        # this logic is lifted term-by-term from the git config manpage

        _quotes_are_necessary = QUOTES_ARE_NECESSARY_RX__ =~ s

        s.gsub! ESCAPE_THESE_SOMEOHOW_RX__ do
          ESCAPE_STRATEGY_MAP__.fetch( $~[ 0 ].getbyte( 0 ) )[ $~[ 0 ] ]
        end

        if _quotes_are_necessary
          s[ 0, 0 ] = '"'
          s[ s.length ] = '"'
        end

        NIL
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

      Mutate_value_string_for_UNmarshal = -> string, & listener do

        ok = ACHIEVED_

        string.gsub! UNESCAPE_THESE_SOMEHOW_RX__ do

          s = $~[ 1 ]  # is empty string IFF backslash was at end of line

          p = UNESCAPE_STRATEGY_MAP__[ s.getbyte 0 ]
          if p
            _otr = p[ s ]
            _otr  # hi. #todo
          else

            listener.call :error, :invalid_escape_sequence do
              self.__TODO_build_invalid_escape_sequence_event $~[ 0 ]
            end

            ok = UNABLE_
            s  # put the string "back in" as-is
          end
        end
        ok
      end

        UNESCAPE_THESE_SOMEHOW_RX__ = /\\(.?)/

        UNESCAPE_STRATEGY_MAP__ = {
          '"'.getbyte( 0 ) => IDENTITY_,
          '\\'.getbyte( 0 ) => IDENTITY_,
          'n'.getbyte( 0 ) => -> _ { "\n" },
          't'.getbyte( 0 ) => -> _ { "\t" },
          'b'.getbyte( 0 ) => -> _ { "\b" }
        }

      attr_reader(
        :internal_normal_name_string,
        :_marshaled_string,
      )

      def nonterminal_symbol
        :assignment
      end
    end

    # ==

    LISTENER_THAT_RAISES_ALL_NON_INFO_EMISSIONS_ = -> sym, *_, & ev_p do
      if :info != sym
        _ev = ev_p[]
        _e = _ev.to_exception
        raise _e
      end
    end

    # ==

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
# :#history-A: (can be temporary) as referenced
