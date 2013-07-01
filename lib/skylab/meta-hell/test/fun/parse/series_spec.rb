require_relative 'test-support'

module Skylab::MetaHell::TestSupport::FUN::Parse::Series

  ::Skylab::MetaHell::TestSupport::FUN::Parse[ Series_TestSupport = self ]

  include CONSTANTS

  MetaHell = ::Skylab::MetaHell  # increase its visibility for below modules

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::MetaHell::FUN::Parse::Series" do
    context "`parse_series` - parse out (a fixed) N values from M args" do
      Sandbox_1 = Sandboxer.spawn
      before :all do
        Sandbox_1.with self
        module Sandbox_1
          P = MetaHell::FUN.parse_series.curry[
            :matcher_a, [
              -> age do
                /\A\d+\z/ =~ age and age.to_i
              end,
              -> sex do
                /\A(?:m(?:ale)?|f(?:emale)?|o(?:ther)?)\z/i =~ sex and sex
              end,
              -> location do
                /\A[A-Z]/ =~ location and location # must start with capital
              end
          ] ]
        end
      end
      it "(with lowlevel interface) parse all three things" do
        Sandbox_1.with self
        module Sandbox_1
          P[ [ '30', 'male', "Mom's basement" ] ].should eql( [ '30', 'male', "Mom's basement" ] )
        end
      end
      it "or just the first one" do
        Sandbox_1.with self
        module Sandbox_1
          P[ [ '30' ] ].should eql( [ '30', nil, nil ] )
        end
      end
      it "or just the last one" do
        Sandbox_1.with self
        module Sandbox_1
          P[ [ "Mom's basement" ] ].should eql( [ nil, nil, "Mom's basement" ] )
        end
      end
      it "or just the middle one, etc (note it gets precedence over last)" do
        Sandbox_1.with self
        module Sandbox_1
          P[ [ 'M' ] ].should eql( [ nil, 'M', nil ] )
        end
      end
      it "if you set `exhaustion` to `false`, it terminates at first non-parsable" do
        Sandbox_1.with self
        module Sandbox_1
          argv = [ '30', 'm', "Mom's", "Mom's again" ]
          omg = P.curry[ :exhaustion, false ]
          omg[ argv ].should eql( [ '30', 'm', "Mom's" ] )
          argv.should eql( [ "Mom's again" ] )
        end
      end
      it "(for contrast, here's the same thing, but with errors:)" do
        Sandbox_1.with self
        module Sandbox_1
          argv = [ '30', 'm', "Mom's", "Mom's again" ]
          -> do
            P[ argv ]
          end.should raise_error( ArgumentError,
                       ::Regexp.new( "\\Aunrecognized\\ argument\\ at\\ index\\ 3" ) )
        end
      end
    end
  end
end
