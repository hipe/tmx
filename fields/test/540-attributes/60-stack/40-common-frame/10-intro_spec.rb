require_relative '../../../test-support'

module Skylab::Fields::TestSupport

  describe "[br] property - stack - common frame" do

    it "loads." do
      Home_::Attributes::Stack::CommonFrame
    end

    it "whines on weirdness" do

      _rx = /\bunrecognized property 'weirdness'/

      begin
        class X_a_s_cf_Intro_A
          Home_::Attributes::Stack::CommonFrame.call self, :weirdness
        end
      rescue Home_::ArgumentError => e
      end

      e.message.should match _rx
    end

    context "a class with one property, a `method` macro" do

      before :all do

        class X_a_s_cf_Intro_B

          Home_::Attributes::Stack::CommonFrame.call(
            self, :method, :foo_diddle, )

          def foo_diddle
            ( @d ||= 0 )
            @d += 1
            "foo diddle: #{ @d }"
          end
        end
      end

      it "loads" do
      end

      it "we have full reflection on these properties" do

        prp = X_a_s_cf_Intro_B.properties.fetch :foo_diddle
        prp.reader_classification.should eql :method
        prp.parameter_arity.should eql :zero_or_one

      end

      it "and then with an object of this class, call the method by `property_value_via_symbol`" do

        frame = X_a_s_cf_Intro_B.new { }
        frame.property_value_via_symbol( :foo_diddle ).should eql "foo diddle: 1"
      end
    end

    context "`proc` macro (not memoized)" do

      before :all do

        class X_a_s_cf_Intro_C

          Home_::Attributes::Stack::CommonFrame.call self,

            :proc, :wiz_waz, -> do
              d = 0
              -> do
                "wiz waz: #{ d += 1 }"
              end
             end.call
        end
      end

      it "loads" do
      end

      it "reads (fresh call each time), makes reader methods too", f:true do
        entity = X_a_s_cf_Intro_C.new { }
        entity.property_value_via_symbol( :wiz_waz ).should eql "wiz waz: 1"
        entity.property_value_via_symbol( :wiz_waz ).should eql "wiz waz: 2"
        entity.wiz_waz.should eql 'wiz waz: 3'
        entity.wiz_waz.should eql 'wiz waz: 4'
      end
    end

    context "`proc` macro (memoized)" do

      before :all do

        class X_a_s_cf_Intro_D

          Home_::Attributes::Stack::CommonFrame.call self,

            :memoized, :proc, :wiz_wuz, -> do
              d = 0
              -> do
                "wiz wuz: #{ d += 1 }"
              end
            end.call

        end
      end

      it "loads" do
      end

      it "reaads (fresh call first time, subsequently memoized)" do
        entity = X_a_s_cf_Intro_D.new { }
        entity.property_value_via_symbol( :wiz_wuz ).should eql "wiz wuz: 1"
        entity.property_value_via_symbol( :wiz_wuz ).should eql "wiz wuz: 1"
      end
    end

    context "`memoized` cannot be used on" do

      it "`method`" do

        _rx = /\Apre-existing methods cannot be memoized\b/

        X_a_s_cf_xxx = ::Class.new

        begin
          Home_::Attributes::Stack::CommonFrame.call X_a_s_cf_xxx, :memoized, :method, :jib_jab
        rescue Home_::ArgumentError => e
        end

        e.message.should match _rx
      end
    end

    context "`inline_method` macro" do

      before :all do

        class X_a_s_cf_Intro_E

          Home_::Attributes::Stack::CommonFrame.call self,

            :inline_method, :dozer, -> do
              "zack #{ briff }"
            end

          def briff
            'braff'
          end
        end
      end

      it "loads" do
      end

      it "works (both ways)" do
        ent = X_a_s_cf_Intro_E.new { }
        ent.dozer.should eql 'zack braff'
        ent.property_value_via_symbol( :dozer ).should eql 'zack braff'
      end
    end

    context "`memoized` `inline_method` macro" do

      before :all do

        class X_a_s_cf_Intro_F

          d = 0

          Home_::Attributes::Stack::CommonFrame.call self,
            :memoized, :inline_method, :wowzaa, -> do
              "#{ fib_nibble  } #{ d += 1 }"
            end

          def fib_nibble
            @d ||= 0
            @d += 1
          end
        end
      end

      it "loads" do
      end

      it "works (both ways)" do
        ent = X_a_s_cf_Intro_F.new { }
        ent.wowzaa.should eql "1 1"
        ent.wowzaa.should eql "1 1"
        ent.property_value_via_symbol( :wowzaa ).should eql "1 1"
        ent.property_value_via_symbol( :wowzaa ).should eql "1 1"
      end
    end

    context "`readable` `field` (and `globbing` `processor` `initialize`)" do

      before :all do

        class X_a_s_cf_Intro_G

          Home_::Attributes::Stack::CommonFrame.call self, :readable, :field, :dingle_woofer,

            :globbing, :processor, :initialize

        end
      end

      it "loads" do
      end

      it "constructs iambicly" do

        entity = X_a_s_cf_Intro_G.new :dingle_woofer, :toofer

        x = entity.dingle_woofer
        x.should eql :toofer

        x = entity.property_value_via_symbol :dingle_woofer
        x.should eql :toofer

      end
    end

    context "`required` `field`" do

      before :all do

        class X_a_s_cf_Intro_H

          Home_::Attributes::Stack::CommonFrame.call self,
            :readable, :field, :foo,
            :field, :bar,
            :globbing, :processor, :initialize,
            :required, :readable, :field, :baz
        end

      end

      it "loads" do
      end

      it "when provide all properties" do

        entity = X_a_s_cf_Intro_H.new :foo, :FO, :bar, :BR, :baz, :BZ
        entity.foo.should eql :FO
        entity.baz.should eql :BZ
        entity.property_value_via_symbol( :baz ).should eql :BZ

        entity.respond_to?( :bar ).should eql false

        begin
          entity.property_value_via_symbol :bar
        rescue ::NameError => e
        end
        e.message.should match %r(\Aproperty is not readable - 'bar'\z)
      end

      it "when non-required fields missing" do
        entity = X_a_s_cf_Intro_H.new :baz, :hi
        entity.baz.should eql :hi
        entity.foo.should be_nil
      end

      it "when required field missing" do  # :#coverpoint1.8
        _rx = /\Amissing required field - 'baz'\z/

        begin
          X_a_s_cf_Intro_H.new
        rescue Home_::ArgumentError => e
        end

        e.message.should match _rx
      end
    end

    context "`required` `field` (but field is not readable)" do

      before :all do

        class X_a_s_cf_Intro_I

          Home_::Attributes::Stack::CommonFrame.call self,
            :required, :field, :foo,
            :globbing, :processor, :initialize
        end
      end

      it "when yes" do
        x = X_a_s_cf_Intro_I.new :foo, :F
        x.instance_variable_get( :@foo ).should eql :F
      end

      it "when no" do

        _rx = /\Amissing required field - 'foo'\z/

        begin
          X_a_s_cf_Intro_I.new
        rescue Home_::ArgumentError => e
        end

        e.message.should match _rx
      end
    end
  end
end
