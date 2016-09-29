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

        _ = _subject %i( bar_biff baz ), X_a_c_Foo1
        _ == :some_x or fail
      end

      it "& it has an explicit form of syntax (tight form, remote ctx)" do

        _ = _subject(
          :from_module, X_a_c_Foo1,
          :const_path, %i( bar_biff baz ),
        )
        _ == :some_x or fail
      end

      it "& it is infinitely extensible (one day) (long form, local ctx)" do

        _rx = %r(\Aname_error: uninitialized constant #{
          }[A-Za-z:]+::X_a_c_Foo1::Bar_Biff::\( ~ cowabungaa \) \(cowabungaa\))

        _ = _subject(

          :from_module, X_a_c_Foo1,
          :const_path, %i( bar_biff cowabungaa bowzer ),

        ) do | name_error_event |

          name_error = name_error_event.to_exception

          "name_error: #{ name_error.message } (#{ name_error.name })"
        end

        _ =~ _rx or fail
      end

      it "invalid const name when just normal style - name error X" do

        begin
          _subject %i( 123fml ), X_a_c_Foo1
        rescue ::NameError => e
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

        ( ::NameError === e ) or fail
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

        pair = _subject(

          :const_path, %i( NCSASpy ),
          :from_module, X_a_c_Foo3,
          :result_in_name_and_value,
        )

        pair.name_x == :NCSA_Spy or fail
        pair.value_x == :x or fail
      end
    end

    # (#tombstone for that one hack)

    context "with an (autolaoded) node that resolves its own dir_pathname" do

      it "make sure autoloading is not broken at this node" do
        fixture_tree_.dir_pathname
      end

      it "(loads, has dir_pathname, ancestor chain is not mutated)" do

        mod = fixture_tree_::One_Skorlab

        mod.singleton_class.ancestors[ 1 ] == ::Module or fail  # eew

        _ = mod.dir_path
        _ =~ %r(fixture-tree/one-skorlab\z) || fail
      end

      it "with a node that is not itself designed to autoload" do

        pair = _subject(
          :result_in_name_and_value,
          :from_module, fixture_tree_::One_Skorlab,
          :path_x, :Infermation_Terktix,
        )

        pair.name_x == :InfermationTerktix or fail
        pair.value_x.name =~ %r(FixtureTree::One_Skorlab::InfermationTerktix\z) or fail
      end

      it "the same as above but value only (name correction)" do

        _mod = _subject(
          :from_module, fixture_tree_::Two_Skorlab,
          :path_x, :Infermation_Terktix,
        )

        _mod.name =~ %r(FixtureTree::Two_Skorlab::InfermationTerktix\z) or fail
      end

      it "if you want name correction on a boxxy module, you need one option" do

        _a = fixture_tree_

        _b = _a::Tre_Skorlab  # #spot-2

        _pair = _subject(
          :from_module, _b,
          :path_x, :Infermation_Terktix,
          :correct_the_name,
          :result_in_name_and_value,
        )

        _pair.name_x == :InfermationTerktix or fail
      end
    end

    it "(reproduction)" do

      # do not autoload this node, because we want the creation of its
      # entry tree to be its own and not its parent's

      _path = fixture_tree_.dir_path

      _load_me = ::File.join _path, 'for-skerlerb/core.rb'

      load _load_me

      _Skylab = fixture_tree_::For_Skerlerb

      _hi = _subject %i( Infermershern ), _Skylab

      _hi.name =~ %r(::Infermershern\z) or fail
    end

    def _subject * x_a, & x_p

      # (all the testing in this file forgoes the surface entrypoint
      # for the performer, but meh that's not the focus)

      Home_::Autoloader::Const_Reduction__.new( x_a, & x_p ).execute
    end

    def fixture_tree_
      TS_::FixtureTree
    end
  end
end

# :+#tombsone: integration with autoloader methods
# :+#tombstone: curry
# :+#tombstone: original issue
