require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] stack - common frame - integrate with entity" do

    before :all do

      class X_cf_Inter_1

        TS_::Common_Frame.lib.call self,
          :globbing, :processor, :initialize,
          :readable, :field, :foo,
          :required, :readable, :field, :bar

        Home_::Entity.call self do
          def biz
            @biz_x = gets_one
            true
          end
        end

        attr_reader :biz_x
      end
    end

    it "loads" do
    end

    it "property names look good" do
      _subject_class.properties.get_keys.should eql [ :foo, :bar, :biz ]
    end

    it "required fields still bork" do

      begin
        _subject_class.new
      rescue ::ArgumentError => e
      end

      expect_missing_required_message_without_newline_ e.message, :bar
    end

    it "works with all" do
      foo = _subject_class.new :biz, :B, :foo, :F, :bar, :A
      [ foo.foo, foo.bar, foo.biz_x ].should eql %i| F A B |
    end

    it "works with one" do
      foo = _subject_class.new :bar, :A
      [ foo.foo, foo.bar, foo.biz_x ].should eql [ nil, :A, nil ]
    end

    define_method :expect_missing_required_message_without_newline_, Common_Frame.definition_for_etc

    def _subject_class
      X_cf_Inter_1
    end
  end
end
