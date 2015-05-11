require_relative 'test-support'

module Skylab::Callback::TestSupport::Autoloader

  describe "[ca] autoloader const reduce is an improvement on boxxy" do

    context "in that from the ground up it does not assume a mutated module" do

      before :all do
        module Foo1
          module Bar_Biff
            Baz = :some_x
          end
        end
      end

      it "normative use-case" do
        Autoloader_.const_reduce( %i( bar_biff baz ), Foo1 ).should eql :some_x
      end

      it "& it is curry friendly - when called with no args you get a proc" do
        p = Autoloader_.const_reduce.curry[ %i( bar_biff baz) ]
        p[ Foo1 ].should eql :some_x
        p[ Foo1 ].should eql :some_x  # important - don't mutate the arg path
      end

      it "& it has an explicit form of syntax (tight form, remote ctx)" do
        Autoloader_.const_reduce do
          from_module Foo1
          const_path %i( bar_biff baz )
        end.should eql :some_x
      end

      it "& it is infinitely extensible (one day) (long form, local ctx)" do
        s = Autoloader_.const_reduce do |cr|
          cr.from_module Foo1
          cr.const_path %i( bar_biff cowabungaa bowzer )
          cr.else do |name_error|
            "name_error: #{ name_error.message } (#{ name_error.name })"
          end
        end
        s.should match %r(\Aname_error: uninitialized constant #{
          }[A-Za-z:]+::Foo1::Bar_Biff::\( ~ cowabungaa \) \(cowabungaa\))
      end

      it "invalid const name when just normal style - name error X" do
        -> do
          Autoloader_.const_reduce( %i( 123fml ), Foo1 )
        end.should raise_name_error
      end

      it "invalid const name and your else block takes one arg - o" do
        ex = nil
        r = Autoloader_.const_reduce %i( 123fml ), Foo1 do |ne|
          ex = ne ; :hi
        end
        r.should eql :hi
        ex.name.should eql :'123fml'
        ex.message.should eql "wrong constant name 123fml for const reduce"
      end

      it "invalid const name and your else block takes no args - X" do
        -> do
          Autoloader_.const_reduce %i( 123fml ), Foo1 do end
        end.should raise_name_error
      end

      def raise_name_error
        raise_error ::NameError,
          %r(\Awrong constant name 123fml for const reduce\z)
      end

      it "const not found and your else block takes one arg - o" do
        ex = nil
        r = Autoloader_.const_reduce(
            %i( bar_biff boon_doggle bizzle ), Foo1 ) do |ne|
          ex = ne ; :hi
        end
        r.should eql :hi
        ex.module.should eql Foo1::Bar_Biff
        ex.name.should eql :boon_doggle
      end

      it "const not found and your else block takes no args - o" do
        r = Autoloader_.const_reduce %i(who_hah), Foo1 do :x end
        r.should eql :x
      end
    end

    context "currently it tries 2 name conventions" do

      before :all do
        module Foo2
          module BarBiff
            NCSA_Spy = :some_y
          end
        end
      end

      it "and you have no say in the matter" do
        _r = Autoloader_.const_reduce %i( bar_biff NCSA_spy ), Foo2
        _r.should eql :some_y
      end
    end

    context "transitional hacks - result in name and value, assume const .." do

      before :all do
        module Foo3
          NCSA_Spy = :x
          Autoloader_[ self ]
        end
      end

      it ".. which allows you to be unobtrusive but induce fuzzily" do
        n, v = Autoloader_.const_reduce do |cr|
          cr.assume_is_defined
          cr.const_path %i( NCSA_Spy )
          cr.from_module Foo3
          cr.result_in_name_and_value
        end
        n.should eql :NCSA_Spy ; v.should eql :x
      end

      it "this puppy is also integrated in with the extension methods" do
        _x = Foo3.const_reduce do |cr|
          cr.const_path %i( NCSA_Spy )
        end
        _x.should eql :x
      end
    end

    # (#tombstone for that one hack)

    context "with an (autolaoded) node that resolves its own dir_pathname" do

      it "make sure autoloading is not broken at this node" do
        TS_::Const_Reduce::Fixtures.dir_pathname
      end

      it "(loads, has dir_pathname, ancestor chain is not mutated)" do
        mod = TS_::Const_Reduce::Fixtures::One_Skorlab
        mod.singleton_class.ancestors[ 1 ].should eql ::Module
        _s = mod.dir_pathname.to_path
        _s.should match %r(fixtures/one-skorlab\z)
      end

      it "with a node that does not autoload, also use iambic form" do
        n, v = Autoloader_.const_reduce.call_via_iambic( [
          :core_basename, nil,
          :do_assume_is_defined, false,
          :do_result_in_n_and_v, true,
          :from_module, TS_::Const_Reduce::Fixtures::One_Skorlab,
          :path_x, :Infermation_Terktix
        ] )

        n.should eql :InfermationTerktix
        v.name.should match %r(Fixtures::One_Skorlab::InfermationTerktix\z)
      end

      it "the same as above but value only (name correction)" do
        v = Autoloader_.const_reduce.call_via_iambic( [
          :core_basename, nil,
          :do_assume_is_defined, false,
          :from_module, TS_::Const_Reduce::Fixtures::Two_Skorlab,
          :path_x, :Infermation_Terktix
        ] )
        v.name.should match %r(Fixtures::Two_Skorlab::InfermationTerktix\z)
      end

      it "the same as above, but via loading" do
        v = Autoloader_.const_reduce.call_via_iambic( [
          :core_basename, nil,
          :do_assume_is_defined, false,
          :from_module, TS_::Const_Reduce::Fixtures::Tre_Skorlab,
          :path_x, :Infermation_Terktix
        ] )
        v.name.should match %r(Fixtures::Tre_Skorlab::InfermationTerktix\z)
      end
    end

    it "(reproduction)" do
      # do not autoload this node, because we want the creation of its
      # entry tree to be its own and not its parent's
      _load_me = TS_::Const_Reduce::Fixtures.
        dir_pathname.join( 'for-skerlerb/core.rb' ).to_path
      load _load_me
      _Skylab = TS_::Const_Reduce::Fixtures::For_Skerlerb
      Autoloader_.const_reduce %i( Infermershern ), _Skylab
    end

    if false  # integ
      Autoloader_.const_reduce %i( InformationTactics ), ::Skylab
      Autoloader_.const_reduce %i( Levenshtein ), ::Skylab::InformationTactics
    end
  end
end
