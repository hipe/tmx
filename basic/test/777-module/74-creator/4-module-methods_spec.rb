require_relative '../../test-support'

# NOTE - this has to be run under the recursive runner - you can't invoke it directly

# the below tests are especially ugly because they themselves are testing
# how this library affects modules, yet the whole purpose of this library
# was to make things like testing modules prettier, hence as a quintessential
# meta-bootstrapping problem we cannot (or, at least, should not) use the
# library itself here, hence they are very ugly, hence in a way, right here
# in this very file is the darkest of all the circles of m-eta-hell.

module Skylab::Basic::TestSupport

  module Mdl_Crtr_MM___  # :+#throwaway-module for constants created below

    # <-

  module Scenario_One

    Once__ = Common_.memoize do  # we want something more explicit than before( :all ) for now

      module Some_Module_Definer_Methods

        Home_::Module::Creator[ self ]

        modul :Wank do
          def worked
          end
        end
      end

      class Class

        include Some_Module_Definer_Methods

        TestSupport_::Let[ self ]

        let :meta_hell_anchor_module do
          ::Module.new
        end
      end

      :__done__
    end

    TS_.describe "[ba] Module::Creator::ModuleMethods (*on* modules, #{
      }not classes" do

      TS_[ self ]

      it "a klass can include modules that have graphs, and work" do

        Once__[]

        Class.new._Wank.instance_methods.should eql [ :worked ]

      end
    end
  end

  module Scenario_Two

      Once__ = Common_.memoize do

        module OneGuy

          Home_::Module::Creator[ self ]

          modul :Lawrence__Fishburne
        end

        module AnotherGuy

          Home_::Module::Creator[ self ]

          modul :Lawrence__Kasdan

          modul :Lawrence__Arabia
        end

        class SomeClass

          include OneGuy, AnotherGuy

          TestSupport_::Let[ self ]

          let :meta_hell_anchor_module do
            ::Module.new
          end
        end

      :__dne__
      end

                                  # (interestingly look how rspec reports
                                  # the below module name when you run
                                  # this file alone)


    TS_.describe "[ba] Module::Creator::ModuleMethods scenario 2 - #{
      }this is fucking amazing - composing different module graphs WTF" do

      TS_[ self ]

      before :all do
        Once__[]
      end

      it "amazingly works sort of under composition with some kicking" do
        o = SomeClass.new
        mod = o._Lawrence
        mod.constants.should eql([:Fishburne])
        o._Lawrence__Arabia
        mod.constants.should eql([:Fishburne, :Kasdan, :Arabia])
      end

      it "I UNDERSTAND THIS RIGHT NOW BUT I NEVER WILL EVER AGAIN" do
        o1 = SomeClass.new
        o2 = SomeClass.new
        o3 = SomeClass.new
        a = [o1, o2, o3]
        a.map { |o| o.meta_hell_anchor_module.constants.length }.
          uniq.should eql([0])
        a.map { |o| o.meta_hell_anchor_module.object_id }.
          uniq.length.should eql(a.length)
        o1.modul! :Lawrence__Arabia__Flavia
        o2.modul! :Lawrence__Fishburne__Wishburne
        o1.Lawrence.constants.should eql([:Fishburne, :Kasdan, :Arabia]) # b/c..
        o2.Lawrence.constants.should eql([:Fishburne])
        o1.Lawrence::Fishburne.constants.should eql([])
        o2.Lawrence::Fishburne.constants.should eql([:Wishburne])
        o2.Lawrence__Arabia.constants.should eql([])
        o1.Lawrence::Arabia.constants.should eql([:Flavia])
      end
    end
  end
# ->
  end
end
