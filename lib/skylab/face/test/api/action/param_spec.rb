require_relative '../test-support'

module Skylab::Face::TestSupport::API::Param

  ::Skylab::Face::TestSupport::API[ Param_TestSupport = self ]

  module Sandbox
    # mine.
  end

  module CONSTANTS
    Sandbox = Sandbox
  end

  include CONSTANTS

  extend TestSupport::Quickie

  Face = Face

  describe "extend module x with Face::API and use params" do

    extend Param_TestSupport

    context "none" do

      define_sandbox_constant :nc do
        module Sandbox::Nightclub_1
          Face::API[ self ]
          class API::Actions::W < Face::API::Action
            def execute
              :ok
            end
          end
        end
      end

      it "right" do
        -> do
          nc::API.invoke :w, xtra: :one
        end.should rais( /undeclared parameter.+xtra/ )
      end

      it "center" do
        nc::API.invoke( :w ).should eql( :ok )
      end
    end

    def rais rx
      raise_error ::ArgumentError, rx
    end

    context "two flat - flat fields are required fields" do

      define_sandbox_constant :nc do
        module Sandbox::Nightclub_2
          Face::API[ self ]
          class API::Actions::W < Face::API::Action
            params :hurf, :gurf
            def execute
              "<<h:#{ @hurf }, g:#{ @gurf }>>"
            end
          end
        end
      end

      it "left clean" do
        -> do
          nc::API.invoke :w
        end.should same
      end

      it "left empty" do
        -> do
          nc::API.invoke :w, { }
        end.should same
      end

      def same
        rais( /missing required parameter\(s\) - \(hurf, gurf\)/ )
      end

      it "left partial" do
        -> do
          nc::API.invoke :w, hurf: :x
        end.should rais( /missing.+\(gurf\)/ )
      end

      it "right" do
        -> do
          nc::API.invoke :w, zip: :zap
        end.should rais( /undeclared param.+\(zip\)/ )
      end

      it "left and right - right wins" do
        -> do
          nc::API.invoke :w, hurf: :x, gurf: :y, berf: :z, derf: :a
        end.should rais( /undeclared parameter\(s\) - \(berf, derf\)/ )
      end
    end

    context "three deep" do

      define_sandbox_constant :nc do
        module Sandbox::Nightclub_3
          Face::API[ self ]
          class API::Actions::W < Face::API::Action
            params [ :eeny, :arity, :one ],
                   [ :meeny, :arity, :zero_or_one ],
                   [ :hermione, :arity, :zero_or_one ]
            def execute
              "<<e:#{ @eeny.inspect }, m:#{ @meeny.inspect }#{
                }, h:#{ @hermione.inspect }>>"
            end
          end
        end
      end

      it "left clean" do
        -> do
          nc::API.invoke :w
        end.should rais( /missing.+\(eeny\)/ )
      end

      it "center inner" do
        nc::API.invoke( :w, { eeny: 'E' } ).should eql(
          '<<e:"E", m:nil, h:nil>>' )
      end

      it "center outer" do
        nc::API.invoke( :w, { eeny: 'A', meeny: 'B', hermione: 'C' } ).should(
          eql( '<<e:"A", m:"B", h:"C">>' )
        )
      end

      it "right" do
        -> do
          nc::API.invoke( :w, { nope: nil } )
        end.should rais( /undeclared.+\(nope\)/ )
      end
    end
  end
end
