require_relative 'mm/test-support'

# the below tests are especially ugly because they themselves are testing
# how this library affects modules, yet the whole purpose of this library
# was to make things like testing modules prettier, hence as a quintessential
# meta-bootstrapping problem we cannot (or, at least, should not) use the
# library itself here, hence they are very ugly, hence in a way, right here
# in this very file is the darkest of all the circles of meta-hell.

module ::Skylab::MetaHell::TestSupport::Module::Creator::ModuleMethods


  module Scenario_One

    o = { }

    done = nil

    o[:once] = -> do

      module Ohai                 # ok so the crazy thing here is that what
        extend Module::Creator     # we are doing is making a *module* (not
        extend MetaHell::Let      # a class) be the module definer here

        modul :Wank do            # (this is the crazy crap that was working
          def worked ; end        # back before the first rewrite that we
        end                       # totally borked and didn't understand
      end                         # how we borked, and are in the middle

      class Class                 # of untangling now.  Does this count as
        include Ohai              # literate programming?)
        extend MetaHell::Let::ModuleMethods

        let(:meta_hell_anchor_module) { ::Module.new }

      end

      done[ :once ]

    end

    F = MetaHell.lib.struct_from_hash o

    done = FUN.done_p[ F ]         # this absurdity is just a sanity check


    describe "[mh] Module::Creator::ModuleMethods (*on* modules, #{
      }not classes" do

      extend MM_TestSupport

      context "minimal" do
        it "a klass can include modules that have graphs, and work" do
          # we want more fine-grained control than before(:all) for now ..
          F.once[]
          Class.new._Wank.instance_methods.should eql([:worked])
        end
      end
    end
  end


  module Scenario_Two
    X = MetaHell.lib.struct_from_hash(
      :once => -> do

        module OneGuy
          extend Module::Creator, MetaHell::Let
          modul :Lawrence__Fishburne

        end
        module AnotherGuy
          extend Module::Creator, MetaHell::Let
          modul :Lawrence__Kasdan
          modul :Lawrence__Arabia
        end
        class SomeClass
          include OneGuy, AnotherGuy

          extend MetaHell::Let::ModuleMethods

          let(:meta_hell_anchor_module) { ::Module.new }
        end
        X.done[ :once ]
      end,

     :done => ->( name ) { X[name] = FUN.done_msg_p[ name ] }
    )

                                  # (interestingly look how rspec reports
                                  # the below module name when you run
                                  # this file alone)


    describe "[mh] Module::Creator::ModuleMethods scenario 2 - #{
      }this is fucking amazing - composing different module graphs WTF" do

      extend MM_TestSupport

      before(:all) { X.once[] }

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
end
