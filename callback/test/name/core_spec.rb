require_relative 'test-support'

module Skylab::Callback::TestSupport::Name

  describe "[ca] name" do

    context "const" do

      context "as variegated symbol" do

        it "Foo_Bar => foo-bar" do

          expect :Foo_Bar, :foo_bar
        end

        it "Foo_Bar_XL => foo-bar-XL" do

          expect :Foo_Bar_XL, :foo_bar_XL
        end

        it "MPC_cone => MPC-cone" do

          expect :MPC_cone, :MPC_cone
        end

        it "TOP_Secret___ => TOP_secret" do

          expect :TOP_Secret___, :TOP_secret
        end
      end

      context "camel case" do

        it "FreiTag => frei-tag" do

          expect :FreiTag, :frei_tag
        end
      end

      def expect sym, s

        _nf = subject.via_const_symbol sym
        _s = _nf.as_variegated_symbol
        _s.should eql s
      end
    end

    context "from variegated symbol" do

      it "as_const" do

        _nf = subject.via_variegated_symbol :merk_FS_lala
        _sym = _nf.as_const
        _sym.should eql :Merk_FS_Lala
      end
    end

    def subject
      Home_::Name
    end
  end
end
