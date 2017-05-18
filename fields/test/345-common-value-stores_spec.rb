require_relative 'test-support'

module Skylab::Fields::TestSupport

  describe "[fi] common value stores" do

    TS_[ self ]
    use :memoizer_methods
    use :attributes

    # ==

      context "(context)" do

        shared_subject :entity_class_ do

          class X_cvs_NoSee_A

            attrs = Attributes.lib.call(
              age: :_write,
              pet: :list,
              hobby: :_write,
            )

            attrs.define_methods self

            attr_writer( * attrs.symbols( :_write ) )

            ATTRIBUTES = attrs

            self
          end
        end

        it "builds" do
          _the_reader or fail
        end

        it "value of list" do
          _bnd = _of_list_attribute
          _a = _bnd.value
          _a == %w( goldfish llama ) || fail
        end

        def _of_list_attribute
          _the_reader.association_reader_via_symbol :pet
        end

        shared_subject :_the_reader do

          ent = _build_guy
          ent.class::ATTRIBUTES::ASSOCIATION_VALUE_READER_FOR ent
        end

        def _build_guy
          o = build_empty_entity_
          o.age = 'fifty one'
          o.hobby = 'spelunk-fishing'
          o.pet 'goldfish'
          o.pet 'llama'
          o
        end
      end
    end
  # ==

  # ==
  # ==
end
