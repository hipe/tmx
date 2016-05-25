module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___

      class A_B_Partitioner___  # implement exactly [#005]. #testpoint

        def initialize _A_stream, _B_stream
          @A_stream = _A_stream
          @B_stream = _B_stream
        end

        def execute
          @_state = :__any_first_chunk
          Callback_.stream do
            send @_state
          end
        end

        def __any_first_chunk

          @A = @A_stream.gets
          @B = @B_stream.gets

          if @A
            if @B
              @_state = :__first_chunk_when_A_and_B
            else
              @_state = :_chunk_when_A_and_no_B
            end
          elsif @B
            @_state = :_chunk_when_B_and_no_A
          else
            close_stream
          end

          send @_state
        end

        # -- hard chunks

        def __first_chunk_when_A_and_B

          rel = _relationship_between @A, @B

          # if one is cleanly apart of the other let that one lead the parse

          if rel.is_cleanly_apart

            if rel.is_forward

              chunk_for_A_with_B

            else
              chunk_for_B_with_A
            end

          else
            self.chunk_when_touching_at_beginning rel
          end
        end

        def chunk_for_A_with_B

          @forward = true
          init_chunk_for_A
          @item = remove_instance_variable :@A
          _money
        end

        def chunk_for_B_with_A
          @forward = false
          init_chunk_for_B
          @item = remove_instance_variable :@B
          _money
        end

        def _money

          if @forward
            st = @A_stream
            st_ = @B_stream
            @boundary_item = remove_instance_variable :@B
          else
            st = @B_stream
            st_ = @A_stream
            @boundary_item = remove_instance_variable :@A
          end

          begin

            @item ||= st.gets  # allow this to be left as-is by callbacks

            if @item

              _init_relationship_between_item_and_boundary_item

              if @relationship.is_cleanly_apart && @relationship.is_forward
                _accept_current_item
                redo
              end

              _ON_BOUNDARY

              if @boundary_item
                if @item
                  _flip_or_end
                  break
                end
                redo
              end
              @boundary_item = st_.gets
              @boundary_item && redo
              into_chunk_flush st_
              close_stream
              break
            end

            # although the current stream is exhausted, we need to give
            # the client a chance to peek and steal boundary piece*s*

            was_last = @chunk.last

            begin
              @item = was_last  # NOT SURE
              _init_relationship_between_item_and_boundary_item
              @item = nil  # EEK #here-1

              _ON_BOUNDARY  # give client a chance to peek and steal

              if ! @boundary_item  # then the client took it.
                @boundary_item = st_.gets
                if @boundary_item  # if there's another one, try again
                  redo
                end
              end
              break
            end while nil

            # the client may have "peeked" and taken 1-N boundary items.
            # now either we are out of boundary items or the client didn't
            # want this boundary item:

            _flip_or_end
            break

          end while nil

          # (client should have cleaned up @item and @boundary_item)

          remove_instance_variable :@relationship

          if @forward
            release_chunk_which_is_for_A
          else
            release_chunk_which_is_for_B
          end
        end

        def _init_relationship_between_item_and_boundary_item
          @relationship = _relationship_between @item, @boundary_item
          NIL_
        end

        def _ON_BOUNDARY

          # give clients the ability to specify one or the other explicitly
          # (but then in our default implementation we corral back in)

          if @forward
            on_boundary_between_A_and_B
          else
            on_boundary_between_B_and_A
          end
          NIL_
        end

        def on_boundary_between_A_and_B
          _common_boundary_decision
          NIL_
        end

        def on_boundary_between_B_and_A
          _common_boundary_decision
          NIL_
        end

        def _common_boundary_decision

          # (see spec) we are here because the client defined no hook-in for
          # this (or called super) and the current item is not cleanly in
          # front of the boundary item; i.e it is touching or cleanly behind.
          #
          #   • if the item is cleanly behind the boundary item, it seems
          #     reasonable that the default choice should be to flip.
          #
          #   • otherwise (and it is one of the 6 kinds of touching), our
          #     "purist" take on this is that A) this is that A) we don't
          #     want to "pollute" our chunk by assuming it is ok to take
          #     both the local and remote items but B) we don't want to
          #     "break apart" the touching items either, however C) we will
          #     if they are just kissing, not overlapping.
          #
          # HOWEVER if we do nothing and the other side does nothing we
          # will infinite loop flip-flopping forever SO the robust parser
          # MUST define at least one of these sides appropriately..

          if @relationship.is_forward && @relationship.is_kissing
            @chunk.push @item ; @item = nil
          end
          NIL_
        end

        def _accept_current_item

          @chunk.push @item
          @item = nil
        end

        def _flip_or_end  # eew

          # decide what to do based on what is set (near #here-1)

          x = remove_instance_variable :@item
          x_ = remove_instance_variable :@boundary_item

          if x_
            if x
              if @forward
                @A = x
                @B = x_
                @_state = :chunk_for_B_with_A
              else
                @B = x
                @A = x_
                @_state = :chunk_for_A_with_B
              end
            else
              if @forward
                @B = x_
                @_state = :_chunk_when_B_and_no_A
              else
                @A = x_
                @_state = :_chunk_when_A_and_no_B
              end
            end
          elsif x
            if @forward
              @A = x
              @_state = :_chunk_when_A_and_no_B
            else
              @B = x
              @_state = :_chunk_when_B_and_no_A
            end
          else
            close_stream
          end
          NIL_
        end

        # -- easy chunks

        def _chunk_when_A_and_no_B
          @forward = true
          init_chunk_for_A
          @chunk.push remove_instance_variable :@A
          finish_for_A
        end

        def finish_for_A
          into_chunk_flush @A_stream
          x = release_chunk_which_is_for_A
          close_stream
          x
        end

        def _chunk_when_B_and_no_A
          @forward = false
          init_chunk_for_B
          @chunk.push remove_instance_variable :@B
          finish_for_B
        end

        def finish_for_B
          into_chunk_flush @B_stream
          x = release_chunk_which_is_for_B
          close_stream
          x
        end

        def into_chunk_flush st
          ch = @chunk
          begin
            x = st.gets
            x or break
            ch.push x
            redo
          end while nil
          NIL_
        end

        def init_chunk_for_A
          @chunk = [] ; nil
        end

        def init_chunk_for_B
          @chunk = [] ; nil
        end

        def release_chunk_which_is_for_A
          remove_instance_variable :@chunk
        end

        def release_chunk_which_is_for_B
          remove_instance_variable :@chunk
        end

        def close_stream
          @_state = :___done ; nil
        end

        def ___done
          NOTHING_
        end

        # --

        def _relationship_between _A, _B
          _begin_rel_d = _A.charpos <=> _B.charpos
          _end_rel_d = _A.end_charpos <=> _B.end_charpos
          o = RELS___.fetch [ _begin_rel_d, _end_rel_d ]
          while o.is_branch
            o = o.proc.call _A, _B
          end
          o
        end

        # --

        # ==

        base = class Relationship___

          def initialize
            @is_forward = true
          end

          def new name_sym=nil, & p
            o = dup
            if name_sym
              o.name_symbol = name_sym
            end
            if p
              o.is_branch = true
              o.proc = p
            end
            o
          end

          def to_converse
            o = dup
            o.is_forward = false
            o.converse_of = self
            o
          end

          attr_accessor(
            :converse_of,
            :is_branch,
            :is_cleanly_apart,
            :is_kissing,
            :is_forward,
            :is_overlap,
            :is_touching,
            :name_symbol,
            :proc,
          )

          o = new
          class << self
            undef_method :new
          end
          o
        end

        overlap = base.new
        overlap.is_touching = true
        overlap.is_overlap = true

        jutting = overlap.new :_jutting_
        enveloping = overlap.new :_enveloping_
        lagging = overlap.new :_lagging_

        _leading = base.new do |_A, _B|
          # A begin is before B begin and A end is before B end.
          # but what is the relationship between A end and B begin?
          LEADING___.fetch( _A.end_charpos <=> _B.charpos )
        end

        _counter_leading = base.new do |_A, _B|
          # A begin is after B begin and A end if after B end.
          # but what is the relationship between A begin and B end?
          COUNTER_LEADING___.fetch( _B.end_charpos <=> _A.charpos )  # see
        end

        RELS___ = {
          [ -1, -1 ] => _leading,
          [ -1,  0 ] => jutting,
          [ -1,  1 ] => enveloping,
          [  0, -1 ] => lagging,
          [  0,  0 ] => overlap.new( :_same_ ),
          [  0,  1 ] => lagging.to_converse,
          [  1, -1 ] => enveloping.to_converse,
          [  1,  0 ] => jutting.to_converse,
          [  1,  1 ] => _counter_leading,
        }

        cleanly_apart = base.new :_cleanly_apart_
        cleanly_apart.is_cleanly_apart = true

        kissing = base.new :_kissing_
        kissing.is_kissing = true
        kissing.is_touching = true

        skewed = overlap.new :_skewed_

        LEADING___ = {
          -1 => cleanly_apart,
           0 => kissing,
           1 => skewed,
        }

        COUNTER_LEADING___ = {
          -1 => cleanly_apart.to_converse,  # B end is before A begin - B is out in front
           0 => kissing.to_converse,  # B end and A begin are same - kissing
           1 => skewed.to_converse,  # B end is after A begin - skewed with B leading
        }

        # ==

      end
    end
  end
end
