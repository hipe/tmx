require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Metastory

  ::Skylab::Face::TestSupport::CLI[ Metastory_TestSupport = self ]

  CONSTANTS::Common_setup_[ self, :sandbox ]

  describe "#{ Face }::CLI metastories" do

    extend Metastory_TestSupport

    context "facet 1 - the `modality_exponent` is `CLI`" do
      modex = :CLI_
      context "from libville" do
        it "CLI (modality client baseclass)" do
          Face::CLI.metastory.modality_exponent.should eql( modex )
        end
        it "Namespace" do
          Face::CLI::Namespace.metastory.modality_exponent.should eql( modex )
        end
        it "Command" do
          Face::CLI::Command.metastory.modality_exponent.should eql( modex )
        end
      end
      context "from businessland" do
        it "client_class" do
          client_class.metastory.modality_exponent.should eql( modex )
        end
        it "namespace_class" do
          namespace_class.metastory.modality_exponent.should eql( modex )
        end
        it "command_class" do
          command_class.metastory.modality_exponent.should eql( modex )
        end
      end
    end

    def self.triforce_exponent i
      define_singleton_method :triforce_exponent_value do i end
      define_method :triforce_exponent do i end
    end

    def self.trio *three
      three.freeze
      define_singleton_method :trio_value do three end
      define_method :trio do three end
    end

    def self.explain_i
      "`triforce_exponent` is :#{ triforce_exponent_value }"
    end

    def self.explain_trio
      "( is_anchor, is_branch, is_leaf ) is #{ trio_value.inspect }"
    end

    def self.metastory &b
      define_method :metastory do
        instance_exec( & b )
      end
    end

    context "facet 2 - the `triforce_exponent` (and derived)" do
      context "of modality client" do
        triforce_exponent :Modality_Client_
        trio true, true, false
        context "libville baseclass" do
          metastory { Face::CLI.metastory }
          it "#{ explain_i }" do
            metastory.triforce_exponent.should eql( triforce_exponent )
          end
          it "#{ explain_trio }" do
            trio_from( metastory ).should eql( trio )
          end
        end
        context "businessland subclass" do
          metastory { client_class.metastory }
          it "#{ explain_i }" do
            metastory.triforce_exponent.should eql( triforce_exponent )
          end
          it "#{ explain_trio }" do
            trio_from( metastory ).should eql( trio )
          end
        end
      end
      context "of namespace" do
        triforce_exponent :Namespace_
        trio false, true, false
        context "libville baseclass" do
          metastory { Face::CLI::Namespace.metastory }
          it "#{ explain_i }" do
            metastory.triforce_exponent.should eql( triforce_exponent )
          end
          it "#{ explain_trio }" do
            trio_from( metastory ).should eql( trio )
          end
        end
        context "businessland subclass" do
          metastory { namespace_class.metastory }
          it "#{ explain_i }" do
            metastory.triforce_exponent.should eql( triforce_exponent )
          end
          it "#{ explain_trio }" do
            trio_from( metastory ).should eql( trio )
          end
        end
      end
      context "of command" do
        triforce_exponent :Action_
        trio false, false, true
        context "libville baseclass" do
          metastory { Face::CLI::Command.metastory }
          it "#{ explain_i }" do
            metastory.triforce_exponent.should eql( triforce_exponent )
          end
          it "#{ explain_trio }" do
            trio_from( metastory ).should eql( trio )
          end
        end
        context "businessland subclass" do
          metastory { command_class.metastory }
          it "#{ explain_i }" do
            metastory.triforce_exponent.should eql( triforce_exponent )
          end
          it "#{ explain_trio }" do
            trio_from( metastory ).should eql( trio )
          end
        end
      end
    end

    define_sandbox_constant :businessland_cli_module do
      module Sandbox::CLI
        class Client < Face::CLI
        end
        class Particular_Namespace < Face::Namespace
        end
        class Particular_Command < Face::Command  # not in the wild
        end
      end
    end

    def trio_from ms
      [ !! ms.is_anchor, !! ms.is_branch, !! ms.is_leaf ]
    end

    def client_class
      businessland_cli_module.const_get :Client, false
    end

    def namespace_class
      businessland_cli_module.const_get :Particular_Namespace, false
    end

    def command_class
      businessland_cli_module.const_get :Particular_Command, false
    end
  end
end
