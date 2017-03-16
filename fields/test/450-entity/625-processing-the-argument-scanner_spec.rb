require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] entity - processing the argument scanner" do

    TS_[ self ]
    use :memoizer_methods
    use :entity

    context "basics" do

      shared_subject :_subject do

        class X_e_ptpu_Iamb

          Entity.lib.call self do

            def foo
              @foo_x = gets_one
            end

            def bar
              @bar_x = gets_one
            end

          end

          attr_reader :foo_x, :bar_x

          Entity::Enhance_for_test[ self ]
        end
      end

      it "do parse one does work" do
        _subject.with( :foo, :FOO ).foo_x.should eql :FOO
      end

      it "do parse two does work" do
        foo = _subject.with( :foo, :FOO, :bar, :BAR )
        foo.foo_x.should eql :FOO
        foo.bar_x.should eql :BAR
      end

      it "do parse strange does not work" do

        _be_this_msg = match %r(\Aunrecognized attribute 'wiz')

        begin
          _subject.with :wiz
        rescue Home_::ArgumentError => e
        end

        e.message.should _be_this_msg
      end

      it "do parse none does work" do
        _subject.with
      end
    end

    it "DSL syntax fail - strange name" do

      _be_this_msg = match %r(\Aunrecognized property 'VAG_rounded')

      begin
        class X_e_ptpu_Pity
          Entity.lib[ self, :VAG_rounded ]
        end
      rescue Home_::ArgumentError => e
      end

      e.message.should _be_this_msg
    end

    it "DSL syntax fail - strange value" do

      begin
        class X_e_ptpu_PityVal
          Entity.lib[ self, :argument_scanning_writer_method_name_suffix ]
        end
      rescue Home_::ArgumentError => e
      end

      e.message == "expecting a value for 'argument_scanning_writer_method_name_suffix'" || fail
    end

    context "iambic writer postfix option (& introduction to using the DSL)" do

      shared_subject :_subject do

        class X_e_ptpu_With_Postfix

          attr_reader :x

          Entity.lib.call self, :argument_scanning_writer_method_name_suffix, :'=' do
            def some_writer=
              @x = gets_one
            end
          end

          Entity::Enhance_for_test[ self ]
        end
      end

      it "iambic writer is recognized (and the DSL is used in the '[]')" do
        _subject.with( :some_writer, :foo ).x.should eql :foo
      end

      it "for now enforces that you use the suffix on every guy" do
        _rx = /\bdid not have expected suffix '_derp': 'ferp'/
        -> do
        class X_e_ptpu_Bad_Suffixer
          Entity.lib.call self, :argument_scanning_writer_method_name_suffix, :_derp do
            def ferp
            end
          end
        end
        end.should raise_error ::NameError, _rx
      end
    end

    # ==
    # ==
  end
end
