module Skylab::TestSupport

  class Tree_Runner

    class Plugins__::Divide_The_Sidesystems < Plugin_

      does :flush_the_sidesystem_tree do | st |

        st.transition_is_effected_by do | o |

          o.on '--divide N', "output the sidesystems into N smaller systems" do | s |
            @N = s
          end

        end
      end

      def initialize( * )
        super
        @N = nil
      end

      def do__flush_the_sidesystem_tree__
        ok = __normalize_number
        ok &&= __resolve_SS_box
        ok && __via_SS_box
      end

      def __normalize_number

        _arg = Callback_::Qualified_Knownness.via_value_and_variegated_symbol @N, :number

        ok_arg = Lib_::Basic[]::Number.normalization.with(
          :argument, _arg,
          :minimum, 1,
          & @on_event_selectively )

        ok_arg and begin
          @d = ok_arg.value_x
          ACHIEVED_
        end
      end

      def __resolve_SS_box
        @bx = @on_event_selectively.call :for_plugin, :sidesystem_box
        @bx && ACHIEVED_
      end

      def __via_SS_box

        _s = @on_event_selectively.call :for_plugin, :program_name
        @head_s = "#{ _s } "

        @num_pieces = @bx.length

        if @d > @num_pieces
          __when_too_big
        else
          _via_OK_count
        end
      end

      def __when_too_big

        d = @d ; num_pieces = @num_pieces

        @on_event_selectively.call :info, :expression do | y |

          y << "#{ ick d } is larger than the number of pieces #{
            }(#{ num_pieces }) - reducing the count to that number"

        end

        @d = @num_pieces
        _via_OK_count
      end

      def _via_OK_count

        lesser_chunk_size = @num_pieces / @d
        num_chunks_with_the_greater_chunk_size = @num_pieces % @d
        num_chunks_with_the_lesser_chunk_size = @d - num_chunks_with_the_greater_chunk_size

        num_chunks_with_the_lesser_chunk_size.times do | d |
          _express_chunk d * lesser_chunk_size, lesser_chunk_size
        end

        greater_chunk_size = lesser_chunk_size + 1
        offset = num_chunks_with_the_lesser_chunk_size * lesser_chunk_size

        num_chunks_with_the_greater_chunk_size.times do | d |
          _express_chunk offset + ( d * greater_chunk_size ), greater_chunk_size
        end

        ACHIEVED_
      end

      def _express_chunk d, d_

        _ = ( d ... ( d + d_ ) ).map do | d__ |
          @bx.at_position( d__ ).stem
        end * SPACE_

        @resources.serr.puts "#{ @head_s }#{ _ }"
      end

    end
  end
end
