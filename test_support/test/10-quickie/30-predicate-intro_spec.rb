require_relative '../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - predicates intro" do

    TS_[ self ]
    use :the_method_called_let
    use :quickie

    context "`eql`" do

      it "when not equal" do

        given_this_example_ do
          1.should_ eql 2
        end

        expect_example_fails_with_message_ 'expected 2, got 1'
      end

      it "when equal" do

        given_this_example_ do
          1.should_ eql 1
        end

        expect_example_passes_with_message_ 'equals 1'
      end
    end

    context "`match`" do

      it "when does not match" do

        given_this_example_ do
          'foo'.should_ match %r(bar)
        end

        expect_example_fails_with_message_ 'expected /bar/, had "foo"'
      end

      it "when matches" do

        given_this_example_ do
          'BEEFUS BOQUEEFUS'.should_ match %r(\Abeef.+boqueef)i
        end

        expect_example_passes_with_message_ "matches /\\Abeef.+boqueef/i"
      end
    end

    context "`raise_error`" do

      it "when expect to match class and rx, doesn't match rx" do

        given_this_example_ do
          -> do
            raise 'helf'
          end.should_ raise_error ::RuntimeError, /dinglebat/
        end

        expect_example_fails_with_message_(
          "expected helf to match (?-mix:dinglebat)" )
      end

      it "when expect to match class and rx, doesn't match class" do

        given_this_example_ do
          -> do
            raise 'helf'
          end.should_ raise_error ::NoMemoryError, 'helf'
        end

        expect_example_fails_with_message_(
          'expected NoMemoryError, had RuntimeError' )
      end

      it "when expect raise using rx, doesn't raise anything" do

        given_this_example_ do
          -> do
            NOTHING_
          end.should_ raise_error %r(wondertard)
        end

        expect_example_fails_with_message_(
          "expected lambda to raise, didn't raise anything." )
      end

      it "when expect raise using string, doesn't raise anything" do

        given_this_example_ do
          -> do
            NOTHING_
          end.should_ raise_error 'wankerberries'
        end

        expect_example_fails_with_message_(
          "expected lambda to raise, didn't raise anything." )
      end

      it "when expect to match class and rx and matches both" do

        given_this_example_ do
          -> do
            raise 'helf'
          end.should_ raise_error ::RuntimeError, 'helf'
        end

        expect_example_passes_with_message_(
          "raises RuntimeError matching (?-mix:\\Ahelf\\z)" )
      end
    end

    # ==

    context "dynamic predicate (on the fly it creates a class).." do

      # these are nasty tests because the write to the const space (or don't)

      it "when the subject matches the dynamically created predicate" do

        given_this_example_ do

          2.should_ be_even
        end

        expect_example_passes_with_message_ "is even"
      end

      it "when the subject does *not* matdch the dynamically created predicate" do

        given_this_example_ do

          3.should_ be_even
        end

        expect_example_fails_with_message_ "expected 3 to be even"
      end
    end

    # ==

    context "dynamic predicate that takes argument.." do

      it "when match" do

        given_this_example_ do

          [ :A ].should_ be_include :A
        end

        expect_example_passes_with_message_ "includes :A"
      end

      it "when not match" do

        given_this_example_ do

          [ :A ].should_ be_include :B
        end

        expect_example_fails_with_message_ "expected [:A] to include :B"
      end
    end

    # ==
    # ==
  end
end
# #history: full rewrite to scrap the hard to read procs used for scope #eyeblood
