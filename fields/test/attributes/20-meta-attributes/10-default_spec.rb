require_relative '../../test-support'

module Skylab::Fields::TestSupport

  TS_.require_ :attributes_meta_attributes

  module Attributes::Meta_Attributes

    TS_.describe "[fi] attributes - meta-attributes - hook" do

      TS_[ self ]
      use :memoizer_methods
      Attributes::Meta_Attributes[ self ]

      context "intro" do

        shared_subject :entity_class_ do

          class X_Default_A

            attrs = Subject_module_[].call(
              starts_as_true: [ :default, true ],
            )

            ATTRIBUTES = attrs

            attr_reader :starts_as_true

            self
          end
        end

        it "has `default_proc`" do
          _attr.default_proc or fail
        end

        it "..which produces the value" do
          true == _attr.default_proc.call or fail
        end

        it "in a call to `init` without the value, it is set" do

          _against_expect Home_::EMPTY_A_, true
        end

        it "in a call to `init` with the value as false, default is NOT applied" do

          _against_expect [ :starts_as_true, false ], false
        end

        it "but if you set the thing to nil, the default is still applied.." do

          _against_expect [ :starts_as_true, nil ], true
        end

        def _against_expect a, x
          o = build_empty_entity_
          o_ = entity_class_::ATTRIBUTES.init o, a
          o.object_id == o_.object_id or fail
          o_.starts_as_true.should eql x
        end

        def _attr
          entity_class_::ATTRIBUTES._index._lookup_attribute :starts_as_true
        end
      end
    end
  end
end
