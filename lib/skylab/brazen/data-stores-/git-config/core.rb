module Skylab::Brazen

  module Data_Stores_::Git_Config

    class << self
      def parse_string str
        Parse_Context__.new.with_input( String_Input_Adapter__, str ).parse
      end
    end

    ParseError = ::Class.new ::RuntimeError

    class Parse_Context__
      def with_input adapter_cls, x
        @line_number = 0
        @lines = adapter_cls.new x
        @parse_error_handler_p = nil
        self
      end

      def parse
        prepare_for_parse
        while @line = @lines.gets
          @line_number += 1
          if BLANK_LINE_OR_COMMENT_RX__ =~ @line
          else
            send @state_i or break
          end
        end
        @document
      end
      BLANK_LINE_OR_COMMENT_RX__ = /\A[ ]*(?:\r?\n?\z|[#;])/

      # ~ support is coming first before business b.c possible future fission

    private
      def error_event i
        x_a = [ i, :line_number, @line_number, :column_number, 1, :line, @line ]
        ev = Brazen_::Entity::Event.new x_a, -> y, o do
          y << "#{ i.to_s.gsub( UNDERSCORE_, SPACE_ ) } #{
           }(#{ o.line_number }:#{ o.column_number })"
        end
        if @parse_error_handler_p
        else
          raise ParseError, ev.
            render_first_line_under( Brazen_::API::EXPRESSION_AGENT )
        end
      end

      # ~ business

      def prepare_for_parse
        @document = Document__.new
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
        (?:[ ]+"(?<subsect>(?:[^\n"\\]+|\\["\\])+)"[ ]*)?\][ ]*\r?\n?\z/x

      def accpt_section
        if (( ss = @md[ :subsect ] ))
          ss.gsub! BACKSLASH_QUOTE__, QUOTE__
          ss.gsub! BACKSLASH_BACKSLASH__, BACKSLASH__
        end
        @sect = Section__.new @md[ :name ], ss
        @document.sections.accept_sect @sect
        @state_i = :when_section_or_assignment
        PROCEDE__
      end
      BACKSLASH_QUOTE__ = '\\"'.freeze ; QUOTE__ = '"'.freeze
      BACKSLASH_BACKSLASH__ = '\\\\'.freeze ; BACKSLASH__ = '\\'.freeze

      def whn_not_section
        error_event :section_expected
      end

      # ~

      def when_section_or_assignment
        if (( @md = SECTION_RX__.match @line ))
          accpt_section
        else
          error_event :assignment_or_section_expected
        end
      end

      PROCEDE__ = true ; CEASE__ = false
    end

    class String_Input_Adapter__
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

    class Document__
      def initialize
        @sections = Sections__.new
      end
      attr_reader :sections
    end

    class Sections__
      def initialize
        @a = []
      end
      def length
        @a.length
      end
      def first
        @a.first
      end
      def map & p
        @a.map( & p )
      end
      def accept_sect sect
        @a.push sect ; nil
      end
    end

    class Section__

      def initialize name_s, subsect_name_s
        @name_s = name_s.freeze
        @subsect_name_s = ( subsect_name_s.freeze if subsect_name_s )
        @normalized_name_i = @name_s.downcase.intern
      end

      attr_reader :name_s, :subsect_name_s
      attr_reader :normalized_name_i
    end
  end
end
