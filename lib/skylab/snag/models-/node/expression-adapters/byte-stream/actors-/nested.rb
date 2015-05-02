module Skylab::Snag

  class Models_::Node

    module Expression_Adapters::Byte_Stream

      class Actors_::Nested

        class << self

          def [] * a
            new( a ).execute
          end
        end  # >>

        def initialize a
          @open_d, @deep_pc, @string_pc, @hashtag_st, @row_st = a
        end

        def execute

          @_scn = @hashtag_st.string_scanner

          d = @_scn.skip OPEN_DOUBLE_QUOTE___
          if d
            self._HAVE_FUN_PARSING_QUOTES
          else

            _d = @_scn.skip CLOSE_PAREN__
            __common do
              if _d
                __one_line_paren_expression
              else
                __multi_line_paren_expression
              end
            end
          end
        end

        def __multi_line_paren_expression

          # we are going to grow the tag piece's string beyond what was
          # in the upstream string so we need a mutable dup of it

          tag = @deep_pc
          tag._string = tag._string.dup

          reinit_my_scn = -> s do
            @_my_scn = @_scn.class.new s
            reinit_my_scn = -> s_ do
              @_my_scn.string = s_
              NIL_
            end
            NIL_
          end

          begin

            row = @row_st.gets

            if ! row
              __finish_unended_paren_expression
              break
            end

            reinit_my_scn[ row.s ]

            _d = @_my_scn.skip CLOSE_PAREN__
            if _d
              __finish_ended_paren_expression
              break
            end

            tag._string.concat row.s

            redo
          end while nil
          NIL_
        end

        def __finish_ended_paren_expression

          scn = @_my_scn

          @_close_paren_pos = scn.pos

          _d = scn.skip EOL___
          if _d
            @deep_pc._string.concat scn.string
            _finish_deep_pc_as_is
          else
            @deep_pc._string.concat scn.string[ 0, scn.pos ]
            _finish_deep_pc_as_is

            @string_scanner = scn
          end
          NIL_
        end

        def __finish_unended_paren_expression

          self._VERIFY_ME

          @_close_paren_pos = @_my_scn.string.length
          _finish_deep_pc_as_is
        end

        def _finish_deep_pc_as_is

          len = @deep_pc._string.length

          @deep_pc._length = len

          @deep_pc._value_r = @deep_pc._name_r.end + 1  ... len - 1

          NIL_
        end

        def __one_line_paren_expression

          # extend the deep piece's length so it ends with the close paren

          @deep_pc._length = @_scn.pos - @open_d

          # change the deep piece's value range to have everything from
          # after the open colon to before the close paren

          @deep_pc._value_r = @deep_pc._name_r.end + 1 ... @_scn.pos - 1

          NIL_
        end

        def __common

          # the received string piece is what would have gone out if we
          # didn't engage this extension. mutate the string piece so
          # it does not include the open paren:

          @string_pc._length = @open_d - @string_pc._begin

          # mutate the "deep piece" so that it begins with the open paren

          @deep_pc._begin = @open_d

          # (note the deep piece's name string range stays the same)

          yield

          if @string_pc._length.zero?

            # in cases where the mutated string piece ends up with no
            # content of its own, skip over it and produce deep pc now

            @piece = @deep_pc
          else

            # otherwise, result in this mutated string piece now and the
            # deep piece next

            @next_piece = @deep_pc
            @piece = @string_pc
          end

          self
        end

        attr_reader :next_piece, :piece, :string_scanner

        CLOSE_PAREN__ = /[^)]*\)/

        EOL___ = /$/

        OPEN_DOUBLE_QUOTE___ = /[^)"]*"/

        Parens = ::Class.new self
      end
    end
  end
end
