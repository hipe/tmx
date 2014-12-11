require_relative 'test-support'

module Skylab::Brazen::TestSupport::Model::Entity

  describe "[br] model entity" do

    extend TS_

    it "loads" do
      Subject_[]
    end

    context "defaulting" do

      with_class do

        class E__Small_Agent_With_Defaults

          include Test_Instance_Methods_

          Subject_.call self do
            o :default, :yay, :property, :foo
          end

          self
        end
      end

      it "(with defaulting)" do
        ok = nil
        ent = subject_class.new do
          ok = procez
        end
        ok.should eql true
        ent.bx.fetch( :foo ).should eql :yay
      end

      it "(without defaulting)" do
        ok = nil
        ent = subject_class.new do
          ok = procez :foo, :bar
        end
        ent.bx.fetch( :foo ).should eql :bar
      end
    end


    context "integer-related metaproperty (this covers some ad-hoc n11n)" do

      with_class do

        class E__Integer

          include Test_Instance_Methods_

          Subject_.call self do
            o :integer_greater_than_or_equal_to, -2, :property, :zoip
          end

          self
        end
      end

      it "when yes" do

        ok = nil
        ent = subject_class.new do
          ok = procez :zoip, -2
        end
        ent.bx.fetch( :zoip ).should eql( -2 )
        ok.should eql true
      end

      it "when no" do
        _i_a = ev = nil
        p = -> * i_a, & ev_p do
          _i_a = i_a
          ev = ev_p[]
          false
        end
        ok = nil
        subject_class.new do
          @on_event_selectively = p
          ok = procez :zoip, -3
        end
        ok.should eql false
        _i_a.should eql [ :error, :number_too_small ]
        ev.terminal_channel_i.should eql :number_too_small
      end
    end

    context "required fields" do

      with_class do

        class E__Small_Agent_With_Required_Properties

          include Test_Instance_Methods_

          Subject_.call self,
            :required, :property, :foo,
            :required, :property, :bar,
            :properties, :bif, :baz

          self
        end
      end

      it "loads agent class" do
        subject_class
      end

      it "when all requireds are provided" do
        ok = nil
        ent = subject_class.new do
          ok = procez :foo, :a, :bar, :b, :baz, :c
        end
        ok.should eql true
        ent.bx.at( :foo, :bar, :baz ).should eql [ :a, :b, :c ]
      end

      it "when required args are missing, throws exception with same msg as app" do
        -> do
          subject_class.new do
            procez :bif, :x, :baz, :y
          end
        end.should raise_error ::ArgumentError, "missing required properties 'foo' and 'bar'"
      end
    end
  end
end
