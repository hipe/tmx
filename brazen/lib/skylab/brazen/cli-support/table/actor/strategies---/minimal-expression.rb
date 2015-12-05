module Skylab::Brazen

  class CLI_Support::Table::Actor

    class Strategies___::Minimal_Expression

      ROLES = [
        :downstream_context_receiver,
        :field_normalizer,
        :user_data_upstream_receiver
      ]

      SUBSCRIPTIONS = nil

      def initialize x
        @parent = x
      end

      def dup( * )

        # across the dup boundary, the duped parent will re-create its own
        # copy of the subject node as needed. there is no significant state
        # to carry over.

        NIL_
      end

      def receive_downstream_context ctx
        @_down_o = ctx
        NIL_
      end

      def receive_user_data_upstream st

        @_am = Table_Impl_::Models_::Argument_Matrix.new
        @_up = st

        if @_up.no_unparsed_exists
          __when_no_rows
        else
          __when_at_least_one_row
        end
      end

      def receive_normalize_fields
        KEEP_PARSING_
      end

      def __when_no_rows
        EMPTY_S_  # as covered
      end

      def __when_at_least_one_row

        # a ball-of-mud synopsis of the general algorithm of this whole
        # lib (explained obliquely at [#096.J]):

        am = @_am
        maxes = ::Hash.new 0
        row_x = @_up.gets_one

        begin
          am.begin_row
          row_x.each_with_index do | x, d |

            s = x.to_s
            w = s.length
            if maxes[ d ] < w
              maxes[ d ] = w
            end
            am.accept_argument s, d
          end
          am.finish_row
          if @_up.no_unparsed_exists
            break
          end
          row_x = @_up.gets_one
          redo
        end while nil

        celifiers = {}
        maxes.each_pair do | d, w |
          fmt = "%-#{ w }s"  # [#096.F] the default is to align left
          celifiers[ d ] = -> s do
            fmt % s
          end
        end

        am.accept_by do | row_s_a |

          _s_a = row_s_a.each_with_index.map do | s, d |
            celifiers.fetch( d )[ s ]
          end

          @_down_o << "#{ LEFT_GLYPH_ }#{ _s_a * SEP_GLYPH_ }#{ RIGHT_GLYPH_ }"
        end

        @_down_o.appropriate_result
      end
    end
  end
end
