require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Fun::Parse::Series

  ::Skylab::MetaHell::TestSupport::Fun::Parse[ Series_TestSupport = self ]

  include CONSTANTS

  MetaHell = ::Skylab::MetaHell  # increase its visibility for below modules

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::MetaHell::Fun::Parse::Series" do
    context "`parse_series` - parse out (a fixed) N values from (0..N) args" do
      Sandbox_1 = Sandboxer.spawn
      before :all do
        Sandbox_1.with self
        module Sandbox_1
          P_ = MetaHell::FUN._parse_series.curry[
            [
              -> age do
                /\A\d+\z/ =~ age
              end,
              -> sex do
                /\A(?:m(?:ale)?|f(?:emale)?|o(?:ther)?)\z/i =~ sex
              end,
              -> location do
                /\A[A-Z]/ =~ location  # must start with capital
              end
            ] ]

          P = P_.curry[
            -> e { raise ::ArgumentError, e.message_function.call }
          ]
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
      it "but now here's the rub: if you pass `false` for the error handler" do
        Sandbox_1.with self
        module Sandbox_1
          argv = [ '30', 'm', "Mom's", "Mom's again" ]
          P_[ false, argv ].should eql( [ '30', 'm', "Mom's" ] )
          argv.should eql( [ "Mom's again" ] )
        end
      end
      it "(for contrast, here's the same thing, but with an error handler:)" do
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
