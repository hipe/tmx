require_relative 'test-support'

module Skylab::Basic::TestSupport::Field::Reflection

  ::Skylab::Basic::TestSupport::Field[ Reflection_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module SANDBOX
  end

  Basic = Basic

  describe "#{ Basic::Field }::Reflection enhancement" do

    extend Reflection_TestSupport

    def sandbox_module
      SANDBOX
    end

    context "what about this.." do

      sandbox :Kls_0 do

        module SANDBOX::Mod_0_
          Basic::Field::Box.enhance self do
            meta_fields [ :required, :reflective ], :list, [ :rx, :property ]
            fields [ :email, :required, :rx, /x/], :name
          end
        end

        class SANDBOX::Kls_0
          Basic::Field::Reflection.enhance( self ).with SANDBOX::Mod_0_
        end
      end

      let :obj do
        self.Kls_0.new
      end

      it "(internally it freezes and caches them as arrays)" do
        x = obj.required_fields
        ( ::Array === x ).should eql( true )
        x.length.should eql( 1 )
        x.frozen?.should eql( true )
        x = x.fetch 0
        ( x.get_rx =~ 'x' ).should eql( 0 )
      end

      it "`field_names`" do
        obj.field_names.should eql( %i( email name ) )
      end

      it "`required_field_names`" do
        obj.required_field_names.should eql( %i( email ) )
      end
    end
  end
end
