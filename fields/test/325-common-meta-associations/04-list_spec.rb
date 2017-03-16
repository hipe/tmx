require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] attributes - meta-attributes - list" do

    TS_[ self ]
    use :memoizer_methods
    use :attributes_meta_attributes

      context "(context)" do

        shared_subject :entity_class_ do

          class X_a_ma_List_A

            attrs = Attributes::Meta_Attributes.lib.call(
              topping: :list,
            )

            attrs.define_methods self

            self
          end
        end

        it "loads" do
          entity_class_
        end

        it "you don't get a reader - keep it orthoganal and simple" do

          entity_class_.instance_method( :topping ).arity.should eql 1
        end

        it "ok" do

          o = build_empty_entity_
          o.topping :sprinkles
          o.topping :sparkles
          o.instance_variable_get( :@topping ).should eql [ :sprinkles, :sparkles ]
        end
      end

    # ==

    it "(E.K)" do

        _subject = __not_memoized_but_could_be_subject

        _subject.length == 2 || fail

        _subject.map( & :name_symbol ) == %i( foo bar ) || fail

        a = _subject
        a.first.is_glob && fail
        a.last.is_glob || fail
    end

    def __not_memoized_but_could_be_subject

        given_definition_(
          :property, :foo,
          :glob, :property, :bar,
        )

        _st = flush_to_item_stream_expecting_all_items_are_parameters_
        _st.to_a
    end

    # ==
  end
end
