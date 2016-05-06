require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - A-B partitioner" do

    TS_[ self ]
    use :memoizer_methods
    use :magnetics_A_B_partitioner

    # voluminous docs at [#005]

    context "essentials" do

      it 'loads' do
        subject_class_
      end
    end

    context "no overlap" do

      it "two empty streams" do
        _A
        _B
        flush_chunks.length.zero? or fail
      end

      it "one B, no A" do
        _A
        _B [0,0]
        a = flush_chunks
        1 == a.length or fail
        _chunk_1 = a.first
        1 == _chunk_1.length or fail
        expect_span _chunk_1.first, 0, 0, :B
      end

      it "one A, no B" do
        _A [1,2]
        _B
        expect_chunks :A, [[1,2]]
      end

      it "two B's only" do
        _A
        _B [3,2], [1,0]
        expect_chunks :B, [[3,2], [1,0]]
      end

      it "an A out in front THEN a B" do

        _A [6,9]
        _B        [10,11]

        expect_chunks :A, [[6,9]], :B, [[10,11]]
      end

      it "as above but touch" do

        _A [1,2]
        _B      [2,3]

        expect_chunks :B, [[2,3], [:A,1,2]]  # NOTE order is not OK
      end

      it "A B A (cleanly)" do

        _A [0,1],         [4,5]
        _B         [2,3]
        expect_chunks :A, [[0,1]], :B, [[2,3]], :A, [[4,5]]
      end

      it "two A's, second one kisses first of two B's. still separate" do

        _A [0,1], [2,3]
        _B              [3,4], [4,5]
        expect_chunks :A, [[0,1], [2,3]], :B, [[3,4], [4,5]]
      end
    end

    context "overlap intro" do

      it "a same overlap - requires intervention" do  # #here-1

        _A [77,99]
        _B [77,99]
        expect_chunks :B, [[77,99], [:A,77,99]]
      end

      it "one overlap when during B, there is a B-jut overlap, swallow 1 A," do

        # exercise #here-2

        _A                [6,7], [8,9]

        _B [1,2], [3,4], [5,7]

        expect_chunks :B, [[1,2], [3,4], [5,7], [:A,6,7]], :A, [[8,9]]
      end
    end

    shared_subject :subject_class_ do

      class X_AB_One < self.A_B_partitioner_base_class

        def chunk_when_touching_at_beginning rel

          # show that we need to decide this kind of behavior :#here-1

          chunk_for_B_with_A
        end

        def on_boundary_between_B_and_A

          # shows how we can control overlapping behavior :#here-2

          rel = @relationship

          if rel.is_touching  # REGARDLESS of direction, swallow

            if @item
              @chunk.push @item ; @item = nil
            end

            @chunk.push @boundary_item ; @boundary_item = nil
          end
          NIL_
        end

        self  # IMPORTANT
      end
    end
  end
end
