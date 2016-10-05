require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] autoloader \"boxxy\"" do

    context "this is a live test, must happen in one big story" do

      before :all do

        module TS_::FixtureTreesVolatile::One
          LOL = nil
          Autoloader_[ self, :boxxy ]
        end
      end

      it "names are inferred then corrected. 'const_defined?' is fuzzy." do

        mod = _subject_module

        _a = mod.constants
        _a == %i( LOL Ncsa_Spy ) || fail

        mod.const_defined?( :NCSA_SPY ) || fail

        _x = mod.const_get :NCsa_spy, false
        _x == :_hello_yes_this_is_NCSA_Spy_ || fail

        mod.constants == %i( LOL NCSA_Spy ) || fail
      end

      it "won't trip up and let invalid names pass, despite distillation" do

        _rx = /\Awrong constant name/

        mod = _subject_module
        begin
          mod.const_defined?( :nCsA_spy )
        rescue ::NameError => e  # for now we need to catch the platform name error
        end

        e.message =~ _rx || fail
      end

      def _subject_module
        TS_::FixtureTreesVolatile::One
      end
    end

    context "when there is no directory, things are ok", wip: true do

      before :all do
        module TS_::Fuxtures
          Wazlo = :heya
          Autoloader_[ self, :boxxy ]
        end
      end

      it "boxxy won't break just because there is no dir" do
        mod = _subject_module
        a = mod.constants
        b = mod.constants
        a == b || fail
        a == %i( Wazlo ) || fail
        a.object_id == b.object_id  && fail
      end

      it "but still gives helpful error message on no ent" do

        _rx = %r(\buninit.+const.+Wizzlo and no directory\b)

        mod = _subject_module
        begin
          mod.const_get :Wizzlo, false
        rescue Autoloader_::NameError => e
        end

        e.message =~ _rx || fail
      end

      def _subject_module
        TS_::Fuxtures
      end
    end

    context "if one of the expected consts is not set in the file" do

      before :all do
        module TS_::FixtureTreesVolatile::Two
          Autoloader_[ self, :boxxy ]
        end
      end

      it "it will say it is defined, and then BOOM - X" do

        mod = _subject_module

       _rx = %r(\A[A-Za-z:]+#{
          }::FixtureTreesVolatile::Two::Lorca #{
           }must be but does not appear to be defined in #{
            }.+/fixture-trees-volatile/two/lorca\.rb)

        mod.const_defined?( :Lorca, false ) || fail

        mod.dir_path || fail

        begin
          mod::Lorca
        rescue Autoloader_::NameError => e
        end

        e.message =~ _rx || fail
      end

      def _subject_module
        TS_::FixtureTreesVolatile::Two
      end
    end

    context "boxxy does NOT autoloaderize downwards" do

      before :all do
        module TS_::FixtureTreesVolatile::Three
          Autoloader_[ self, :boxxy ]
        end
      end

      it "it only happens the once" do

        mod = TS_::FixtureTreesVolatile::Three

        mod.constants == %i( Level_1 ) || fail

        lvl1 = mod::Level_1

        _yes = lvl1.const_defined? :Level_2
        _yes && fail

        lvl2 = lvl1::Level_2

        _yes = lvl2.const_defined? :Leaf_3
        _yes && fail

        _leaf3 = lvl2::Leaf_3
        _x = _leaf3::SOME_CONST

        _x == :some_val || fail
      end
    end

    context "when there is a fuzzy pair (file and folder) of entries" do

      before :all do
        module TS_::FixtureTreesVolatile::Four
          Autoloader_[ self, :boxxy ]
        end
      end

      it "it works" do
        _i_a = TS_::FixtureTreesVolatile::Four.constants
        _i_a == %i( Red_Leader ) || fail  # wrong case b.c not loaded eek
      end
    end
  end
end
