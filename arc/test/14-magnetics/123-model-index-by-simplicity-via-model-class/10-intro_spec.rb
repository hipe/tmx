require_relative '../../test-support'

module Skylab::Arc::TestSupport

  describe "[arc] magnetics - model index by simplicity - intro" do  # :#coverpoint2.2

    # (say something. #born has a commit message as draft. EDIT #todo)

    TS_[ self ]
    use :memoizer_methods
    use :model_index_by_simplicity

    it "loads" do
      subject_module_ || fail
    end

    context "for names not ending in (_symbol|_string) we cannot infer type" do

      it "fails" do
        _this || fail
      end

      it "message" do
        _msg = _this.message
        _msg =~ /\A`wachumba_my_wumba` must end in / || fail
      end

      shared_subject :_this do

        given_upstream_ :wachumba_my_wumba, :no_see

        begin
          interpret_entity_
        rescue Home_::RuntimeError => e
        end

        e
      end
    end

    context "extra" do

      it "fails" do
        fails_
      end

      it "explains" do
        _actual = tuple_.first
        _actual == [ "unrecognized property 'bleecko_blicko'" ] || fail
      end

      shared_subject :tuple_ do
        a = []

        given_upstream_ :bleecko_blicko, :no_see

        want :error, :expression, :unrecognized_property do |y|
          a.push y
        end

        a.push execute
      end
    end

    context "if a primitive type isn't specified explicitly but can be inferred from field name (symbol)" do

      it "derives" do
        _subject || fail
      end

      it "memoizes" do

        once = call_subject_module_
        _again = call_subject_module_
        once || fail
        once.object_id == _again.object_id || fail
      end

      it "converts, for example, string to n" do

        given_upstream_ :category_symbol, "valued_customer"
        _ent = interpret_entity_
        _ent.category_symbol == :valued_customer || fail
      end

      shared_subject :_subject do
        call_subject_module_
      end
    end

    context "use TYPES hash to state type explicitly" do

      it "convert, for example, integer to string" do

        given_upstream_ :email, 1
        _ent = interpret_entity_
        _ent.email == "1" || fail
      end

      it "string as string OK" do

        s = "a@b.c"
        given_upstream_ :email, s
        _ent = interpret_entity_
        _ent.email == s || fail
      end
    end

    context "(range error)" do

      it "results in falseish" do
        fails_
      end

      it "explains" do
        tuple_.first == [ "must be non negative (had: -1)" ] || fail
      end

      shared_subject :tuple_ do
        a = []

        given_upstream_ :thing_count, "-1"

        want :error, :expression, :range_error do |y|
          a.push y
        end
        a.push execute
      end
    end

    def subject_class_
      X_01_Customer
    end

    def expression_agent
      expag_for_modernity_
    end

    # ==

    class X_01_Customer < Common_::SimpleModel

      TYPES = {
        email: :_string_,
        thing_count: :_non_negative_integer_,
      }

      attr_accessor(
        :category_symbol,
        :thing_count,
        :email,
        :wachumba_my_wumba,
      )
    end

    # ==
    # ==
  end
end
# #born
