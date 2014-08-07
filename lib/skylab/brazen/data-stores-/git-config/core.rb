module Skylab::Brazen

  module Data_Stores_::Git_Config

    class << self
      def parse_string str
        Parse_Context__.new.with_input( String_Input_Adapter__, str ).parse
      end
    end

    class Parse_Context__
      def with_input adapter_cls, x
        @lines = adapter_cls.new x
        self
      end

      def parse
        prepare_for_parse
        while @line = @lines.gets
          if BLANK_LINE_OR_COMMENT_RX__ =~ @line
          else
            send @state_i
          end
        end
        @document
      end

      BLANK_LINE_OR_COMMENT_RX__ = /\A[ ]*(?:\z|[#;])/

      def prepare_for_parse
        @document = Document__.new
        @state_i = :when_before_section
      end
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
    end
  end
end
