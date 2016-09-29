require_relative '../../../test-support'

module Skylab::Fields::TestSupport

  describe "[br] property - stack - common frame - integrate with entity" do

    before :all do

      class X_a_s_cf_Inter_1

        Home_::Attributes::Stack::Common_Frame.call self,
          :globbing, :processor, :initialize,
          :readable, :field, :foo,
          :required, :readable, :field, :bar

        Home_.lib_.brazen::Entity.call self do
          def biz
            @biz_x = gets_one_polymorphic_value
            true
          end
        end

        attr_reader :biz_x
      end
    end

    it "loads" do
    end

    it "property names look good" do
      _subject_class.properties.get_names.should eql [ :foo, :bar, :biz ]
    end

    it "required fields still bork" do

      _rx = /\Amissing required field - 'bar'/

      begin
        _subject_class.new
      rescue ::ArgumentError => e
      end

      e.message =~ _rx || fail
    end

    it "works with all" do
      foo = _subject_class.new :biz, :B, :foo, :F, :bar, :A
      [ foo.foo, foo.bar, foo.biz_x ].should eql %i| F A B |
    end

    it "works with one" do
      foo = _subject_class.new :bar, :A
      [ foo.foo, foo.bar, foo.biz_x ].should eql [ nil, :A, nil ]
    end

    def _subject_class
      X_a_s_cf_Inter_1
    end
  end
end
