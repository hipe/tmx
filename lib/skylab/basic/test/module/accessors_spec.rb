require_relative '../test-support'

module Skylab::Basic::TestSupport

  module Mdl_A___  # :+#throwaway-module for contants set during tests

    # <-

  TS_.describe "[ba] module accessors" do

    context "imagine a module graph with the below five modules" do

      before :all do

        module MyApp
          module CLI
            class Client
            end
          end

          module API
            class Client
            end
          end
        end
      end

      it "from one instance you can reach a module in its class's graph" do

        module MyApp
          class CLI::Client
            Basic_::Module::Accessors.enhance self do
              public_methods do
                module_reader :API_client_module, '../../API/Client'
              end
            end
          end
        end

        cli = MyApp::CLI::Client.new
        cli.API_client_module.should eql MyApp::API::Client
      end
    end

    context "here's the autovivifying hack" do

      before :all do

        class Foo

          Basic_::Module::Accessors.enhance self do

            private_module_autovivifier_reader :zapper, 'Ohai_',
              -> do  # when didn't exist
                m = ::Module.new
                m.instance_variable_set :@counter, 0
                m
              end,
              -> do  # whether did or didn't exist, on first access
                @counter += 1
              end
          end

          def touch
            zapper
            zapper
            zapper
          end
        end
      end

      it "the first time the thing is accessed, the two procs are called" do

        foo = Foo.new
        foo.touch
        Foo::Ohai_.instance_variable_get( :@counter ).should eql 1
      end

      it "if you create the thing before it is accessed, etc" do

        class Bar < Foo
          module Ohai_
            @counter = 10
          end

          def run
            zapper
            zapper
            zapper
          end
        end

        bar = Bar.new
        bar.run
        Bar::Ohai_.instance_variable_get( :@counter ).should eql 11
      end
    end
  end
# ->
  end
end
