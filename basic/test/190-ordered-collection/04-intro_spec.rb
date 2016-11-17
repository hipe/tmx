require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] ordered collection" do

    TS_[ self ]
    use :memoizer_methods
    use :ordered_collection

    it "loads" do
      subject_module_ || fail
    end

    context "the empty guy" do

      it "builds" do
        subject_instance_ || fail
      end

      it "knows it's empty" do
        subject_instance_.is_empty || fail
      end

      shared_subject :subject_instance_ do
        build_empty_subject_instance_
      end
    end

    context "insert or retrieve one item" do

      it "executes without failure" do
        subject_instance_ || fail
      end

      it "is not empty any more" do
        subject_instance_.is_empty && fail
      end

      it "access the head ITEM" do
        subject_instance_.head_item == :value_1 || fail
      end

      it "retrieve the one item by key" do
        expect_retrieve_ :key_1, :value_1
      end

      it "(deep audit of structure)" do

        linkA = subject_instance_.instance_variable_get :@_head_link

        linkB = linkA.next

        linkC = linkB.next

        name_these_ linkA, :linkA, linkB, :linkB, linkC, :linkC

        # [ ] _head_link [ ] [ ] content_link [ ] [ ] _tail_link [ ]

        expect_prev_and_next_ nil, linkA, :linkB
        expect_prev_and_next_ :linkA, linkB, :linkC
        expect_prev_and_next_ :linkB, linkC, nil
      end

      shared_subject :subject_instance_ do
        o = build_empty_subject_instance_
        x = o.insert_or_retrieve :key_1 do |k|
          :value_1
        end
        x.nil? || fail
        o
      end
    end

    context "insert two items (reverse order)" do

      it "executes without failure" do
        subject_instance_ || fail
      end

      it "looks good thru deep audit" do
        _sym_a = array_via_deep_audit_
        _sym_a == [ :value_1, :value_2 ] || fail
      end

      shared_subject :subject_instance_ do
        o = build_empty_subject_instance_
        o.insert_or_retrieve( :key_2 ) { :value_2 }
        o.insert_or_retrieve( :key_1 ) { :value_1 }
        o
      end
    end

    context "insert two items (forward order)" do

      it "executes without failure" do
        subject_instance_ || fail
      end

      it "looks good thru deep audit" do
        _sym_a = array_via_deep_audit_
        _sym_a == [ :value_1, :value_2 ] || fail
      end

      shared_subject :subject_instance_ do
        o = build_empty_subject_instance_
        o.insert_or_retrieve( :key_1 ) { :value_1 }
        o.insert_or_retrieve( :key_2 ) { :value_2 }
        o
      end
    end
  end
end
# #tombstone: took the known knowns (training wheels) out
