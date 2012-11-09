require_relative 'mm/test-support'

# the below tests are especially ugly because they themselves are testing
# how this library affects modules, yet the whole purpose of this library
# was to make things like testing modules prettier, hence as a quintessential
# meta-bootstrapping problem we cannot (or, at least, should not) use the
# library itself here, hence they are very ugly, hence in a way, right here
# in this very file is the darkest of all the circles of meta-hell.

module ::Skylab::MetaHell::TestSupport::Modul::Creator::ModuleMethods

  module Module_Scenario_One

    o = { }

    done = -> name do
      F[name] = -> { $stderr.puts "NEVER AGAIN: #{name}" } # just to be sure
    end

    o[:once] = -> do

      module Ohai                 # ok so the crazy thing here is that what
        extend Modul::Creator     # we are doing is making a *module* (not
        extend MetaHell::Let      # a class) be the module definer here

        modul :Wank do            # (this is the crazy crap that was working
          def worked ; end        # back before the first rewrite that we
        end                       # totally borked and didn't understand
      end                         # how we borked, and are in the middle

      class Klass                 # of untangling now.  Does this count as
        include Ohai              # literate programming?)
        extend MetaHell::Let::ModuleMethods

        let(:meta_hell_anchor_module) { ::Module.new }

      end

      done[ :once ]
    end

    F = ::Struct.new(* o.keys).new ; o.each { |k, v| F[k] = v }

    describe "#{MetaHell::Modul::Creator::ModuleMethods} (*on* modules, #{
      }not classes" do

      extend MM_TestSupport

      context "minimal" do
        it "FUCK" do
          # we want more fine-grained control than before(:all) for now ..
          F.once[]
          Klass.new._Wank.instance_methods.should eql([:worked])
        end
      end
    end
  end
end
