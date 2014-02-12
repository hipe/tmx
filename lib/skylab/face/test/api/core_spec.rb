require_relative 'test-support'

module Skylab::Face::TestSupport::API::Core_

  ::Skylab::Face::TestSupport::API[ self, :sandboxes_et_al ]

  describe "extend module x with Face::API and you get `x::API.invoke` that" do

    extend TS__

    context "against the minimal case" do

      define_sandbox_constant :nightclub do
        module Sandbox::Nightclub_1
          Face::API[ self ]
        end
      end

      it "will complain about dpn missing" do
        -> do
          nightclub::API.invoke :foo
        end.should raise_error ::NoMethodError, %r(\Aneeds '?dir_pathname'?)
      end
    end

    context "when dir pathname can be resolved" do

      define_sandbox_constant :nightclub do
        module Sandbox::Nightclub_1_B
          Face::API[ self ]
          Face::Autoloader_[ self ]
        end
      end

      it "try to invoke anything - raises boxxy-esque name not found error" do
        -> do
          nightclub::API.invoke :foo
        end.should raise_this_error
      end
    end

    context "against a rig with one explicitly made and empty box module" do

      define_sandbox_constant :nightclub do
        module Sandbox::Nightclub_2
          module API
          end
          module API::Actions
          end
          Face::API[ self ]
          Face::Autoloader_[ self ]
        end
      end

      it "try to invoke anything - raises boxxy name not found error" do
        -> do
          nightclub::API.invoke :foo
        end.should raise_this_error
      end
    end

    context "against a rig with one API action, one level deep" do

      define_sandbox_constant :nightclub do
        module Sandbox::Nightclub_3
          Face::API[ self ]
          module API::Actions
            class WahHoo
            end
          end
          Face::Autoloader_[ self ]
        end
      end

      it "your class must define `execute`" do
        -> do
          nightclub::API.invoke :wah_hoo
        end.should raise_error( ::NoMethodError,
          /undefined method `execute'/ )
      end
    end

    context "wow this rig has it all - minimal execute" do

      define_sandbox_constant :nightclub do
        module Sandbox::Nightclub_4
          Face::API[ self ]
          class API::Actions::WahHoo
            def execute
              :yerp
            end
          end
          Face::Autoloader_[ self ]
        end
      end

      it "here have one" do
        nightclub::API.invoke( :wah_hoo ).should eql( :yerp )
      end

      it "but don't touch the sides" do
        -> do
          nightclub::API.invoke( :wah_hoo, one: :two )
        end.should raise_error( ::NoMethodError,
          /undefined method `normalize'/ )
      end
    end

    def raise_this_error  # (let the below be the only place that the
      raise_error( ::RuntimeError,  # <- particular class is asserted)
        /isomorphic API action resolution failed - #{
          }.*no.+constant.+isomorph.+"foo"/i )
    end
  end
end
