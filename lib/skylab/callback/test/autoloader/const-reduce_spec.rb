require_relative 'test-support'

module Skylab::Callback::TestSupport::Autoloader

  describe "[cb] autoloader const reduce is an improvement on boxxy" do

    context "in that from the ground up it does not assume a mutated module" do

      before :all do
        module Foo1
          module Bar_Biff
            Baz = :some_x
          end
        end
      end

      it "normative use-case" do
        Autoloader.const_reduce( %i( bar_biff baz ), Foo1 ).should eql :some_x
      end

      it "& it is curry friendly - when called with no args you get a proc" do
        p = Autoloader.const_reduce.curry[ %i( bar_biff baz) ]
        p[ Foo1 ].should eql :some_x
        p[ Foo1 ].should eql :some_x  # important - don't mutate the arg path
      end

      it "& it has an explicit form of syntax (tight form, remote ctx)" do
        Autoloader.const_reduce do
          from_module Foo1
          const_path %i( bar_biff baz )
        end.should eql :some_x
      end

      it "& it is infinitely extensible (one day) (long form, local ctx)" do
        s = Autoloader.const_reduce do |cr|
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
          Autoloader.const_reduce( %i( 123fml ), Foo1 )
        end.should raise_name_error
      end

      it "invalid const name and your else block takes one arg - o" do
        ex = nil
        r = Autoloader.const_reduce %i( 123fml ), Foo1 do |ne|
          ex = ne ; :hi
        end
        r.should eql :hi
        ex.name.should eql :'123fml'
        ex.message.should eql "wrong constant name 123fml for const reduce"
      end

      it "invalid const name and your else block takes no args - X" do
        -> do
          Autoloader.const_reduce %i( 123fml ), Foo1 do end
        end.should raise_name_error
      end

      def raise_name_error
        raise_error ::NameError,
          %r(\Awrong constant name 123fml for const reduce\z)
      end

      it "const not found and your else block takes one arg - o" do
        ex = nil
        r = Autoloader.const_reduce(
            %i( bar_biff boon_doggle bizzle ), Foo1 ) do |ne|
          ex = ne ; :hi
        end
        r.should eql :hi
        ex.module.should eql Foo1::Bar_Biff
        ex.name.should eql :boon_doggle
      end

      it "const not found and your else block takes no args - o" do
        r = Autoloader.const_reduce %i(who_hah), Foo1 do :x end
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
        _r = Autoloader.const_reduce %i( bar_biff NCSA_spy ), Foo2
        _r.should eql :some_y
      end
    end
  end
end
