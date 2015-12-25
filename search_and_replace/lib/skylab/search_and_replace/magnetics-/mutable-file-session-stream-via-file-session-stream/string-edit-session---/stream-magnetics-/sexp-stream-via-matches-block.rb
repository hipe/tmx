module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___

      class Stream_Magnetics_::Sexp_stream_via_matches_block < Callback_::Actor::Dyadic

        # given a [#010] block that has one or more matches, produce a
        # stream of [#012] sexp nodes representing the content with
        # replacements applied.

        def initialize x, s
          @_block = x
          @_the_big_string = s
        end

        def execute

          _ = Match_controller_stream_via_block___[ @_block ]  # assume 1

          st = _.reduce_by do | mc |
            mc.replacement_is_engaged
          end

          mc = st.gets

          if mc
            @_engaged_match_controller_stream = st
            ___the_hard_way mc
          else
            self._WRONG
            o = Stream_Magnetics_::Sexp_Stream_via_String.new
            o.string = @_the_big_string
            o.sexp_symbol_for_context_strings = :orig_str
            o.pos = 0
            o.end = -1
            o.execute
          end
        end

        def ___the_hard_way mc

          p = nil

          block_pos, block_end = @_block.offsets

          after_repl = nil

          repl = -> do
            ___sexp_stream_via_match_then mc do
              p = nil
              after_repl[]
            end
          end

          static = -> pos do
            st = _build_sexp_stream_for_static_run pos, mc.pos
            -> do
              x = st.gets
              if x then x else
                p = repl[]
                p[]
              end
            end
          end

          if block_pos == mc.pos  # the match occupies the first cel in the block
            p = repl[]
          else
            # there is some static content we have to express before etc.
            p = static[ block_pos ]
          end

          after_repl = -> do
            # when you have reached the end of the replacement content

            mc_end = mc.end
            if block_end == mc_end
              # is the end of the match also the end of the block?
              p = EMPTY_P_ ; NOTHING_
            else
              mc = @_engaged_match_controller_stream.gets

              if mc  # then we have another match ..

                if mc_end == mc.pos
                  self._A

                else  # but we have some interceding content to express first
                  p = static[ mc_end ]
                  p[]
                end
              else
                p = _build_sexp_stream_for_static_run mc_end, @_block.end
                p[]
              end
            end
          end

          Callback_.stream do
            p[]
          end
        end

        def ___sexp_stream_via_match_then mc, & after_p

          s = mc.replacement_value
          if s
            sexp_st = Stream_Magnetics_::Sexp_Stream_via_String[ :repl_str, s ]
          else
            self._C
          end

          -> do
            x = sexp_st.gets
            if x
              x  # you got a[nother] sexp from the replacement value
            else
              after_p[]  # the replacement content has been exhausted.
            end
          end
        end

        def _build_sexp_stream_for_static_run beg, end_

          o = Stream_Magnetics_::Sexp_Stream_via_String.new
          o.string = @_the_big_string
          o.pos = beg
          o.end = end_
          o.sexp_symbol_for_context_strings = :orig_str
          o.execute
        end

        Match_controller_stream_via_block___ = -> block do

          curr = block
          Callback_.stream do
            curr = curr.next_match_controller
            curr
          end
        end
      end
    end
  end
end
