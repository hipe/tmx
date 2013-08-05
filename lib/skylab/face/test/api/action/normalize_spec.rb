require_relative 'test-support'

module Skylab::Face::TestSupport::API::Action::Normalize

  ::Skylab::Face::TestSupport::API::Action[ Normalize_TestSupport = self ]

  module Sandbox
    # mine.
  end

  module CONSTANTS
    Sandbox = Sandbox
  end

  include CONSTANTS

  extend TestSupport::Quickie

  Face = Face

  describe "extend module x with Face::API and be normal" do

    extend Normalize_TestSupport

    context "roll own normalize if you must" do

      define_sandbox_constant :nightclub do
        module Sandbox::Nightclub_1
          Face::API[ self ]
          class API::Actions::W < Face::API::Action
            def normalize y, p_h
              if ! p_h
                y << "no params provided"
              elsif p_h.length.zero?
                y << "zero number of params provided"
              elsif ( 2 % p_h.length ).nonzero?
                y << "non-even number of params provided - #{ p_h.length }"
              else
                @valid_p_h = p_h
              end
            end

            def execute
              @valid_p_h.map { |k, v| "#{ k }:#{ v }" } * ', '
            end
          end
        end
      end

      def rais rx
        raise_error ::ArgumentError, rx
      end

      it "no params" do
        -> do
          nightclub::API.invoke :w
        end.should rais( /no params provided/ )
      end

      it "empty params" do
        -> do
          nightclub::API::invoke :w, { }
        end.should rais( /zero number/ )
      end

      it "odd num" do
        -> do
          nightclub::API::invoke :w, { one: 2, three: 4, five: 6 }
        end.should rais( /non-even.+3/ )
      end

      it "fun num" do
        x = nightclub::API::invoke :w, { any: 'arg', you: 'want' }
        x.should eql( 'any:arg, you:want' )
      end
    end

    context "field-level normalization" do

      define_sandbox_constant :nightclub do
        module Sandbox::Nightclub_2
          Face::API[ self ]
          class API::Actions::Weee < Face::API::Action
            params [ :email, :normalizer, -> y, x, z do
              if x.length < 3
                y << "email is too short."
                false
              elsif /\A[@a-z.]+\z/ =~ x
                true
              else
                z[ x.capitalize ]
                true
              end
            end ]
            def execute
              "okay(#{ @email })"
            end
          end
        end
      end

      it "is neat" do
        -> do
          nightclub::API::invoke :weee, email: '1'
        end.should raise_error( ::ArgumentError, /email is too short/ )
        x = nightclub::API::invoke :weee, email: 'foobarbaz'
        x.should eql( 'okay(foobarbaz)' )
        x = nightclub::API::invoke :weee, email: 'mINKEL TINKEL'
        x.should eql( 'okay(Minkel tinkel)' )
      end
    end
  end
end
