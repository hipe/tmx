module Skylab::GitViz

  module Test_Lib_

    module Mock_Sys

      Input_Adapters_ = ::Module.new

      class Input_Adapters_::OGDL

        class << self

          def tree_stream_from_lines lines
            new( lines ).execute
          end

          private :new
        end  # >>

        def initialize lines
          @lines = lines
          @scn = GitViz_.lib_.string_scanner.new EMPTY_S_
          @stack = [ Frame__.new( 0, Root_Node___.new ) ]
        end

        def execute
          Callback_.stream do
            __gets
          end
        end

        def __gets

          if _resolve_next_nonblank_noncomment_line
            __gets_when_at_least_one_line
          end
        end

        def __gets_when_at_least_one_line

          1 == @stack.length or self._SANITY

          frame = @stack.last

          begin
            d = @scn.skip INDENT__
            case frame.margin_count <=> d
            when 0
              frame = _process_line

            when -1
              frame = __push d

            when 1
              frame = __pop d

              if 1 == @stack.length

                # this is the part that makes us streaming: break as soon
                # as you have completed a level-one object

                stopped_early = true

                break
              end
            else
              self._SANITY
            end

            _yes = _resolve_next_nonblank_noncomment_line
            _yes or break
            redo
          end while nil

          frame and begin

            a = @stack.first.node.children

            # the number of children that the root node has should always
            # be either one or two based on whether there is more than one
            # object in the stream. when two, keep the stack where it is:
            # we have just started parsing the next object

            if stopped_early
              2 == a.length or self._SANITY
              x = a.shift
            else
              1 == a.length or self._SANITY
              x = a.shift
              @stack[ 1 .. -1 ] = EMPTY_A_
            end
            x
          end
        end

        EMPTY_S_ = ''.freeze

        def __push d

          new_frame = Frame__.new d, @stack.last.node.children.last
          @stack.push new_frame

          _process_line
        end

        def __pop d

          begin
            @stack.pop
            frm = @stack.last
            case frm.margin_count <=> d
            when 0

              # margin counts signify the indent of that frame's node's
              # children; so if this is your indent, frame is your parent

              x = _process_line
              break

            when -1

              # you are deeper than it ..

              self._HOLE

            when 1

              # you are shallower than it, pop another one off the stack

              redo

            else
              self._SANITY
            end

          end while nil
          x
        end

        def _process_line

          _d = @scn.skip OPEN_PAREN__
          _d and self._PARENS_NOT_IMPLEMENTED

          begin

            s = _produce_word
            s or break

            @stack.last.node.accept_child Node__.new s

            _d = @scn.skip COMMA___
            _d and redo

            _d = @scn.skip INDENT__
            if _d.nonzero?
              __build_tree_downwards_in_single_line
            end

            _d = @scn.skip OPEN_PAREN__
            _d and self._PARENS_NOT_IMPLEMENTED

            @scn.skip EOL__

            break
          end while nil

          if @scn.eos?
            @stack.last
          else
            raise "huh? #{ @scn.rest.inspect }"
          end
        end

        COMMA___ = /[ \t]*,[ \t]*/

        OPEN_PAREN__ = /[ \t]*\(/

        def __build_tree_downwards_in_single_line  # don't touch the stack

          local_hero = @stack.last.node.children.last
          begin

            s = _produce_word
            s or break

            new_node = Node__.new s
            local_hero.accept_child new_node

            _d = @scn.skip INDENT__
            _d.zero? and break

            local_hero = new_node

            redo
          end while nil
          NIL_
        end

        def _produce_word
          _d = @scn.skip QUOT__
          if _d
            __produce_word_via_quoted_string
          else
            @scn.scan WORD___
          end
        end

        WORD___ = /[^" ,()\t\r\n]+/

        def __produce_word_via_quoted_string  # result signature is complex

          content = @scn.scan QUOT_CONTENT__
          _mutate_content_by_unescaping content

          _d = @scn.skip QUOT__
          if _d
            content
          else
            __produce_word_via_multiline_string content
          end
        end

        def __produce_word_via_multiline_string content

          a = [ content ]
          fr = @stack.last

          begin

            _yes = _resolve_next_nonblank_noncomment_line
            _yes or raise "end of quote not found"

            s = @scn.scan INDENT__
            if s.length < fr.margin_count
              fr.margin_count = s.length
              use = nil
            else
              use = s[ fr.margin_count .. -1 ]
            end

            content = @scn.scan QUOT_CONTENT__
            _mutate_content_by_unescaping content
            _line = "#{ use }#{ content }"

            a.push _line
            if @scn.skip QUOT__
              @scn.skip INDENT__
              @scn.skip EOL__
              x = a.join EMPTY_S_
              break
            else
              self._MULTILINE_QUOTE_IS_EASY
            end

          end while nil

          x
        end

        def _mutate_content_by_unescaping s

          s.gsub! ESC_RX___ do

            d = $~[ 1 ].getbyte 0

            x = SUPPORTED_ESCAPE_SEQUENCES__[ d ]

            if x
              x
            else
              raise "unsupported escape sequence: \"\\#{ d.chr }"
              # or just: "\\#{ d.chr }"
            end
          end
          NIL_
        end

        ESC_RX___ = /\\(.)/

        SUPPORTED_ESCAPE_SEQUENCES__ = {
          '"'.getbyte( 0 ) => '"',
          'n'.getbyte( 0 ) => "\n",
          "\\".getbyte( 0 ) => "\\"
        }  # etc

        def _resolve_next_nonblank_noncomment_line

          begin
            line = @lines.gets
            if line
              @scn.string = line

              _d = @scn.skip COMMENT_LINE_BEGINNING_OR_BLANK_LINE___
              if _d
                redo
              else
                x = ACHIEVED_
              end
            else
              @scn = nil
            end
            break
          end while nil
          x
        end

        COMMENT_LINE_BEGINNING_OR_BLANK_LINE___ = /[ \t]*(?:#|$)/

        Frame__ = ::Struct.new :margin_count, :node

        class Root_Node___

          attr_reader :children

          def accept_child x

            @children ||= []
            @children.push x
            NIL_
          end
        end

        class Node__ < Root_Node___
          def initialize s
            @string = s
          end
          attr_reader :string
        end

        EOL__ = /\r?\n/

        INDENT__ = /[ \t]*/  # if this is not also space, look

        QUOT__ = /["]/

        QUOT_CONTENT__ = /(?:[^\\"]+|\\.)*/

        STAY_ = true
      end
    end
  end
end
