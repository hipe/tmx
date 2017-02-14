require_relative '../../test-support'

module Skylab::Fields::TestSupport

  TS_.require_ :attributes_meta_attributes  # #[#017]
  module Attributes::Meta_Attributes

    TS_.describe "[fi] attributes - meta-attributes - default" do

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

        def _attr
          entity_class_::ATTRIBUTES.attribute :starts_as_true
        end

        def _against_expect a, x

          _ = build_by_init_via_sexp_ a
          _.starts_as_true.should eql x
        end
      end

      context "`default_proc` is also a thing (more low-level, same effect)" do

        shared_subject :entity_class_ do

          class X_Default_B

            d = 0

            attrs = Subject_module_[].call(
              wahoo: [ :default_proc, -> { "wahootie: #{ d += 1 }" } ],
              other: nil,
            )

            ATTRIBUTES = attrs

            attr_reader( * attrs.symbols )

            self
          end
        end

        it "don't" do

          o = build_by_init_ :wahoo, :xx, :other, :hi
          :hi == o.other or fail
          :xx == o.wahoo or fail
        end

        it "do" do
          o = build_by_init_ :other, :hi
          :hi == o.other or fail
          "wahootie: 1" == o.wahoo or fail
        end
      end
    end
  end
end
