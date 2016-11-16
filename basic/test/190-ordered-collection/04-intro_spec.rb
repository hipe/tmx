require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] ordered collection" do

    TS_[ self ]
    use :memoizer_methods

    it "loads" do
      _subject_module || fail
    end

    context "the empty guy" do

      it "builds" do
        _instance || fail
      end

      it "knows it's empty" do
        _instance.is_empty || fail
      end

      shared_subject :_instance do
        _build_empty
      end
    end

    context "insert or retrieve one item" do

      it "executes without failure" do
        _instance || fail
      end

      it "is not empty any more" do
        _instance.is_empty && fail
      end

      it "access the head ITEM" do
        _instance.head_item == :_value_1 || fail
      end

      it "retrieve the one item by key" do
        _expect_retrieve :_key_1, :_value_1
      end

      it "(deep audit of structure)" do

        linkA = _instance.instance_variable_get :@_head_link

        linkB = linkA.next

        linkC = linkB.next

        _name_these linkA, :linkA, linkB, :linkB, linkC, :linkC

        # [ ] _head_link [ ] [ ] content_link [ ] [ ] _tail_link [ ]

        _expect_prev_and_next nil, linkA, :linkB
        _expect_prev_and_next :linkA, linkB, :linkC
        _expect_prev_and_next :linkB, linkC, nil
      end

      shared_subject :_instance do
        o = _build_empty
        x = o.insert_or_retrieve :_key_1 do |k|
          :_value_1
        end
        x.nil? || fail
        o
      end
    end

    context "insert two items (reverse order)" do

      it "executes without failure" do
        _instance || fail
      end

      it "looks good thru deep audit" do
        _sym_a = _array_via_deep_audit
        _sym_a == [ :_value_1, :_value_2 ] || fail
      end

      shared_subject :_instance do
        o = _build_empty
        o.insert_or_retrieve( :_key_2 ) { :_value_2 }
        o.insert_or_retrieve( :_key_1 ) { :_value_1 }
        o
      end
    end

    context "insert two items (forward order)" do

      it "executes without failure" do
        _instance || fail
      end

      it "looks good thru deep audit" do
        _sym_a = _array_via_deep_audit
        _sym_a == [ :_value_1, :_value_2 ] || fail
      end

      shared_subject :_instance do
        o = _build_empty
        o.insert_or_retrieve( :_key_1 ) { :_value_1 }
        o.insert_or_retrieve( :_key_2 ) { :_value_2 }
        o
      end
    end

    # --

    def _expect_retrieve k, v
      _inst = _instance
      x = nil
      res = _inst.insert_or_retrieve k, nil do |x_|
        x = x_
      end
      res.nil? || fail
      x == v || fail
    end

    # -- deep audit 2

    def _array_via_deep_audit

      a = []
      _o = _instance
      left = _o.instance_variable_get :@_head_link

      left.instance_variable_defined? :@_prev_known and false
      left.is_head || fail

      begin
        # assume always there is a next (although the next might be tail)

        left.instance_variable_defined? :@_next_known or fail
        right = left.next

        right.prev.object_id == left.object_id || fail

        if right.is_tail
          right.instance_variable_defined? :@_next_known and fail
          break
        end

        a.push right.comparable.item
        left = right
        redo
      end while above
      a
    end

    # -- deep audit 1

    def _expect_prev_and_next exp_prev, link, exp_next

      _expect_one_side link, :is_head, :@_prev_known, exp_prev, :prev
      _expect_one_side link, :is_tail, :@_next_known, exp_next, :next
      NIL
    end

    def _expect_one_side link, is_head_or_tail_m, ivar, exp_sym, prev_or_next_m

      if link.send is_head_or_tail_m
        link.instance_variable_defined?( ivar ) and fail
        exp_sym && fail  # ..
      else
        _prev_or_next_link = link.send prev_or_next_m
        act_sym = @symbol_via_object_id.fetch _prev_or_next_link.object_id
        if exp_sym
          act_sym == exp_sym || fail  # ..
        else
          fail  # ..
        end
      end
    end

    def _name_these * x_a
      len = x_a.length
      d = 0
      h = {}
      until d == len
        h[ x_a.fetch( d ).object_id ] = x_a.fetch( d += 1 )
        d += 1
      end
      @symbol_via_object_id = h ; nil
    end

    # --

    def _build_empty
      _subject_module.begin_empty __my_collection_class
    end

    shared_subject :__my_collection_class do

      X_oc_ORD = {
        _key_1: 0,
        _key_2: 1,
        _key_3: 2,
      }

      class X_oc_CollectionClass

        def initialize k, x
          @item = x
          @_symbol = k
        end

        def compare_against_key k
          X_oc_ORD.fetch( @_symbol ) <=> X_oc_ORD.fetch( k )
        end

        attr_reader(
          :item,
        )

        self
      end
    end

    def _subject_module
      Home_::OrderedCollection
    end
  end
end
