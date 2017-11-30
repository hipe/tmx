require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] stack - common frame - intro" do

    it "loads." do
      TS_::Common_Frame.lib || fail
    end

    it "whines on weirdness" do

      _rx = /\bunrecognized property 'weirdness'/

      begin
        class X_cf_Intro_A
          TS_::Common_Frame.lib.call self, :weirdness
        end
      rescue Home_::ArgumentError => e
      end

      expect( e.message ).to match _rx
    end

    context "a class with one property, a `method` macro" do

      before :all do

        class X_cf_Intro_B

          TS_::Common_Frame.lib.call(
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

        prp = X_cf_Intro_B.properties.fetch :foo_diddle
        expect( prp.reader_classification ).to eql :method
        expect( prp.parameter_arity ).to eql :zero_or_one

      end

      it "and then with an object of this class, call the method by `dereference`" do

        frame = X_cf_Intro_B.new { }
        frame.dereference( :foo_diddle ) == "foo diddle: 1" || fail
      end
    end

    context "`proc` macro (not memoized)" do

      before :all do

        class X_cf_Intro_C

          TS_::Common_Frame.lib.call self,

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
        entity = X_cf_Intro_C.new { }
        entity.dereference( :wiz_waz ) == "wiz waz: 1" || fail
        entity.dereference( :wiz_waz ) == "wiz waz: 2" || fail
        expect( entity.wiz_waz ).to eql 'wiz waz: 3'
        expect( entity.wiz_waz ).to eql 'wiz waz: 4'
      end
    end

    context "`proc` macro (memoized)" do

      before :all do

        class X_cf_Intro_D

          TS_::Common_Frame.lib.call self,

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
        entity = X_cf_Intro_D.new { }
        entity.dereference( :wiz_wuz ) == "wiz wuz: 1" || fail
        entity.dereference( :wiz_wuz ) == "wiz wuz: 1" || fail
      end
    end

    context "`memoized` cannot be used on" do

      it "`method`" do

        _rx = /\Apre-existing methods cannot be memoized\b/

        X_cf_xxx = ::Class.new

        begin
          TS_::Common_Frame.lib.call X_cf_xxx, :memoized, :method, :jib_jab
        rescue Home_::ArgumentError => e
        end

        expect( e.message ).to match _rx
      end
    end

    context "`inline_method` macro" do

      before :all do

        class X_cf_Intro_E

          TS_::Common_Frame.lib.call self,

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
        ent = X_cf_Intro_E.new { }
        expect( ent.dozer ).to eql 'zack braff'
        ent.dereference( :dozer ) == 'zack braff' || fail
      end
    end

    context "`memoized` `inline_method` macro" do

      before :all do

        class X_cf_Intro_F

          d = 0

          TS_::Common_Frame.lib.call self,
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
        ent = X_cf_Intro_F.new { }
        expect( ent.wowzaa ).to eql "1 1"
        expect( ent.wowzaa ).to eql "1 1"
        ent.dereference( :wowzaa ) == "1 1" || fail
        ent.dereference( :wowzaa ) == "1 1" || fail
      end
    end

    context "`readable` `field` (and `globbing` `processor` `initialize`)" do

      before :all do

        class X_cf_Intro_G

          TS_::Common_Frame.lib.call self, :readable, :field, :dingle_woofer,

            :globbing, :processor, :initialize

        end
      end

      it "loads" do
      end

      it "constructs iambicly" do

        entity = X_cf_Intro_G.new :dingle_woofer, :toofer

        x = entity.dingle_woofer
        expect( x ).to eql :toofer

        x = entity.dereference :dingle_woofer
        expect( x ).to eql :toofer

      end
    end

    context "`required` `field`" do

      before :all do

        class X_cf_Intro_H

          TS_::Common_Frame.lib.call self,
            :readable, :field, :foo,
            :field, :bar,
            :globbing, :processor, :initialize,
            :required, :readable, :field, :baz
        end

      end

      it "loads" do
      end

      it "when provide all properties" do

        entity = X_cf_Intro_H.new :foo, :FO, :bar, :BR, :baz, :BZ
        expect( entity.foo ).to eql :FO
        expect( entity.baz ).to eql :BZ
        entity.dereference( :baz ) == :BZ || fail

        expect( entity.respond_to?( :bar ) ).to eql false

        begin
          entity.dereference :bar
        rescue ::NameError => e
        end

        expect( e.message ).to match %r(\Aproperty is not readable - 'bar'\z)
      end

      it "when non-required fields missing" do
        entity = X_cf_Intro_H.new :baz, :hi
        expect( entity.baz ).to eql :hi
        expect( entity.foo ).to be_nil
      end

      it "when required field missing" do  # :#coverpoint1.8

        begin
          X_cf_Intro_H.new
        rescue Home_::ArgumentError => e
        end

        want_missing_required_message_without_newline_ e.message, :baz
      end
    end

    context "`required` `field` (but field is not readable)" do

      before :all do

        class X_cf_Intro_I

          TS_::Common_Frame.lib.call self,
            :required, :field, :foo,
            :globbing, :processor, :initialize
        end
      end

      it "when yes" do
        x = X_cf_Intro_I.new :foo, :F
        expect( x.instance_variable_get( :@foo ) ).to eql :F
      end

      it "when no" do

        begin
          X_cf_Intro_I.new
        rescue Home_::ArgumentError => e
        end

        want_missing_required_message_without_newline_ e.message, :foo
      end
    end

    define_method :want_missing_required_message_without_newline_, Common_Frame.definition_for_etc
  end
end
