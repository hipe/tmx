require_relative 'test-support'

module Skylab::Face::TestSupport::API::Action::Proc

  ::Skylab::Face::TestSupport::API::Action[ self, :sandboxes_et_al ]

  describe "extend module x with Face_::API and use procs for actions" do

    extend TS__

    context "against proc as API action" do

      define_sandbox_constant :nightclub do
        module Sandbox::Nightclub_1
          Face_::API[ self ]
          API::Actions::WahHoo = -> do
            :some_result
          end
          Face_::Autoloader_[ self ]
        end
      end

      it "works" do
        r = nightclub::API.invoke :wah_hoo
        r.should eql( :some_result )
      end
    end

    context "against proc as API action with parameters" do

      define_sandbox_constant :nightclub do
        module Sandbox::Nightclub_2
          Face_::API[ self ]
          API::Actions::WahHoo = -> wing, ding=:ohai do
            "<<wing:#{ wing },ding:#{ ding }>>"
          end
          Face_::Autoloader_[ self ]
        end
      end

      it "just right 2 - works" do
        r = nightclub::API.invoke :wah_hoo, wing: 'one', ding: 'two'
        r.should eql( "<<wing:one,ding:two>>" )
      end

      def raise_same_error
        raise_error( ::ArgumentError,
          /missing required parameter ['"]wing['"]/ )
      end

      it "none 1 - barks" do
        -> do
          nightclub::API::invoke :wah_hoo
        end.should raise_same_error
      end

      it "none 2 - barks" do
        -> do
          nightclub::API::invoke :wah_hoo, { }
        end.should raise_same_error
      end

      it "too many - barks" do
        -> do
          nightclub::API::invoke :wah_hoo, waz: :x, taz: :y, wing: :z
        end.should raise_error( ::ArgumentError,
          /undeclared parameters ['"]waz['"] and ['"]taz['"]/ )
      end

      it "just right 1 (USES DEFAULTS) - works" do
        r = nightclub::API.invoke :wah_hoo, wing: 'ONE'
        r.should eql( '<<wing:ONE,ding:ohai>>' )
      end
    end
  end
end
