require_relative '../../../../test-support'

module Skylab::Brazen::TestSupport::PropertyStack_Namespace_1____

  ::Skylab::Brazen::TestSupport.lib_(
    :property_stack_models_common_frame
  ).prepare_sandbox self

  describe "[br] property - stack - common frame" do

    context "you can define [non-]memoized { proc | inline } methods" do

      before :all do
        class Foo
          Subject_.call self,
            :proc, :foo, -> do
               d = 0
               -> { d += 1 }
            end.call,
            :memoized, :proc, :bar, -> do
              d = 0
              -> { d += 1 }
            end.call,
            :inline_method, :bif, -> do
              "_#{ foo }_"
            end,
            :memoized, :inline_method, :baz, -> do
              "<#{ foo }>"
            end
        end
      end
      let :foo do
        Foo.new { }
      end
      it "accessing a field's value when it is an ordinary proc" do
        foo.foo.should eql 1
        foo.foo.should eql 2
      end
      it "accessing a field's value when it is a memoized proc" do
        foo.bar.should eql 1
        foo.bar.should eql 1
      end
      it "accessing a field's value when it is an \"inline method\"" do
        foo.bif.should eql "_3_"
        foo.bif.should eql "_4_"
      end
      it "accessing a field's value when it is a memoized inline method" do
        foo.baz.should eql "<5>"
        foo.baz.should eql "<5>"
        foo.baz.object_id.should eql foo.baz.object_id
      end
    end
    context "[ `required` ] `field`s -" do

      before :all do
        class Bar
          Home_::Property::Stack.common_frame self,
            :globbing, :processor, :initialize,
            :required, :readable, :field, :foo,
            :readable, :field, :bar
        end
      end

      it "failing to provide a required field triggers an argument error" do

        _rx = ::Regexp.new "\\Amissing\\ required\\ field\\ \\-\\ 'foo'\\z"
        begin
          Bar.new
        rescue ::ArgumentError => e
        end
        e.message.should match _rx
      end

      it "passing nil is considered the same as not passing an argument" do

        _rx = ::Regexp.new "\\Amissing\\ required\\ field\\ \\-\\ 'foo'\\z"

        begin
          Bar.new :foo, nil
        rescue ::ArgumentError => e
        end

        e.message.should match _rx
      end

      it "passing false is not the same as passing nil, passing false is valid." do
        Bar.new( :foo, false ).foo.should eql false
      end
      it "you can of course pass nil as the value for a non-required field" do
        Bar.new( :foo, :x, :bar, nil ).bar.should eql nil
      end
    end
  end
end
