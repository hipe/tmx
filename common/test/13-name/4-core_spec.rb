require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] name" do

    context "via const" do

      context "as variegated symbol" do

        it "Foo_Bar => foo-bar" do

          want :Foo_Bar, :foo_bar
        end

        it "Foo_Bar_XL => foo-bar-XL" do

          want :Foo_Bar_XL, :foo_bar_XL
        end

        it "MPC_cone => MPC-cone" do

          want :MPC_cone, :MPC_cone
        end

        it "TOP_Secret___ => TOP_secret" do

          want :TOP_Secret___, :TOP_secret
        end
      end

      context "via const in camel case as variegated symbol" do

        it "FreiTag => frei-tag" do

          want :FreiTag, :frei_tag
        end
      end

      def want sym, s

        _nf = subject.via_const_symbol sym
        _s = _nf.as_variegated_symbol
        expect( _s ).to eql s
      end
    end

    context "via variegated symbol" do

      it "as_const" do

        _nf = subject.via_variegated_symbol :merk_FS_lala
        _sym = _nf.as_const
        expect( _sym ).to eql :Merk_FS_Lala
      end
    end

    context "via slug" do

      define_singleton_method :shared_subject, TestSupport_::DANGEROUS_MEMOIZE

      shared_subject :_name do
        subject.via_slug 'wing-ding--'
      end

      it "as const" do
        _expect :as_const, :Wing_Ding__
      end

      it "as camelcase const" do
        _expect :as_camelcase_const_string, "WingDing__"
      end

      def _expect m, c
        _exp = _name.send m
        expect( _exp ).to eql c
      end
    end

    def subject
      Home_::Name
    end
  end
end
