require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] module accessors" do

    context "a lightweight enhancer that for the module using it generates instance" do

      before :all do

        module X_xkcd_MyApp
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

        module X_xkcd_MyApp
          class CLI::Client
            Home_::Module::Accessors.enhance self do
              public_methods do
                module_reader :API_client_module, '../../API/Client'
              end
            end
          end
        end

        cli = X_xkcd_MyApp::CLI::Client.new
        cli.API_client_module.should eql X_xkcd_MyApp::API::Client
      end
    end

    context "There are also undocumented facilities for auto-vivifying the constants" do

      before :all do

        class X_xkcd_Foo

          Home_::Module::Accessors.enhance self do

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

        foo = X_xkcd_Foo.new
        foo.touch
        X_xkcd_Foo::Ohai_.instance_variable_get( :@counter ).should eql 1
      end

      it "if you create the thing before it is accessed, etc" do

        class Bar < X_xkcd_Foo
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
end
