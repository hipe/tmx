require_relative '../../../test-support'

module Skylab::Brazen::TestSupport::PropertyStack_Namespace_0____

  ::Skylab::Brazen::TestSupport.lib_(
    :property_stack_models_common_frame
  ).prepare_sandbox self

  describe "[br] property - stack - common frame" do

    it "loads." do

      Subject_[]

    end

    it "whines on weirdness" do

      _rx = /\bunrecognized property 'weirdness'/

      begin
        class Foo_Thing
          Subject_[ self, :weirdness ]
        end
      rescue ::ArgumentError => e
      end

      e.message.should match _rx
    end

    context "a class with one property, a `method` macro" do

      before :all do

        class CF_One_Property

          Home_::Property::Stack.common_frame self,
            :method, :foo_diddle

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

        prop = CF_One_Property.properties.fetch :foo_diddle
        prop.reader_classification.should eql :method
        prop.parameter_arity.should eql :zero_or_one

      end

      it "and then with an object of this class, call the method by `property_value_via_symbol`" do

        frame = CF_One_Property.new { }
        frame.property_value_via_symbol( :foo_diddle ).should eql "foo diddle: 1"

      end
    end

    context "`prop` macro (not memoized)" do

      before :all do

        class CF_Prop_Simple

          Subject_.call self,

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
        entity = CF_Prop_Simple.new { }
        entity.property_value_via_symbol( :wiz_waz ).should eql "wiz waz: 1"
        entity.property_value_via_symbol( :wiz_waz ).should eql "wiz waz: 2"
        entity.wiz_waz.should eql 'wiz waz: 3'
        entity.wiz_waz.should eql 'wiz waz: 4'
      end
    end

    context "`proc` macro (memoized)" do

      before :all do

        class CF_Prop_Memoized

          Subject_.call self,

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
        entity = CF_Prop_Memoized.new { }
        entity.property_value_via_symbol( :wiz_wuz ).should eql "wiz wuz: 1"
        entity.property_value_via_symbol( :wiz_wuz ).should eql "wiz wuz: 1"
      end
    end

    context "`memoized` cannot be used on" do

      it "`method`" do

        _rx = /\Apre-existing methods cannot be memoized\b/

        CF_Memoized_Method = ::Class.new

        begin
          Subject_.call CF_Memoized_Method, :memoized, :method, :jib_jab
        rescue ::ArgumentError => e
        end

        e.message.should match _rx
      end
    end

    context "`inline_method` macro" do

      before :all do

        class CF_Inline_Method

          Subject_.call self,

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
        ent = CF_Inline_Method.new { }
        ent.dozer.should eql 'zack braff'
        ent.property_value_via_symbol( :dozer ).should eql 'zack braff'
      end
    end

    context "`memoized` `inline_method` macro" do

      before :all do

        class CF_Inline_Method_Memoized

          d = 0

          Subject_.call self,
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
        ent = CF_Inline_Method_Memoized.new { }
        ent.wowzaa.should eql "1 1"
        ent.wowzaa.should eql "1 1"
        ent.property_value_via_symbol( :wowzaa ).should eql "1 1"
        ent.property_value_via_symbol( :wowzaa ).should eql "1 1"
      end
    end

    context "`readable` `field` (and `globbing` `processor` `initialize`)" do

      before :all do

        class CF_Field_Minimal

          Subject_.call self, :readable, :field, :dingle_woofer,

            :globbing, :processor, :initialize

        end
      end

      it "loads" do
      end

      it "constructs iambicly" do

        entity = CF_Field_Minimal.new :dingle_woofer, :toofer

        x = entity.dingle_woofer
        x.should eql :toofer

        x = entity.property_value_via_symbol :dingle_woofer
        x.should eql :toofer

      end
    end

    context "`required` `field`" do

      before :all do

        class CF_Field_Required

          Subject_.call self,
            :readable, :field, :foo,
            :field, :bar,
            :globbing, :processor, :initialize,
            :required, :readable, :field, :baz
        end

      end

      it "loads" do
      end

      it "when provide all properties" do
        entity = CF_Field_Required.new :foo, :FO, :bar, :BR, :baz, :BZ
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
        entity = CF_Field_Required.new :baz, :hi
        entity.baz.should eql :hi
        entity.foo.should be_nil
      end

      it "when required field missing" do

        _rx = /\Amissing required field - 'baz'\z/

        begin
          CF_Field_Required.new
        rescue ::ArgumentError => e
        end

        e.message.should match _rx
      end
    end

    context "`required` `field` (but field is not readable)" do

      before :all do

        class CF_Field_Required_

          Subject_.call self,
            :required, :field, :foo,
            :globbing, :processor, :initialize
        end
      end

      it "when yes" do
        x = CF_Field_Required_.new :foo, :F
        x.instance_variable_get( :@foo ).should eql :F
      end

      it "when no" do

        _rx = /\Amissing required field - 'foo'\z/

        begin
          CF_Field_Required_.new
        rescue ::ArgumentError => e
        end

        e.message.should match _rx
      end
    end
  end
end
