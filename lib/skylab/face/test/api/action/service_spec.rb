require_relative 'test-support'

module Skylab::Face::TestSupport::API::Action::Service

  ::Skylab::Face::TestSupport::API::Action[ self, :sandboxes_et_al ]

  describe "extend module x with Face_::API and use services" do

    extend TS__

    context "when service is not declared" do

      define_sandbox_constant :nc do
        module Sandbox::Nightclub_1
          Face_::API[ self ]
          class API::Actions::W < Face_::API::Action
            services :nerk
          end
          Face_::Autoloader_[ self ]
        end
      end

      it "borks on invoke - custom exception" do
        -> do
          nc::API.invoke :w, never: :see
        end.should raise_this_error
      end

      def raise_this_error
        raise_error(
          Face_::Plugin::DeclarationError,
          /Client has not declared the required service "nerk" declared #{
            }as needed by .+API::Actions::W\./
       )
      end
    end

    context "when service is declared, not defined" do

      define_sandbox_constant :nc do
        module Sandbox::Nightclub_2
          Face_::API[ self ]
          class API::Client  # (re-open!)
            Face_::Plugin::Host.enhance self do
              services :nerk, :blerk
            end
          end
          class API::Actions::W < Face_::API::Action
            services :nerk

            def execute
              nerk
            end
          end
          Face_::Autoloader_[ self ]
        end
      end

      it "borks on invoke - no method error from api client" do
        -> do
          nc::API.invoke :w
        end.should raise_error( ::NoMethodError,
          /undefined method `nerk' for .+API::Client/ )
      end
    end

    context "when service is declared and defined" do

      define_sandbox_constant :nc do
        module Sandbox::Nightclub_3
          Face_::API[ self ]
          class API::Client  # (re-open!)
            Face_::Plugin::Host.enhance self do
              services :nerk, :blerk
            end

            def nerk
              :zeeple
            end
          end
          class API::Actions::W < Face_::API::Action
            services :nerk

            def execute
              "<yup:#{ nerk }>"
            end
          end
          Face_::Autoloader_[ self ]
        end
      end

      it "no borky just worky" do
        nc::API.invoke( :w ).should eql( '<yup:zeeple>' )
      end
    end

    context "when service is ingested" do

      define_sandbox_constant :nc do
        module Sandbox::Nightclub_4
          Face_::API[ self ]
          class API::Client  # (re-open!)
            Face_::Plugin::Host.enhance self do
              services :blerk
            end

            def initialize( * )
              super
              @blerk = -> { "helo" }
            end

            attr_reader :blerk
          end

          class API::Actions::W < Face_::API::Action

            services [ :blerk, :ivar ]

            def execute
              "<yup-w:#{ @blerk.call }>"
            end
          end

          class API::Actions::X < Face_::API::Action

            services [ :blerk, :ivar, :@zoidberg ]

            def execute
              "<yup-x:#{ @zoidberg.call }>"
            end
          end
          Face_::Autoloader_[ self ]
        end
      end

      it "i just an entire service" do
        nc::API.invoke( :w ).should eql( "<yup-w:helo>" )
      end

      it "i just an entire service - custom ivar" do
        nc::API.invoke( :x ).should eql( "<yup-x:helo>" )
      end
    end
  end
end
