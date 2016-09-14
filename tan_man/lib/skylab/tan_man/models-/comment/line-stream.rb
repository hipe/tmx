module Skylab::TanMan

  class Models_::Comment

    Actions = ::Module.new

    module Line_Stream

      class << self

        def of_mystery_string str
          if SHELL_STYLE_OPEN_COMMENT_RX___ =~ str
            of_comment_string str
          elsif C_STYLE_OPEN_COMMENT_RX_ =~ str
            of_comment_string str
          else
            of_string str
          end
        end

        def of_comment_string str
          Of_comment_string__[ str ]
        end

        def of_string str
          Of_string__[ str ]
        end
      end

      module Of_string__

        def self.[] str
          scn = Home_.lib_.string_scanner.new str
          scan = Stream__.new scn do
            if ! scn.eos?
              scan.last_start_position = scn.pos
              s = scn.scan CONTENT_RX__
              scan.last_end_position = scn.pos
              scn.skip NEWLINE_RX_
            end
            s
          end
        end

        CONTENT_RX__ = /[^\r\n]*/
      end

      module Of_comment_string__

        def self.[] str
          scn = Home_.lib_.string_scanner.new str
          scn.skip SPACE_RX__
          type = if scn.skip C_STYLE_COMMENT_OPENER_RX__
            :C_Style__
          elsif scn.skip SHELL_STYLE_COMMENT_OPENER_RX__
            :Shell_Style__
          end
          if type
            Line_Stream.const_get( type, false ).new scn
          end
        end
        SPACE_RX__ = /[[:space:]]+/
        C_STYLE_COMMENT_OPENER_RX__ = /\/\*/
        SHELL_STYLE_COMMENT_OPENER_RX__ = /#/
      end

      module C_Style__

        def self.new scn
          scan = Stream__.new scn do
            while scn and ! scn.eos?
              scan.last_start_position = scn.pos
              s = scn.scan CONTENT_RX__
              if s
                scan.last_end_position = scn.pos
              end
              if scn.match? END_RX__
                scn = nil
                break
              end
              scn.skip NEWLINE_RX_
              s and break
            end
            s
          end
        end
        CONTENT_RX__ = /((?!\*\/)[^\r\n])*/
        END_RX__ = /\*\//
      end

      SHELL_OPEN_RX__ = /[[:space:]]*#/

      SHELL_STYLE_OPEN_COMMENT_RX___ = %r(\A#{ SHELL_OPEN_RX__.source })

      module Shell_Style__

        def self.new scn
          scn.skip SHELL_OPEN_RX__
          scan = Stream__.new scn do
            while true
              scn or break
              scan.last_start_position = scn.pos
              s = scn.scan CONTENT_RX__
              if ! s
                break( scn = nil )
              end
              scan.last_end_position = scn.pos
              if ! scn.skip( NEWLINE_RX_ )
                break( scn = nil )
              end
              scn.skip BLANK_LINES_RX__
              if ! scn.skip( LINE_OPEN_RX__ )
                break( scn = nil )
              end
              break
            end
            s
          end
        end
        CONTENT_RX__ = /[^\r\n]*/
        LINE_OPEN_RX__ = /[ \t]*#/
        BLANK_LINES_RX__ = /([ \t]*\r?\n)+/
      end

      class Stream__ < Common_::Stream

        def initialize scn=nil, & p
          @last_start_position = @last_end_position = nil
          @parent_stream = nil
          @string_scanner = scn
          super( & p )
        end

        def members
          [ :last_end_position, :last_start_position, :source_string ]
        end

        attr_writer :parent_stream, :last_start_position, :last_end_position

        def source_string
          @string_scanner ? @string_scanner.string :
            @parent_stream.source_string
        end

        def last_start_position
          @last_start_position || @parent_stream.last_start_position
        end

        def last_end_position
          @last_end_position || @parent_stream.last_end_position
        end
      end

      C_STYLE_OPEN_COMMENT_RX_ = /\A[[:space:]]*\/\*/

      NEWLINE_RX_ = /\r?\n/
    end
  end
end
