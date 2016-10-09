require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] autoloader core" do

    context "for a const_missing, in order it will try:" do

      it "1. the eponymous leaf file" do

        # (#tombstone-A: no more name correction)

        _x = TS_::FIXTURE
        _x == :_yes_ || fail
        _x = TS_::FIXTURE
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

        _rx = %r(\A.+::TestSupport::Foxture #{
          }must be but does not appear to be defined in #{
           }.+test/foxture\.rb\z)

        begin
          TS_::Foxture
        rescue _name_error => e
        end

        e.message =~ _rx || fail
      end

      it "if no corefile, AUTO VIVIFY BRANCH MODULE" do
        _mod = fixture_directories_
        _yes = _mod.dir_path
        _yes || fail
      end

      it "if corefile, use that" do
        _mod = fixture_directories_
        mod_ = _mod::Five
        _x = mod_::OHAI
        _x == :_hey_ || fail
        mod_.dir_path || fail
      end

      it "2. when corefile, iff module then autoloaderized" do
        fixture_directories_::Thrtn_Herdless::Terxt
      end

      it "4. for a branch node, load any file (like even core.rb)" do
        fixture_directories_::NINE::Peripheral == :_nine_ || fail
      end

      it "4. even if no corefile and no eponymous file, autovivify (this changed)" do

        # (this changed at #tombstone-B)

        _mod = fixture_directories_
        mod_ = _mod::Ten
        _hi = mod_.dir_path
        /\bten\z/ =~ _hi || fail
      end

      it "insonconsistent const casing is not allowed" do

        # (this changed at #tombstone-B)

        # (the camel name is "correct")

        mod = fixture_directories_
        mod_camel = mod::SixBersic
        mod_camel.name =~ /::FixtureDirectories::SixBersic\z/ || fail

        begin
          mod::Six_Bersic
        rescue _name_error => e
        end

        e.message =~ /\Aincon.+\( \(then:\) SixBersic \(now:\) Six_Ber/ || fail

        # (not shown here but if you then try to reach the asset value in the
        # asset fixture file, the same error will be raised again because of
        # how it is cased in the file (the same way in the "correct" (but
        # error-raising) way here.)
      end

      it "inheritence - child of autoloady parent" do

        mod = fixture_directories_::Seven_Son::Child
        mod.dir_path =~ %r(/seven-son/child) || fail
        mod::Foo::YEP == :_yep_ || fail
      end

      # (test removed at #tombsone-A - "experimental trick with correction")

      it "collateral - nodes loaded along the way still get enhanced" do

        _mod_a = fixture_directories_::Eight_HERDLESS::CIL
        _mod_b = _mod_a::Erkshern
        _x = _mod_b::ME
        _x == :_ok_you_ || fail
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
# #tombstone: #tombstone-A: no more name correction #tombstone-B: not autovivifying
