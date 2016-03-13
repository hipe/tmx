require_relative '../../test-support'

module Skylab::Fields::TestSupport

  TS_.require_ :attributes_meta_attributes  # #[#017]
  module Attributes::Meta_Attributes

    TS_.describe "[fi] attributes - meta-attributes - boolean" do

      TS_[ self ]
      use :memoizer_methods
      Attributes::Meta_Attributes[ self ]

      context "intro" do

        shared_subject :entity_class_ do

          class X_Boolean_A

            attrs = Subject_module_[].call(
              finished: :boolean,
            )

            attrs.define_methods self

            self
          end
        end

        it '"object.foo?" is a reader of the (presumably boolean) value' do

          build_empty_entity_.finished?.should be_nil
        end

        it '"object.foo!" is a DSL-y writer that sets the parameter ' <<
          'value of "foo" to true' do

          object = build_empty_entity_
          object.finished!
          object.finished?.should eql(true)
        end

        it '"object.not_foo!" is a DSL-y writer that sets the parameter value ' <<
          'of "foo" to false' do

          object = build_empty_entity_
          object.not_finished!
          object.finished?.should eql(false)
        end

        it '"object.foo", however, (a reader) you do not get ' <<
          'out of the box just like that.' do

          entity_class_.method_defined?( :finished ) and fail
        end

        it '"object.foo = x", however, (the writer) you do not just get ' <<
          'out of the box just like that just for doing nothing ' do

          entity_class_.method_defined?( :finished= ) and fail
        end
      end

      context "custom stems (etc. proof of concept)" do

        shared_subject :entity_class_ do

          class X_Boolean_B

            attrs = Subject_module_[].call(
              ready: [ :boolean, :negative_stem, :pending, :positive_stem, :is_ready ],
            )

            attrs.define_methods self

            self
          end
        end

        it "neg read / positive write" do

          sess = build_empty_entity_
          sess.pending? or fail
          sess.is_ready!
          sess.pending? and fail
        end

        it "pos read / neg write" do

          sess = build_empty_entity_
          sess.is_ready? and fail
          sess.is_ready!
          sess.is_ready? or fail
          sess.pending!
          sess.is_ready? and fail
        end
      end
    end
  end
end
