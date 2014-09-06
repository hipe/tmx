module Skylab::TanMan

  class Models_::Comment

    def self.get_unbound_upper_action_scan
      nil
    end

    module Line_Scan

      class << self

        def of_comment_string str
          Of_comment_string__[ str ]
        end

        def of_string str
          Of_string__[ str ]
        end
      end

      module Of_string__

        def self.[] str
          scn = TanMan_::Lib_::String_scanner[].new str
          Callback_::Scan.new do
            if ! scn.eos?
              s = scn.scan CONTENT_RX__
              scn.skip NEWLINE_RX_
            end
            s
          end
        end

        CONTENT_RX__ = /[^\r\n]*/
      end

      module Of_comment_string__

        def self.[] str
          scn = TanMan_::Lib_::String_scanner[].new str
          scn.skip SPACE_RX__
          if scn.skip C_STYLE_COMMENT_OPENER_RX__
            type_i = :C_Style__
          elsif scn.skip SHELL_STYLE_COMMENT_OPENER_RX__
            type_i = :Shell_Style__
          end
          if type_i
            _cls = Line_Scan.const_get type_i, false
            _cls.new scn
          end
        end
        SPACE_RX__ = /[[:space:]]+/
        C_STYLE_COMMENT_OPENER_RX__ = /\/\*/
        SHELL_STYLE_COMMENT_OPENER_RX__ = /#/
      end

      module C_Style__

        def self.new scn
          Callback_::Scan.new do
            while scn and ! scn.eos?
              s = scn.scan CONTENT_RX__
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

      module Shell_Style__

        def self.new scn
          scn.skip OPEN_RX__
          Callback_::Scan.new do
            while true
              scn or break
              s = scn.scan CONTENT_RX__
              if ! s
                break( scn = nil )
              end
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
        OPEN_RX__ = /[[:space:]]*#/
        CONTENT_RX__ = /[^\r\n]*/
        LINE_OPEN_RX__ = /[ \t]*#/
        BLANK_LINES_RX__ = /([ \t]*\r?\n)+/
      end

      NEWLINE_RX_ = /\r?\n/
    end
  end
end
