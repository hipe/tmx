require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] ordered collection - muta" do

    TS_[ self ]
    use :memoizer_methods
    use :ordered_collection

    context "insert one item and remove it" do

      it "works without failure" do

        _double_trouble || fail
      end

      it "the removed comparable was resulted" do

        _cmp = _double_trouble.first
        _cmp.symbol___ == :key_1 || fail
      end

      it "guy is empty afterwards" do

        subject_instance_.is_empty || fail
      end

      def subject_instance_
        _double_trouble.last
      end

      shared_subject :_double_trouble do

        o = build_empty_subject_instance_

        o.insert_or_retrieve( :key_1 ) { :value_1 }

        _x = o.remove_head_comparable

        [ _x, o ]
      end
    end

    context "insert two items and remove one" do

      it "works without failure" do

        _double_trouble || fail
      end

      it "the removed comparable was resulted" do

        _cmp = _double_trouble.first
        _cmp.symbol___ == :key_2 || fail
      end

      it "guy is not empty afterwards" do

        subject_instance_.is_empty && fail
      end

      it "graph looks good" do

        _wee = array_via_deep_audit_
        _wee == [ :value_3 ] || fail
      end

      def subject_instance_
        _double_trouble.last
      end

      shared_subject :_double_trouble do

        o = build_empty_subject_instance_

        o.insert_or_retrieve( :key_2 ) { :value_2 }

        o.insert_or_retrieve( :key_3 ) { :value_3 }

        _x = o.remove_head_comparable

        [ _x, o ]
      end
    end

  end
end
