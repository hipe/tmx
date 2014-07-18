require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Parse::Series__

  describe "[mh] Parse::Series__" do
    context "parse out (a fixed) N values from M args" do
      Sandbox_1 = Sandboxer.spawn
      it "one-shot, inline usage" do
        Sandbox_1.with self
        module Sandbox_1
          args = [ '30', 'other' ]
          age, sex, loc =  MetaHell::Parse.series[ args,
            -> a { /\A\d+\z/ =~ a },
            -> s { /\A[mf]\z/i =~ s },
            -> l { /./ =~ l } ]

          age.should eql( "30" )
          sex.should eql( nil )
          loc.should eql( 'other' )
        end
      end
    end
    context "`curry` can make your code more readable and may improve performance" do
      Sandbox_2 = Sandboxer.spawn
      before :all do
        Sandbox_2.with self
        module Sandbox_2
          P = MetaHell::Parse.series.curry[
            :token_matchers, [
              -> age do
                /\A\d+\z/ =~ age
              end,
              -> sex do
                /\A(?:m(?:ale)?|f(?:emale)?|o(?:ther)?)\z/i =~ sex
              end,
              -> location do
                /\A[A-Z]/ =~ location   # must start with capital
              end
          ] ]
        end
      end
      it "e.g curry this parser by giving it `matchers` in advance of usage" do
        Sandbox_2.with self
        module Sandbox_2
          P[ [ '30', 'male', "Mom's basement" ] ].should eql( [ '30', 'male', "Mom's basement" ] )
        end
      end
      it "or just the first one" do
        Sandbox_2.with self
        module Sandbox_2
          P[ [ '30' ] ].should eql( [ '30', nil, nil ] )
        end
      end
      it "or just the last one" do
        Sandbox_2.with self
        module Sandbox_2
          P[ [ "Mom's basement" ] ].should eql( [ nil, nil, "Mom's basement" ] )
        end
      end
      it "or just the middle one, etc (note it gets precedence over last)" do
        Sandbox_2.with self
        module Sandbox_2
          P[ [ 'M' ] ].should eql( [ nil, 'M', nil ] )
        end
      end
      it "if you set `exhaustion` to `false`, it terminates at first non-parsable" do
        Sandbox_2.with self
        module Sandbox_2
          argv = [ '30', 'm', "Mom's", "Mom's again" ]
          omg = P.curry[ :exhaustion, false ]
          omg[ argv ].should eql( [ '30', 'm', "Mom's" ] )
          argv.should eql( [ "Mom's again" ] )
        end
      end
      it "(for contrast, here's the same thing, but with errors:)" do
        Sandbox_2.with self
        module Sandbox_2
          argv = [ '30', 'm', "Mom's", "Mom's again" ]
          -> do
            P[ argv ]
          end.should raise_error( ArgumentError,
                       ::Regexp.new( "\\Aunrecognized\\ argument\\ at\\ index\\ 3" ) )
        end
      end
    end
    context "changing it from a matching parser to a scanning parser" do
      Sandbox_3 = Sandboxer.spawn
      it "indicate `token_scanners` instead of `token_matchers`" do
        Sandbox_3.with self
        module Sandbox_3
          P = MetaHell::Parse.series.curry[
            :token_scanners, [
              -> feet   { /\A\d+\z/ =~ feet and feet.to_i },
              -> inches { /\A\d+(?:\.\d+)?\z/ =~ inches and inches.to_f }
            ] ]

          P[ [ "8"   ] ].should eql( [ 8,  nil  ] )
          P[ [ "8.1" ] ].should eql( [ nil, 8.1 ] )
          P[ [ "8", "9" ] ].should eql( [ 8, 9.0 ] )
          -> do
            P[ [ "8.1", "8.2" ] ]
          end.should raise_error( ArgumentError,
                       ::Regexp.new( "\\Aunrecognized\\ argument" ) )
        end
      end
    end
  end
end
