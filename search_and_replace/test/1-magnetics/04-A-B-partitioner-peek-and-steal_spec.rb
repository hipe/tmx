require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - A-B partitioner (more)" do

    TS_[ self ]
    use :memoizer_methods
    use :magnetics_A_B_partitioner

    context "try to catch those newlines" do

      it "touching at beginning (minimal)" do

        _A [0,1]
        _B [0,3]
        expect_chunks :A, [[0,1], [:B,0,3]]
      end

      it "above but with more \"lines\"" do

        # from a drawing of a 5x3 "document" with DOS newlines, 2 matches

        _A [3,5], [7,8]
        _B [3,5],       [8,10], [13,15]

        expect_chunks :A, [[3,5], [:B,3,5], [7,8], [:B,8,10]],
                      :B, [[13,15]]
      end

      it "2 lines with simple matches, 1 line without, one line with." do

        # a document with four lines like above:
        #
        #     . M . n l  --> chunk 1
        #     . M . n l  /
        #     . . . n l      chunk 2
        #     . m . n l      chunk 3

        _A [1,2], [6,7], [16,17]
        _B [3,5], [8,10], [13,15], [18,20]

        expect_chunks :A, [[1,2],[:B,3,5],[6,7], [:B,8,10]],
                      :B, [[13,15]],
                      :A, [[16,17], [:B,18,20]]
      end

      it "more peek-and-steal" do

        _A [1,2],                      [10,11]

        _B       [4,5], [7, 8], [9,10],       [13,14]

        expect_chunks :A, [[1,2],[:B,4,5]], :B, [[7,8],[9,10]], :A, [[10,11],[:B, 13,14]]
      end

      it "jimmers" do

        _A [10,11]

        _B          [13,14], [14,14]

        expect_chunks :A, [[10,11], [:B,13,14]], :B, [[14,14]]
      end
    end

    shared_subject :subject_class_ do

      class X_AB_Two < self.A_B_partitioner_base_class

        # (#spot-1, the below 2 are a model for (but not identical to)
        # the production parser..

        def chunk_when_touching_at_beginning rel

          if rel.is_cleanly_apart && ! rel.is_forward

            # when newline is cleanly ahead of match, procede as normal
            chunk_for_B_with_A

          else
            # in all other cases (even if newline starts ahead of match),
            chunk_for_A_with_B
          end
        end

        def on_boundary_between_A_and_B  # :#spot-1

          # as you near leaving the "A" state and entering the "B" state:
          #
          # here is where we must work to establish our syntax beyond just
          # simple A-B partitioning: here is where we do the "peek-and-steal"
          # so that all chunks are terminated by newlines.
          #
          # in this file we're imagining that the "A" stream is the matches
          # and the "B" stream is the newlines. per the A-B API this method
          # is called whenever you are in an "A" state and the current "A"
          # item is not cleanly ahead of the boundary item.
          #
          # that means you are here IFF:
          #
          #   • the item and the boundary item exhibit one of the six
          #     kinds of touching (kiss, same, jut, lag, envelope, skew) OR
          #
          #   • the item is cleanly apart but after the boundary item
          #
          # i.e, either one of the items could have come first, or they
          # could even be beginning in the same cel (and/or ending on the
          # same cel too).

          # it's logically critical that you nilify whatever you consume

          add_newline = -> do
            @chunk.push @boundary_item ; @boundary_item = nil
          end

          add_match = -> do
            @chunk.push @item ; @item = nil
          end

          if @item
            # if the newline starts before the match starts,
            if @boundary_item.charpos < @item.charpos

              if @relationship.is_cleanly_apart  # if the newline does not
                # touch the match, consume the newline now and decide what
                # to do with the match in the next cycle. (there may be yet
                # another newline before it in which case chunk break.)
                add_match = nil
              else
                # newline is touching match but starts before it. consume
                # them both but place them in their corresponding order.
                reverse_them = true
              end
            end
          else
            add_match = nil
          end

          # never add a newline if the last item in the chunk is already
          # a newline. (this is how we ever get to forming a static block
          # after a matches block.)

          x = @chunk.last
          if x && :B == x._category_symbol_
            add_newline = nil
          end

          if reverse_them
            add_newline && add_newline[]
            add_match && add_match[]
          else
            add_match && add_match[]
            add_newline && add_newline[]
          end
          NIL_
        end

        self  # IMPORTANT
      end
    end
  end
end
