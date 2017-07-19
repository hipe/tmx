require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] autoloader \"boxxy\"" do

    define_singleton_method :shared_subject, TestSupport_::DANGEROUS_MEMOIZE

    context "this is a live test, must happen in one big story" do

      before :all do

        module TS_::FixtureTreesVolatile::One
          LOL = nil
          Autoloader_[ self, :boxxy ]
        end
      end

      it "names are inferred then corrected." do
        # #cov1.2

        mod = _subject_module

        _a = mod.constants
        _a == %i( LOL Ncsa_Spy ) || fail

        _x = mod.const_get :NCsa_spy, false
        _x == :_hello_yes_this_is_NCSA_Spy_ || fail

        # when upgraded ruby from 2.2.3 to 2.4.1, order is indeterminate
        these = mod.constants
        these.sort!
        these == %i( LOL NCSA_Spy ) || fail
      end

      def _subject_module
        TS_::FixtureTreesVolatile::One
      end
    end

    context "when there is no directory, things are ok" do

      shared_subject :_subject_module do
        module TS_::X_a_b_Module1
          Wazlo = :heya
          Autoloader_[ self, :boxxy ]
          self
        end
      end

      it "boxxy won't break just because there is no dir" do
        # :#cov1.3
        mod = _subject_module
        a = mod.constants
        b = mod.constants
        a == b || fail
        a == %i( Wazlo ) || fail
        a.object_id == b.object_id  && fail
      end

      it "but still gives helpful error message on no ent" do
        # :#cov1.4

        _rx = %r(\buninit.+const.+Wizzlo and no directory\b)

        mod = _subject_module
        begin
          mod.const_get :Wizzlo, false
        rescue Autoloader_::NameError => e
        end

        e.message =~ _rx || fail
      end
    end

    context "if one of the expected consts is not set in the file" do

      before :all do
        module TS_::FixtureTreesVolatile::Two
          Autoloader_[ self, :boxxy ]
        end
      end

      it "it will say it is defined, and then BOOM - X" do
        # :#cov1.5

        mod = _subject_module

        _hi = mod.constants

        _hi.include?( :Lorca ) || fail

        _rx = %r(\A[A-Za-z:]+#{
          }::FixtureTreesVolatile::Two::Lorca #{
           }must be but does not appear to be defined in #{
            }.+/fixture-trees-volatile/two/lorca\.rb)

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

        # :#cov1.6

        mod = TS_::FixtureTreesVolatile::Three

        mod.constants == %i( Level_1 ) || fail

        lvl1 = mod::Level_1

        _yes = lvl1.const_defined? :Level_2, false
        _yes && fail

        lvl2 = lvl1::Level_2

        _yes = lvl2.const_defined? :Leaf_3, false
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

    context "integration with const-reduce" do

      it "if you want name correction on a boxxy module, you need one option" do

        _a = TS_::FixtureTree

        _b = _a::Tre_Skorlab  # #spot-2

        _pair = Autoloader_::Value_via_ConstPath.call_by do |o|
          o.from_module = _b
          o.const_path = :Infermation_Terktix  # this is conventioned incorrectly
          o.result_in_name_and_value
          o.file_tree_cache_by = Autoloader_::File_tree_cache__
        end

        _pair.correct_const_symbol == :InfermationTerktix || fail
      end
    end

    context "integration with stowaways (SORT OF)!" do

      shared_subject :_custom_tuple do

        _a = TS_::FixtureDirectories
        mod = _a::SxtnBoxstow
        _constants = mod.constants
        [ mod, _constants ]
      end

      # #cov1.7

      it "the constants have the right essential constituency" do

        const_a = _these_two

        2 == const_a.length || fail

        _actual_h = ::Hash[ const_a.map { |c| [ Home_::Distill[ c ], nil ] } ]

        _expect_h = {
          Home_::Distill[ "shimmy_jimmy" ] => nil,
          Home_::Distill[ "shammy_jammy" ] => nil,
        }

        _hashes_have_same_keys _actual_h, _expect_h
      end

      it "the one constant uses the stowaway name, trumping the filesystem node" do

        _actual_h = ::Hash[ _these_two.map { |c| [ c, nil ] } ]

        _expect_h = {
          ShimmyJIMMY: nil,
          Shammy_Jammy: nil,
        }

        _hashes_have_same_keys _actual_h, _expect_h
      end

      it "the constant names are ordered with the stowaway const(s) first " do

        _these_two == %i( ShimmyJIMMY Shammy_Jammy ) || fail
      end

      shared_subject :_these_two do
        _the_module.constants
      end

      it "the ordinary asset loads (use inaccurately inferred name)" do
        _mod = _the_module
        _xx = _mod::Shammy_Jammy  # name is as inferred, name is not as is
        _xx == :_yes_ || fail
      end

      it "the stowed-away asset loads (use name in stowaway entry)" do
        # :#cov1.8
        _mod = _the_module
        _mod_ = _mod::ShimmyJIMMY
        _mod_.hello_shimmy_jimmy
      end

      def _the_module
        TS_::FixtureDirectories::SxtnBoxstow
      end
    end

    # ==

    def _hashes_have_same_keys actual_h, expect_h

      p = Home_.lib_.basic::Hash::Validate_superset
      p[ expect_h, actual_h.keys ]
      p[ actual_h, expect_h.keys ]
    end

    # ==
    # ==
  end
end
# #tombstone: `const_defined?` is no longer overridden with fuzziness
# #tombstone: `correct_the_name` now happens always
