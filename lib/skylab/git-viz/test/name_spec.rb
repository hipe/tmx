require_relative 'test-support'

module Skylab::GitViz::TestSupport

  describe "[gv] name" do

    def self.memoize i, & p
      p_ = -> do x = p[] ; p_ = -> { x } ; x end
      define_method i do p_[] end
    end

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

      def expect i, s
        _name = GitViz_::Name_.via_const i
        _name.as_doc_slug.should eql s
      end
    end

    context "from variegated symbol" do

      memoize :name do
        GitViz_::Name_.via_variegated_symbol :merk_FS
      end

      it "as_const" do
        name.as_const.should eql :Merk_FS
      end
    end
  end
end
