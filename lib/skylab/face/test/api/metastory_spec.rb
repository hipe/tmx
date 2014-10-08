require_relative 'test-support'

module Skylab::Face::TestSupport::API::Metastory

  ::Skylab::Face::TestSupport::API[ self, :sandboxes_et_al ]

  describe "[fa] API metastories" do

    extend TS__

    modex = :API_

    context "facet 1 - the `modality_exponent` is reported as `#{ modex }`" do
      context "in libraryville base class" do
        it "modality client" do
          Face_::API::Client.metastory.modality_exponent.
            should eql( modex )
        end
        # action namespaces are wispy afterthoughts, we skip them
        it "action" do
          Face_::API::Action.metastory.modality_exponent.
            should eql( modex )
        end
      end
      context "businessland subclass" do
        it "modality client" do
          businessland_modality_client_class.metastory.modality_exponent.
            should eql( modex )
        end
        it "action" do
          businessland_modality_client_class.metastory.modality_exponent.
            should eql( modex )
        end
      end
    end

    context "facet 2 - the `triforce_exponent` is reported" do
      context "in libraryville base class" do
        context "by modality client" do
          it "as `Modality_Client`" do
            Face_::API::Client.metastory.triforce_exponent.
              should eql( :Modality_Client_ )
          end
          it "( is_anchor, is_branch, is_leaf ) is ( true, true, false )" do
            trio Face_::API::Client, true, true, false
          end
        end
        context "by action class" do
          it "as `Action`" do
            Face_::API::Action.metastory.triforce_exponent.
              should eql( :Action_ )
          end
          it "( is_anchor, is_branch, is_leaf ) is ( false, false, true )" do
            trio Face_::API::Action, false, false, true
          end
        end
      end
      context "in businessland subclass" do
        context "by modality client" do
          it "as `Modality_Client`" do
            businessland_modality_client_class.metastory.triforce_exponent.
              should eql( :Modality_Client_ )
          end
          it "( is_anchor, is_branch, is_leaf ) is ( true, true, false )" do
            trio businessland_modality_client_class, true, true, false
          end
        end
        context "by action class" do
          it "as `Action`" do
            businessland_action_class.metastory.triforce_exponent.
              should eql( :Action_ )
          end
          it "( is_anchor, is_branch, is_leaf ) is ( false, false, true )" do
            trio businessland_action_class, false, false, true
          end
        end
      end
    end

    context "note - the particular metastory" do
      context "as reported by the modality client" do
        it "is persistent in library-ville" do
          oid = Face_::API::Client.metastory.object_id
          Face_::API::Client.metastory.object_id.should eql( oid )
        end
        it "is persistent in businessland" do
          oid = businessland_modality_client_class.metastory.object_id
          businessland_modality_client_class.metastory.object_id.
            should eql( oid )
        end
        it "is *not* the same object from library-ville to businessland" do
          oid1 = Face_::API::Client.metastory.object_id
          oid2 = businessland_modality_client_class.metastory.object_id
          ( oid1 == oid2 ).should eql( false )
        end
      end
    end

    context "facet 3 - the `aggregate_exponent` is reported" do
      context "in businessland" do
        it "by modality client class as `API_Modality_Client_`" do
          businessland_modality_client_class.metastory.aggregate_exponent.
            should eql( :API_Modality_Client_ )
        end
        it "by action client class as `API_Action_`" do
          businessland_action_class.metastory.aggregate_exponent.
            should eql( :API_Action_ )
        end
      end
    end

    def trio thing, *bbb
      x = thing.metastory
      [ x.is_anchor, x.is_branch, x.is_leaf ].should eql( bbb )
    end

    def businessland_modality_client_class
      businessland_api_module.const_get :Client, false
    end

    def businessland_action_class
      businessland_api_module.const_get :Particular_Action, false
    end

    define_sandbox_constant :businessland_api_module do
      module Sandbox::API
        class Client < Face_::API::Client
        end
        class Particular_Action < Face_::API::Action
        end
      end
    end
  end
end
