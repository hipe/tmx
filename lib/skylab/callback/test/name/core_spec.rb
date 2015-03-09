require_relative 'test-support'

module Skylab::Callback::TestSupport::Name

  describe "[ca] name" do

    context "from const" do

      context "simplified conventional" do

        it "Foo_Bar => foo-bar" do
          expect :Foo_Bar, 'foo-bar'
        end

        it "Foo_Bar_XL => foo-bar-XL" do
          expect :Foo_Bar_XL, 'foo-bar-XL'
        end

        it "MPC_cone => MPC-cone" do
          expect :MPC_cone, 'MPC-cone'
        end
      end

      context "camel case" do
        it "FreiTag => frei-tag" do
          expect :FreiTag, 'frei-tag'
        end
      end

      def expect sym, s
        subject.via_const( sym ).as_doc_slug.should eql s
      end
    end

    context "from variegated symbol" do

      it "as_const" do
        subject.via_variegated_symbol( :merk_FS ).as_const.should eql :Merk_FS
      end
    end

    def subject
      Callback_::Name
    end
  end
end
