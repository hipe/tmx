module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    class Strategies___::Row_First_Receiver

      Models__ = ::Module.new

      class Models__::Content_Matrix

        # implements the minimum styling necessary to do etc.

        def initialize_dup _

          # this structure stateful but purely reactive.
          # nothing is initialized and no state carries over.

          instance_variables.each do | ivar |
            remove_instance_variable ivar
          end
        end

        def downstream_yielder_x
          @_downstream_yielder_x
        end

        def receive_downstream_element ctx

          @_downstream_yielder_x = ctx
          @_column_widths = ::Hash.new 0
          @_s_a_a = []
          KEEP_PARSING_
        end

        def get_column_widths
          @_column_widths.dup
        end

        def receive_user_row x_a

          session_for_adding_content_row do

            x_a.each_with_index( &

              method( :for_current_content_row_receive_user_datapoint ) )
           end
        end

        def session_for_adding_content_row

          @_current_content_row = []
          yield self
          @_s_a_a.push remove_instance_variable :@_current_content_row
          KEEP_PARSING_
        end

        def for_current_content_row_receive_user_datapoint x, d

          s = x.to_s
          w = @_column_widths[ d ]
          w_ = s.length
          if w < w_
            @_column_widths[ d ] = w_
          end
          @_current_content_row[ d ] = s
          NIL_
        end

        def receive_table

          __init_celifiers
          __express_each_row
        end

        def __init_celifiers

          p_h = {}
          @_column_widths.each_pair do | d, w |

            fmt = "%-#{ w }s"  # [#096.F] the default is left
            p_h[ d ] = -> s do
              fmt % s
            end
          end
          @_celifiers = p_h
          ACHIEVED_
        end

        def __express_each_row

          accept( & method( :__celify_and_flush_content_row ) )

          ACHIEVED_
        end

        def accept & visit

          kp = KEEP_PARSING_
          @_s_a_a.each do | s_a |

            kp = visit[ s_a ]
            kp or break
          end
          kp
        end

        def __celify_and_flush_content_row s_a

          _s_a_ = s_a.each_with_index.map do | s, d |
            @_celifiers.fetch( d ).call s
          end

          @_downstream_yielder_x <<
            "#{ LEFT_GLYPH_ }#{ _s_a_ * SEP_GLYPH_ }#{ RIGHT_GLYPH_ }"

          ACHIEVED_
        end
      end
    end
  end
end
