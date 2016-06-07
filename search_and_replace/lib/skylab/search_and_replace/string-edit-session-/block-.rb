module Skylab::SearchAndReplace

  class StringEditSession_

    class Block_

        # implement exactly [#012] (over [#010] (over [#005])).

        class << self

          def via_ingredients__ o

            st = Build_block_stream___.new( o ).execute

            block = st.gets

            # (for now we'll just assume there is always at least one block,
            # although maybe we'll decide that empty files get no blocks.)

            block.__receive_big_string_as_first_block o.match_scanner.big_string__

            block.receive_predecessor_etc_ st

            block
          end
        end  # >>

        Ingredients = ::Struct.new(
          :line_scanner,
          :match_scanner,
          :replacement_function,
        )

        class Build_block_stream___ < Here_::A_B_Partitioner___

          # customize the partitioner for our "peek-and-steal" behavior so
          # that blocks are always "pure" but always demarcated by newlines.

          def initialize o
            @chunk = nil
            _line_stream, _match_stream, replacement_function = o.to_a
            @_services = Services___.new replacement_function
            super _line_stream, _match_stream  # A stream, B stream
          end

          def init_chunk_for_A
            @chunk = Here_::Static_Block___.new @_services ; nil
          end

          def init_chunk_for_B
            @chunk = Here_::Matches_Block___.new @_services ; nil
          end

          def release_chunk_which_is_for_A
            @chunk.close_static_block__
            super
          end

          def release_chunk_which_is_for_B
            @chunk.close_matches_block_
            super
          end

          # the next two are modeled after #spot-1 in the specs

          def chunk_when_touching_at_beginning rel

            # this means that at the start of the parse, the first newline
            # and the first match are exhibiting one of the six kinds of
            # touching (i.e kissing or 5 shapes of overlap). in such cases
            # the parser has no good basis by which to decide which should
            # be the first context (chunk) to build under, so intervention
            # is required. (covered by #spot-2)

            if rel.is_kissing && rel.is_forward

              # if the relationship is "kissing" (that is, touching but not
              # overlapping) *and* "forward" ("A" before "B") then it means
              # the newline is in front of and "kissing" the match, which
              # means that actually the two are on separate, adjacent lines EEW

              chunk_for_A_with_B  # newline as its own chunk.
            else
              # otherwise, they're either kissing with the match in front or
              # overlapping. if they're kissing in this manner it means the
              # newline sequence ends the [first] line the match overlaps with.
              # otherwise it's a match overlapping with a newline sequence,
              # which certainly goes into a matches chunk.

              chunk_for_B_with_A
            end
          end

          def on_boundary_between_B_and_A

            # despite 10 days of rewrites this is still inexplicably complex:
            # this is [#012]:#the-conjecture and :#spot-4:
            # you are in a "B" context (matches) and you have encountered a
            # boundary event (a newline). whether or not you consume the LTS
            # here determines whether we stay or "flip".

            if @chunk.block_is_closed

              # whenever the block is already closed then this is how we
              # "flip" to the other context, by doing nothing (which leaves
              # the LTS there so the parser knowns we need to break).

              self._YAY  # #todo

              NOTHING_

            elsif @item

              if @relationship.is_forward

                # theorem: if ever the match starts before the LTS,
                # the block definitiely wants them both (in order).
                # (the LTS may or may not be clear of the match.)
                # (the LTS may be same with the match #spot-5.)

                @chunk.add_match_controller__ self
                @chunk.add_LTS__ self

              else  # (really spread out for literacy)

                # assume the match starts at or after the start of the LTS.

                if @relationship.is_touching

                  if @relationship.is_kissing  # :#spot-7
                    # if here the match touches but does not overlap the LTS,
                    # then classify it as starting cleanly after the LTS.
                    NOTHING_
                  else
                    is_goofy = true
                  end
                end

                if is_goofy

                  # this is this "goofy" edge case where the match starts
                  # midway through an LTS. it is covered for both the first
                  # match in a block and midway through a block EXPERIMENTAL

                  @chunk.add_both_goofy__ self
                else

                  # the LTS is ahead of the match and clear of it. in such
                  # cases we don't even deal with the match here at all -
                  # leave the match there and the parser should do the right
                  # thing. we only want to give the block (the any last match
                  # there) a chance to maybe swallow the LTS.

                  @chunk.maybe_add_LTS_ self
                end
              end
            else

              # when it's only an LTS and not an item, give the block
              # the choice of whether or not to accept the LTS.

              @chunk.maybe_add_LTS_ self
            end
            NIL_
          end

          def release_LTS_
            x = @boundary_item
            @boundary_item = nil
            x
          end

          def clear_LTS_
            @boundary_item = nil
          end

          def LTS_
            @boundary_item
          end

          def release_match_
            x = @item
            @item = nil
            x
          end

          def clear_match_
            @item = nil
          end

          def match_
            @item
          end
        end

        # ==

        def initialize services
          @__services = services
        end

        # ~

        def duplicate_first_block__
          duplicate_block_for_previous_block_ NOTHING_
        end

        def duplicate_block_for_previous_block_ prev
          otr = dup
          otr.next_block
          otr.init_duplicated_block_for_previous_block_ prev
        end

        def init_duplicated_block_for_previous_block_ prev
          @previous_block = prev
          blk = @_next_block
          if blk
            @_next_block = blk.duplicate_block_for_previous_block_ self
          end
          self
        end

        # ~

        def __receive_big_string_as_first_block s
          @big_string_ = s ; nil
        end

        def receive_predecessor_etc_ st, previous_block=nil

          @_TEMP_st = st
          @_unflushed = true
          @previous_block = previous_block

          if previous_block
            @big_string_ = previous_block.big_string_
            @block_charpos = previous_block.block_end_charpos
          else
            @block_charpos = 0
          end
          NIL_
        end

        def big_string_
          @big_string_
        end

        def block_charpos
          @block_charpos  # (hi.)
        end

        # --

        def next_block
          if @_unflushed
            @_unflushed = false
            st = remove_instance_variable :@_TEMP_st
            blk = st.gets
            if blk
              blk.receive_predecessor_etc_ st, self
            end
            @_next_block = blk
          end
          @_next_block
        end

        def replacement_function__
          @__services.replacement_function
        end

        attr_reader(
          :previous_block,
        )

        # --

        def to_throughput_line_stream_
          _ = to_throughput_atom_stream_
          Home_::Throughput_Magnetics_::
            Throughput_Line_Stream_via_Throughput_Atom_Stream.new( _ ).execute
        end

      # ==

      Services___ = ::Struct.new :replacement_function

    end
  end
end
