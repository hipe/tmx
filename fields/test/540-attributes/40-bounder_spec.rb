require_relative '../test-support'

module Skylab::Fields::TestSupport

  TS_.require_ :attributes   # #[#017]
  module Attributes

    TS_.describe "[fi] attributes - bounder" do

      TS_[ self ]
      use :memoizer_methods
      Attributes[ self ]

      context "(context)" do

        shared_subject :entity_class_ do

          class X_A_Bounder_A

            attrs = Subject_module_[].call(
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

        it "loads" do
          _subject_module
        end

        it "builds" do
          _the_bounder or fail
        end

        it "value of list" do
          _bnd = _of_list_attribute
          _a = _bnd.value_x
          _a.should eql %w( goldfish llama )
        end

        def _of_list_attribute
          _the_bounder.lookup :pet
        end

        shared_subject :_the_bounder do

          _o = _this_entity
          _mod = _subject_module
          _guy = _mod[ _o ]
        end

        shared_subject :_this_entity do
          _build_guy
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

      def _subject_module
        Home_::Attributes::Bounder
      end
    end
  end
end
