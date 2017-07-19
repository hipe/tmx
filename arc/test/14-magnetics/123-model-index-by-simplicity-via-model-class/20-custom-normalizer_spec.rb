require_relative '../../test-support'

module Skylab::Arc::TestSupport

  describe "[arc] magnetics - model index by simplicity - custom normalizer" do

    TS_[ self ]
    use :memoizer_methods
    use :model_index_by_simplicity

    context "when both type and n11n, and type error" do

      it "results in falseish" do
        fails_
      end

      it "explains" do
        tuple_.first == [ "doesn't look like string: 100" ] || fail
      end

      shared_subject :tuple_ do

        a = []

        given_upstream_ :email, 100

        expect :error, :expression, :type_error do |y|
          a.push y
        end

        a.push execute
      end
    end

    context "both type and n11n - let's see that custom n11n fail" do

      it "fails" do
        fails_
      end

      it "custom message is custom" do
        _actual = tuple_.first
        _actual == [ 'flubburgh: "nyla"' ] || fail
      end

      shared_subject :tuple_ do
        a = []

        given_upstream_ :email, "nyla"

        expect :error, :expression, :yup do |y|
          a.push y
        end

        a.push execute
      end
    end

    it "both type and n11n - custom normalization can convert" do

      given_upstream_ :email, "aa@bb.cc"
      _ent = interpret_entity_
      _ent.email == %w( aa bb cc ) || fail
    end

    context "n11n only - fail" do

      it "fails" do
        fails_
      end

      it "custom message is custom" do
        _actual = tuple_.first
        _actual == [ 'zigowat *hi*' ] || fail
      end

      shared_subject :tuple_ do
        a = []

        given_upstream_ :gza, nil

        expect :error, :expression, :yup_is_required do |y|
          a.push y
        end

        a.push execute
      end
    end

    it "n11n succeed - custom normalization can convert" do

      given_upstream_ :gza, 23
      _ent = interpret_entity_
      _ent.gza == "INTEGER" || fail
    end

    def subject_class_
      X_02_FooFoo
    end

    def expression_agent
      expag_for_modernity_
    end

    # ==

    class X_02_FooFoo < Common_::SimpleModel

      TYPES = {
        email: :_string_,
      }

      def normalize__email__ s, & p
        s.respond_to? :ascii_only? or fail
        md = /\A([a-z]+)@([a-z]+)\.([a-z]+)\z/.match s
        if md
          Common_::KnownKnown[ md.captures ]
        else
          p.call :error, :expression, :yup do |y|
            y << "flubburgh: #{ ick_mixed s }"
          end
          UNABLE_
        end
      end

      def normalize__gza__ x, & p
        if x.nil?
          p.call :error, :expression, :yup_is_required do |y|
            y << "zigowat #{ em 'hi' }"
          end
          UNABLE_
        else
          Common_::KnownKnown[ x.class.name.upcase ]
        end
      end

      attr_accessor(
        :email,
        :gza,
      )
    end

    # ==
    # ==
  end
end
# #born
