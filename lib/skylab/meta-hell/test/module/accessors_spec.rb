require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Module::Accessors

  ::Skylab::MetaHell::TestSupport::Module[ self ]

  include Constants

  extend TestSupport_::Quickie

  MetaHell_ = MetaHell_

  Sandboxer = TestSupport_::Sandbox::Spawner.new

  describe "[mh] Module::Accessors" do
    context "a lightweight enhancer that for the module using it generates instance" do
      Sandbox_1 = Sandboxer.spawn
      before :all do
        Sandbox_1.with self
        module Sandbox_1
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
      end
      it "imagine a constant tree with the below five modules" do
        Sandbox_1.with self
        module Sandbox_1
          MyApp::CLI::Client.class.should eql( ::Class )
        end
      end
      it "library would facilitate that thus" do
        Sandbox_1.with self
        module Sandbox_1
          module MyApp
            class CLI::Client
              MetaHell_::Module::Accessors.enhance self do
                public_methods do
                  module_reader :api_client, '../../API/Client'
                end
              end
            end
          end

          cli = MyApp::CLI::Client.new
          cli.api_client.should eql( MyApp::API::Client )
        end
      end
    end
    context "There are also undocumented facilities for auto-vivifying the constants" do
      Sandbox_2 = Sandboxer.spawn
      before :all do
        Sandbox_2.with self
        module Sandbox_2
          class Foo
            MetaHell_::Module::Accessors.enhance self do
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
      end
      it "like so" do
        Sandbox_2.with self
        module Sandbox_2
          Foo.const_defined?( :Ohai_, false ).should eql( false )
        end
      end
      it "the first time the thing is accessed, the two procs are called" do
        Sandbox_2.with self
        module Sandbox_2
          foo = Foo.new
          foo.touch
          Foo::Ohai_.instance_variable_get( :@counter ).should eql( 1 )
        end
      end
      it "if you create the thing before it is accessed, etc" do
        Sandbox_2.with self
        module Sandbox_2
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
          Bar::Ohai_.instance_variable_get( :@counter ).should eql( 11 )
        end
      end
    end
  end
end
