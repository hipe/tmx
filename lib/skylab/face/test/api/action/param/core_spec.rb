require_relative '../test-support'

module Skylab::Face::TestSupport::API::Action::Param

  ::Skylab::Face::TestSupport::TestLib_::Sandboxify[ self ]

  describe "[fa] test API action param" do

    extend TS_

    context "none" do

      define_sandbox_constant :nc do
        module Sandbox::Nightclub_1
          Face::API[ self ]
          class API::Actions::W < Face::API::Action
            def execute
              :ok
            end
          end
          Face::Autoloader_[ self ]
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
          Face::Autoloader_[ self ]
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
        rais( /missing required parameters ['"]hurf['"] and ['"]gurf['"]/ )
      end

      it "left partial" do
        -> do
          nc::API.invoke :w, hurf: :x
        end.should rais( /missing required parameter ['"]gurf['"]/ )
      end

      it "right" do
        -> do
          nc::API.invoke :w, zip: :zap
        end.should rais( /undeclared parameter ['"]zip['"]/ )
      end

      it "left and right - right wins" do
        -> do
          nc::API.invoke :w, hurf: :x, gurf: :y, berf: :z, derf: :a
        end.should rais( /undeclared parameters 'berf' and 'derf'/ )
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
          Face::Autoloader_[ self ]
        end
      end

      it "left clean" do
        -> do
          nc::API.invoke :w
        end.should rais( /missing required parameter "eeny"/ )
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
        end.should rais( /undeclared parameter ['"]nope['"]/ )
      end
    end
  end
end
