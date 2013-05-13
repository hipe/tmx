require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::API_Integration::Core

  ::Skylab::Face::TestSupport::CLI::API_Integration[ Core_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module Sandbox
  end

  CONSTANTS::Sandbox = Sandbox

  describe "#{ Face::CLI } API integration (core)" do

    extend CLI_TestSupport
    extend Core_TestSupport  # so CONSTANTS (Sandbox) is visible in i.m's

    Face = Face

    context "some nightclub - request a simple isomorphic call" do
      define_sandbox_constant :application_module do
        module Sandbox::Nightclub_1
          module CLI  # maybe magic one day [#fa-009]
            class Client < Face::CLI
              def fee
                api
              end

              def foo
                api
              end
            end
          end

          module API
            module Actions
              class Foo < Face::API::Action
                def execute
                  :foo_it_is
                end
              end
            end
          end
        end
      end

      it "for which no action defined - raises boxxy name error" do
        -> do
          invoke 'fee'
        end.should raise_error(
          MetaHell::Boxxy::NameNotFoundError,
          /uninitialized constant .+:API::Actions::Fee/
        )
      end

      it "that takes no arguments anywhere - works" do
        debug!
        r = invoke 'foo'
        r.should eql( :foo_it_is )
      end

      # (NOTE having two tests above it clutch - it catches some things
      # like that API::Client._enhance is actually re-runnable.)
    end
  end
end
