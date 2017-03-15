require_relative '../../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] attributes - stack - common frame - core" do

    TS_[ self ]
    use :memoizer_methods

    context "enhance a class as a `common_frame`" do

      before :all do
        class X_a_s_cf_c_Foo
          TS_::Common_Frame.lib.call self,
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

      shared_subject :foo do
        X_a_s_cf_c_Foo.new { }
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

        class X_a_s_cf_c_Bar
          TS_::Common_Frame.lib.call self,
            :globbing, :processor, :initialize,
            :required, :readable, :field, :foo,
            :readable, :field, :bar
        end
      end

      it "failing to provide a required field triggers an argument error" do

        _rx = ::Regexp.new "\\Amissing\\ required\\ field\\ 'foo'\\z"

        begin
          X_a_s_cf_c_Bar.new
        rescue ArgumentError => e
        end

        e.message.should match _rx
      end

      it "passing nil is considered the same as not passing an argument" do

        _rx = ::Regexp.new "\\Amissing\\ required\\ field\\ 'foo'\\z"

        begin
          X_a_s_cf_c_Bar.new( :foo, nil )
        rescue ArgumentError => e
        end

        e.message.should match _rx
      end

      it "passing false is not the same as passing nil, passing false is valid." do
        ( X_a_s_cf_c_Bar.new( :foo, false ).foo ).should eql false
      end

      it "you can of course pass nil as the value for a non-required field" do
        ( X_a_s_cf_c_Bar.new( :foo, :x, :bar, nil ).bar ).should eql nil
      end
    end
  end
end
