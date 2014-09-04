require_relative 'test-support'

module Skylab::Callback::TestSupport::Autoloader

  describe "[cb] autoloader core" do

    context "for a const_missing, in order it will try:" do

      it "1. the eponymous leaf file (with a correction)" do
        _x = TS_::Fixture
        _x.should eql :_yes_
        _x = TS_::Fixture
        _x.should eql :_yes_
      end

      it "1. random name - X" do
        -> do
          TS_::Whatever
        end.should raise_error ::NameError, %r(\Auninit.+loader::Whatever #{
          }and no directory\[file\] .+loader/whatever\[\.rb\]\z)
      end

      it "1. the eponymous leaf who fails to define - X" do
        -> do
          TS_::Foxture
        end.should raise_error ::NameError, %r(\A.+::Autoloader::#{
          }\( ~ foxture \) must be but does not appear to be defined in #{
           }.+autoloader/foxture\.rb\z)
      end

      it "3. (2 is pre-requisite on 3). the dir (but no core.#{}rb)" do
        TS_::Fixtures.dir_pathname or fail
      end

      it "2. the dir with a core.#{}rb" do
        TS_::Fixtures.class  # kick
        TS_::Fixtures::Five::OHAI.should eql :_hey_
        TS_::Fixtures::Five::OHAI.should eql :_hey_
        TS_::Fixtures::Five.dir_pathname or fail
      end

      it "2. the dir with a core.#{}rb that was loaded adjunctly" do
        TS_::Const_Reduce::Fixtures.dir_pathname
      end

      it "2. WHATEVER" do
        TS_::Fixtures::Thrtn_Herdless::Terxt
      end

      it "2. inter" do  # integration of above
        _HL = TestLib_::Headless__[]
        _HL::Text
      end

      it "4. for a branch node, load any file (like even core.rb)" do
        TS_::Fixtures::NINE::Peripheral.should eql :_nine_
      end

      it "4. but when a directory has no valid leaf or branch" do
        -> do
          TS_::Fixtures::Ten
        end.should raise_error ::NameError, %r(\Acannot determine correct #{
          }casing and scheme for [:A-Za-z]+::Fixtures::\( ~ ten \) - #{
           }directory is effectively empty: .+/fixtures/ten\z)
      end

      it "autovivifying as we know it either does or doesn't happen still" do
        _mod = TS_::Fixtures::SixBersic
        _mod.name.should match %r(::Fixtures::Six_Bersic)
      end

      it "inheritence - child of autoloady parent" do
        _mod = TS_::Fixtures::Seven_Son::Child
        _mod.dir_pathname.to_path.should match %r(/seven-son/child)
        _mod::Foo::YEP.should eql :_yep_
      end

      it "experimental trick with correction" do
        _mod = TS_::Fixtures::Four
        x = TS_::Fixtures::Four::Npl::Ne::Numbers
        x.name.should eql "#{ TS_.name }#{
          }::Fixtures::Four::NPL::NE::Numbers"
      end

      it "collateral - nodes loaded along the way still get enhanced" do
        _mod_a = TS_::Fixtures::Eight_HERDLESS::CIL
        _mod_b = _mod_a::Erkshern
        _x = _mod_b::Me
        _x.should eql :_ok_you_
      end

      it "a stowaway path that does not isomorph to a node is OK.." do
        _Face = TS_::Fixtures::Elvn_Ferce
        _Face::TerstSerppert
      end


      if false  # integ
        _Face = TestLib_::Face__[]
        _Face::TestSupport
      end

      it "..and make sure that such a node can set its own dirpn" do
        _Face = TS_::Fixtures::Elvn_Ferce
        _TS = _Face::TerstSerppert
        _TS::CIL
      end

      if false  # integ
        _Face = TestLib_::Face__[]
        _TS = _Face::TestSupport
        _TS::CLI
      end

      it "entry trees get hackishly built" do
        _TernMern = TS_::Fixtures::Frtrn_TM
        _TernMern::Kernel_::YEP.should eql :yep
      end

      if false  # see if it integrates
        require 'skylab/tan-man/core'
        ::Skylab::TanMan::Kernel_
      end

      it "at the boundary of an integration with old :+[#027]" do
        TS_::Fixtures::Twlv_DLI::Glient
      end
    end
  end
end
