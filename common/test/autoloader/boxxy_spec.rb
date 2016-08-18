require_relative 'test-support'

module Skylab::Common::TestSupport::Autoloader

  describe "[co] autoloader \"boxxy\"" do

    context "this is a live test, must happen in one big story" do

      before :all do

        module TS_::Fixtures::One
          LoL = :weird_casing
          Subject_[ self, :boxxy ]
        end
      end

      it "names are inferred then corrected. 'const_defined?' is fuzzy." do
        mod = TS_::Fixtures::One
        a = mod.constants
        a.should eql %i( LoL Ncsa_Spy )
        mod.should be_const_defined :NcSa_spy
        x = mod.const_get :NCsa_spy, false
        x.should eql :_hello_yes_this_is_NCSA_Spy_
        mod.constants.should eql %i( LoL NCSA_Spy )
       end

      it "won't trip up and let invalid names pass, despite distillation" do
        -> do
          TS_::Fixtures::One.const_defined?( :nCsA_spy )
        end.should raise_error ::NameError, /\Awrong constant name/
      end
    end

    context "when there is no directory, things are ok" do

      before :all do
        module TS_::Fuxtures
          Wazlo = :heya
          Subject_[ self, :boxxy ]
        end
      end

      it "boxxy won't break just because there is no dir" do
        mod = TS_::Fuxtures
        a = mod.constants
        b = mod.constants
        a.should eql b
        a.should eql %i( Wazlo )
        ( a.object_id == b.object_id ).should eql false
      end

      it "but still gives helpful error message on no ent" do
        mod = TS_::Fuxtures
        -> do
          mod.const_get :Wizzlo, false
        end.should raise_error ::NameError, %r(\buninit.+const.+Wizzlo and #{
          }no directory\b)
      end
    end

    context "if one of the expected consts is not set in the file" do
      before :all do
        module TS_::Fixtures::Two
          Subject_[ self, :boxxy ]
        end
      end
      it "it will say it is defined, and then BOOM - X" do
        _y = TS_::Fixtures::Two.const_defined? :Lorca, false
        _y.should eql true
        TS_::Fixtures::Two.dir_pathname or fail
        -> do
          TS_::Fixtures::Two::Lorca
        end.should raise_error ::NameError, rx
      end
      def rx
        %r(\A[A-Za-z:]+#{
          }::Fixtures::Two::\( ~ lorca \) #{
           }must be but does not appear to be defined in #{
            }.+/fixtures/two/lorca\.rb)
      end
    end

    context "boxxy goes deep on your startup whether you like it or not" do

      before :all do
        module TS_::Fixtures::Three
          Subject_[ self, :boxxy ]
        end
      end

      it "for now boxxy is always recursively contagious" do
        mod = TS_::Fixtures::Three
        lvl_1 = mod::Level_1
        _y = lvl_1.const_defined? :Level_2
        _y.should eql true
        x = lvl_1::Level_2::Leaf_3::SOME_CONST
        x.should eql :some_val
      end
    end

    context "when there is a fuzzy pair (file and folder) of entries" do
      before :all do
        module TS_::Boxxy::Fixtures::One
          Subject_[ self, :boxxy ]
        end
      end
      it "it works" do
        i_a = TS_::Boxxy::Fixtures::One.constants
        i_a.should eql %i( RedLeader )
      end
    end
  end
end