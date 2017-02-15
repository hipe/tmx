require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] autoloader const reduce is an improvement on boxxy" do

    context "in that from the ground up it does not assume a mutated module" do

      before :all do
        module X_a_c_Foo1
          module Bar_Biff
            Baz = :some_x
          end
        end
      end

      it "normative use-case" do

        _ = _call_by do |o|
          o.from_module = X_a_c_Foo1
          o.const_path = %i( bar_biff baz )
        end
        _ == :some_x or fail
      end

      it "& it is infinitely extensible (one day) (long form, local ctx)" do

        _rx = %r(\Aname_error: uninitialized constant #{
          }[A-Za-z:]+::X_a_c_Foo1::Bar_Biff::\( ~ cowabungaa \))

        _ = _call_by do |o|
          o.from_module = X_a_c_Foo1
          o.const_path = %i( bar_biff cowabungaa bowzer )
          o.receive_name_error_by = -> name_error_event do

          name_error = name_error_event.to_exception

          "name_error: #{ name_error.message } (#{ name_error.name })"
        end ; end

        _ =~ _rx or fail
      end

      it "invalid const name when just normal style - name error X" do

        begin
          _subject %i( 123fml ), X_a_c_Foo1
        rescue _name_error_class => e
        end

        _expect_same_name_error e
      end

      it "invalid const name and your else block takes one arg - o" do

        ev = nil
        _ = _subject %(123fml), X_a_c_Foo1 do |ev_|
          ev = ev_ ; :hi
        end

        _ == :hi or fail
        _expect_same_name_error ev.to_exception
      end

      def _expect_same_name_error e

        ( _name_error_class === e ) or fail
        e.message =~ %r(\Awrong constant name '123fml' for const reduce\z) or fail
      end

      it "invalid const name and your else block takes no args - X" do

        _x = _subject %i( 123fml ), X_a_c_Foo1 do :x end

        :x == _x or fail
      end

      it "const not found and your else block takes one arg - o" do

        ev = nil
        _ = _subject %i( bar_biff boon_doggle bizzle ), X_a_c_Foo1 do |ev_|
          ev = ev_ ; :hi
        end

        _ == :hi or fail
        ev.mod == X_a_c_Foo1::Bar_Biff or fail
        ev.name == :boon_doggle or fail
      end

      it "const not found and your else block takes no args - o" do

        _ = _subject %i(who_hah), X_a_c_Foo1 do :x end
        _ == :x or fail
      end
    end

    context "currently it tries 2 name conventions" do

      before :all do
        module X_a_c_Foo2
          module BarBiff
            NCSA_Spy = :some_y
          end
        end
      end

      it "and you have no say in the matter" do

        _ = _subject %i( bar_biff NCSA_spy ), X_a_c_Foo2
        _ == :some_y or fail
      end
    end

    context "transitional hacks - result in name and value.." do

      before :all do
        module X_a_c_Foo3
          NCSA_Spy = :x
          Autoloader_[ self ]
        end
      end

      it ".. which allows you correct a name" do

        pair = _call_by do |o|
          o.from_module = X_a_c_Foo3
          o.const_path = %i( NCSASpy )
          o.result_in_name_and_value
        end

        pair.name_x == :NCSA_Spy or fail
        pair.value_x == :x or fail
      end
    end

    # (#tombstone for that one hack)

    context "with an (autolaoded) node that resolves its own dir_path" do

      it "make sure autoloading is not broken at this node" do
        fixture_tree_.dir_path || fail
      end

      it "(loads, has dir_path, ancestor chain is not mutated)" do

        mod = fixture_tree_::One_Skorlab

        mod.singleton_class.ancestors[ 1 ] == ::Module or fail  # eew

        _ = mod.dir_path
        _ =~ %r(fixture-tree/one-skorlab\z) || fail
      end

      it "with a node that is not itself designed to autoload" do

        pair = _call_by_plus_real_life_file_tree_cache do |o|

          o.from_module = fixture_tree_::One_Skorlab
          o.const_path = :Infermation_Terktix
          o.result_in_name_and_value
        end

        pair.name_x == :InfermationTerktix or fail
        pair.value_x.name =~ %r(FixtureTree::One_Skorlab::InfermationTerktix\z) or fail
      end

      it "the same as above but value only (name correction)" do

        _mod = _call_by_plus_real_life_file_tree_cache do |o|
          o.from_module = fixture_tree_::Two_Skorlab
          o.const_path = :Infermation_Terktix
        end

        _mod.name =~ %r(FixtureTree::Two_Skorlab::InfermationTerktix\z) or fail
      end
    end

    it "(reproduction)" do

      # do not autoload this node, because we want the creation of its
      # entry tree to be its own and not its parent's

      _path = fixture_tree_.dir_path

      _load_me = ::File.join _path, 'for-skerlerb/core.rb'

      load _load_me

      _Skylab = fixture_tree_::For_Skerlerb

      _hi = _subject_plus_real_file_tree_cache %i( Infermershern ), _Skylab

      _hi.name =~ %r(::Infermershern\z) or fail
    end

    context "`autoloaderize`" do

      context "without this flag, the loaded thing is not autoloaderized" do

        def _const_path
          :FIV_SAME_TWEEDLE_DEE
        end

        def _yes_autoloaderize
          false
        end

        it "sic" do
          _loaded_subject.respond_to?( :dir_path ) && fail
        end
      end

      context "with this flag, the loaded thing is autoloaderized" do

        def _const_path
          :FIV_SAME_TWEEDLE_DUM
        end

        def _yes_autoloaderize
          TRUE
        end

        it "sic" do
          _loaded_subject.respond_to?( :dir_path ) || fail
        end
      end

      def _loaded_subject

        _from_here = fixture_tree_
        _use_const_path = _const_path


        _mod = _call_by_plus_real_life_file_tree_cache do |o|
          o.from_module = _from_here
          o.const_path = _use_const_path
          if _yes_autoloaderize
            o.autoloaderize
          end
        end

        _mod  # #todo
      end
    end

    def _subject_plus_real_file_tree_cache cp, fm, & p
      _call_by_plus_real_life_file_tree_cache do |o|
        o.from_module = fm
        o.const_path = cp
        o.receive_name_error_by = p
      end
    end

    def _subject cp, fm, & p
      _call_by do |o|
        o.from_module = fm
        o.const_path = cp
        o.receive_name_error_by = p
      end
    end

    def _call_by_plus_real_life_file_tree_cache
      _call_by do |o|
        yield o
        o.file_tree_cache_by = Autoloader_::File_tree_cache__
      end
    end

    def _call_by
      Home_::Autoloader::Value_via_ConstPath.call_by do |o|
        o.file_tree_cache_by = :_no_see_CO_
        yield o
      end
    end

    def _name_error_class
      Autoloader_::NameError
    end

    def fixture_tree_
      TS_::FixtureTree
    end
  end
end
# #tombstone-D: bye bye iambic interface
# :+#tombsone: integration with autoloader methods
# :+#tombstone: curry
# :+#tombstone: original issue
