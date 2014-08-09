module Skylab::Brazen

  module Data_Stores_::Git_Config

    class << self
      def parse_string str, & p
        Parse_Context_.new( p ).
          with_input( String_Input_Adapter_, str ).parse
      end
    end

    ParseError = ::Class.new ::RuntimeError

    class Parse_Context_

      def initialize p
        @parse_error_handler_p = p
      end

      def with_input adapter_cls, x
        @line_number = 0
        @lines = adapter_cls.new x
        self
      end

      def parse
        prepare_for_parse
        while @line = @lines.gets
          @line_number += 1
          if BLANK_LINE_OR_COMMENT_RX_ =~ @line
          else
            send @state_i or break
          end
        end
        @document
      end
      BLANK_LINE_OR_COMMENT_RX_ = /\A[ ]*(?:\r?\n?\z|[#;])/

      # ~ support is coming first before business b.c possible future fission

    private
      def error_event i, col_number=nil
        d = ( col_number or @column_number ||= 1 )
        x_a = [ i, :line_number, @line_number, :column_number, d, :line, @line ]
        ev = Brazen_::Entity::Event.new x_a, -> y, o do
          y << "#{ i.to_s.gsub( UNDERSCORE_, SPACE_ ) } #{
           }(#{ o.line_number }:#{ o.column_number })"
        end
        if @parse_error_handler_p
          @document = @parse_error_handler_p[ ev ]
          CEASE_
        else
          raise ParseError, ev.
            render_first_line_under( Brazen_::API::EXPRESSION_AGENT )
        end
      end

      # ~ business

      def prepare_for_parse
        @did_error = false
        @document = Document_.new
        @state_i = :when_before_section
      end

      # ~

      def when_before_section
        @md = SECTION_RX__.match @line
        if @md
          accpt_section
        else
          whn_not_section
        end
      end
      _NAME_RX = '[-A-Za-z0-9.]+'
      SECTION_RX__ = /\A[ ]*\[[ ]*
       (?<name>#{ _NAME_RX })
        (?:[ ]+"(?<subsect>(?:[^\n"\\]+|\\["\\])+)")?[ ]*\][ ]*\r?\n?\z/x

      def accpt_section
        if (( ss = @md[ :subsect ] ))
          self.class.unescape_two_escape_sequences ss
        end
        @sect = Section__.new @md[ :name ], ss
        @document.sections.accept_sect @sect
        @state_i = :when_section_or_assignment
        PROCEDE_
      end

      def self.unescape_two_escape_sequences s
        s.gsub! BACKSLASH_QUOTE_, QUOTE_
        s.gsub! BACKSLASH_BACKSLASH_, BACKSLASH_ ; nil
      end

      def whn_not_section
        error_event :section_expected
      end

      # ~

      def when_section_or_assignment
        if (( @md = ASSIGNMENT_LINE_RX__.match @line ))
          accpt_assignment
        elsif (( @md = SECTION_RX__.match @line ))
          accpt_section
        else
          error_event :assignment_or_section_expected
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

    class String_Input_Adapter_
      def initialize str
        @scn = Lib_::String_scanner[].new str
      end

      def gets
        @scn.scan RX__
      end

      RX__ = /[^\r\n]*\r?\n|[^\r\n]+/
    end

    module Lib_
      memoize = -> p { p_ = -> { x = p[] ; p_ = -> { x } ; x } ; -> { p_[] } }

      String_scanner = memoize[ -> do
        require 'strscan' ; ::StringScanner
      end ]
    end

    class Document_
      def initialize
        @sections = Sections__.new
      end
      attr_reader :sections
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

    class Section__

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
    end

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

      def self.unescape_quoted_value_string s
        s.gsub! BACKSLASH_QUOTE_, QUOTE_
        s.gsub! BACKSLASH_N__, NEWLINE__
        s.gsub! BACKSLASH_T__, TAB__
        s.gsub! BACKSLASH_B__, BACKSPACE__
        s.gsub! BACKSLASH_BACKSLASH_, BACKSLASH_  # do this last, else etc
      end
      BACKSLASH_N__ = '\n'.freeze ; NEWLINE__ = "\n".freeze
      BACKSLASH_T__ = '\t'.freeze ; TAB__ = "\t".freeze
      BACKSLASH_B__ = '\b'.freeze ; BACKSPACE__ = "\b".freeze
    end

    BACKSLASH_ = '\\'.freeze
    BACKSLASH_BACKSLASH_ = '\\\\'.freeze
    BACKSLASH_QUOTE_ = '\\"'.freeze
    CEASE_ = false
    PROCEDE_ = true
    QUOTE_= '"'.freeze

  end
end
