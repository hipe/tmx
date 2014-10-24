require_relative 'test-support'

module Skylab::Basic::TestSupport::Field::Reflection

  ::Skylab::Basic::TestSupport::Field[ TS_ = self ]

  module Constants::Sandbox
  end

  include Constants

  extend TestSupport_::Quickie

  Basic_ = Basic_
  Sandbox = Sandbox

  describe "[ba] field reflection enhancement" do

    extend TS_

    context "what about this.." do

      define_sandbox_constant :Kls_0 do

        module Sandbox::Mod_0_
          Basic_::Field.box self do
            meta_fields [ :required, :reflective ], :list, [ :rx, :property ]
            fields [ :email, :required, :rx, /x/], :name
          end
        end

        class Sandbox::Kls_0
          Basic_::Field.reflection.enhance( self ).with Sandbox::Mod_0_
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
        ( x.rx_value =~ 'x' ).should eql( 0 )
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
