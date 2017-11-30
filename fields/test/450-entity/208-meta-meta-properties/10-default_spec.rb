require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] entity - meta-meta-properties - default" do

    TS_[ self ]
    use :memoizer_methods
    use :entity

    context "uses an event hook" do

      shared_subject :_subject_class do

        class X_e_mmp_d_One

          attr_reader :foo, :bar, :baz

          Entity.lib.call self, :argument_scanning_writer_method_name_suffix, :"=" do

            o :default, 22,
              :meta_property, :importance,

              :importance, 10

            def foo=
              @foo = gets_one
            end

            o :importance, 20

            def bar=
              @bar = gets_one
            end

            def baz=
              @baz = gets_one
            end

          end

          self
        end
      end

      it "(builds)" do
        _subject_class || fail
      end

      it "ok" do
        a = _subject_class.properties.each_value.to_a
        expect( a.map( & :name_symbol ) ).to eql [ :foo, :bar, :baz ]
        expect( a.map( & :importance ) ).to eql [ 10, 20, 22 ]
      end
    end

    # ==
    # ==
  end
end
