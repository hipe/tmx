require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] autoloader core" do

    context "for a const_missing, in order it will try:" do

      it "1. the eponymous leaf file (with a correction)" do
        _x = TS_::Fixture
        _x == :_yes_ || fail
        _x = TS_::Fixture
        _x == :_yes_ || fail
      end

      it "1. random name - X" do

        _rx = %r(\Auninitialized constant [A-Za-z:]+::Whatever #{
          }and no directory\[file\] .+/whatever\[\.rb\]\z)

        begin
          TS_::Whatever
        rescue _name_error => e
        end

        e.message =~ _rx || fail
      end

      it "1. the eponymous leaf who fails to define - X" do

        _rx = %r(\A.+::TestSupport::\( ~ foxture \) #{
          }must be but does not appear to be defined in #{
           }.+test/foxture\.rb\z)

        begin
          TS_::Foxture
        rescue _name_error => e
        end

        e.message =~ _rx || fail
      end

      it "3. (2 is pre-requisite on 3). the dir (but no core.#{}rb)" do
        fixture_directories_.dir_path || fail
      end

      it "2. the dir with a core.#{}rb" do
        fixture_directories_::Five::OHAI.should eql :_hey_
        fixture_directories_::Five::OHAI.should eql :_hey_
        fixture_directories_::Five.dir_path || fail
      end

      it "2. the dir with a core.#{}rb that was loaded adjunctly" do
        TS_::FixtureTree.dir_path || fail
      end

      it "2. WHATEVER" do
        fixture_directories_::Thrtn_Herdless::Terxt
      end

      it "4. for a branch node, load any file (like even core.rb)" do
        fixture_directories_::NINE::Peripheral.should eql :_nine_
      end

      it "4. but when a directory has no valid leaf or branch" do

        _rx = %r(\Acannot determine correct #{
          }casing and scheme for [:A-Za-z]+::FixtureDirectories::\( ~ ten \) - #{
           }directory is effectively empty: .+/fixture-directories/ten\z)

        begin
          fixture_directories_::Ten
        rescue _name_error => e
        end

        e.message =~ _rx || fail
      end

      it "autovivifying as we know it either does or doesn't happen still" do

        _mod = fixture_directories_::SixBersic
        _mod.name =~ %r(::FixtureDirectories::Six_Bersic) || fail
      end

      it "inheritence - child of autoloady parent" do

        mod = fixture_directories_::Seven_Son::Child
        mod.dir_path =~ %r(/seven-son/child) || fail
        mod::Foo::YEP == :_yep_ || fail
      end

      it "experimental trick with correction" do

        _mod = fixture_directories_::Four

        x = fixture_directories_::Four::Npl::Ne::Numbers

        x.name == "#{ TS_.name }::FixtureDirectories::Four::NPL::NE::Numbers" || fail
      end

      it "collateral - nodes loaded along the way still get enhanced" do

        _mod_a = fixture_directories_::Eight_HERDLESS::CIL
        _mod_b = _mod_a::Erkshern
        _x = _mod_b::Me
        _x == :_ok_you_ || fail
      end

      it "a stowaway path that does not isomorph to a node is OK.." do
        _Face = fixture_directories_::Elvn_Ferce
        _Face::TerstSerppert
      end

      it "..and make sure that such a node can set its own dirpn" do
        _Face = fixture_directories_::Elvn_Ferce
        _TS = _Face::TerstSerppert
        _TS::CIL
      end

      it "entry trees get hackishly built" do
        _TernMern = fixture_directories_::Frtrn_TM
        _TernMern::Kernel_::YEP.should eql :yep
      end

      it "at the boundary of an integration with old :+[#027]" do
        fixture_directories_::Twlv_DLI::Glient
      end
    end

    def _name_error
      Home_::Autoloader::NameError
    end

    def fixture_directories_
      TS_::FixtureDirectories
    end
  end
end
