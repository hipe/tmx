require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Parse::Series

  describe "[mh] Parse::Series__" do

    it "one-shot, inline usage" do
      args = [ '30', 'other' ]
      age, sex, loc =  MetaHell_::Parse.series[ args,
        -> a { /\A\d+\z/ =~ a },
        -> s { /\A[mf]\z/i =~ s },
        -> l { /./ =~ l } ]

      age.should eql "30"
      sex.should eql nil
      loc.should eql 'other'
    end
    context "curried usage" do

      before :all do
        P = MetaHell_::Parse.series.curry[
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
      it "works to match each of the three terms" do
        P[ [ '30', 'male', "Mom's basement" ] ].should eql [ '30', 'male', "Mom's basement" ]
      end
      it "or just the first one" do
        P[ [ '30' ] ].should eql [ '30', nil, nil ]
      end
      it "or just the last one" do
        P[ [ "Mom's basement" ] ].should eql [ nil, nil, "Mom's basement" ]
      end
      it "or just the middle one, etc (note it gets precedence over last)" do
        P[ [ 'M' ] ].should eql [ nil, 'M', nil ]
      end
      it "if you set `exhaustion` to `false`, it terminates at first non-parsable" do
        argv = [ '30', 'm', "Mom's", "Mom's again" ]
        omg = P.curry[ :exhaustion, false ]
        omg[ argv ].should eql [ '30', 'm', "Mom's" ]
        argv.should eql [ "Mom's again" ]
      end
      it "(for contrast, here's the same thing, but with errors:)" do
        argv = [ '30', 'm', "Mom's", "Mom's again" ]
        -> do
          P[ argv ]
        end.should raise_error( ArgumentError,
                     ::Regexp.new( "\\Aunrecognized\\ argument\\ at\\ index\\ 3" ) )
      end
    end
    it "indicating `token_scanners` instead of `token_matchers`" do
      p = MetaHell_::Parse.series.curry[
        :token_scanners, [
          -> feet   { /\A\d+\z/ =~ feet and feet.to_i },
          -> inches { /\A\d+(?:\.\d+)?\z/ =~ inches and inches.to_f }
        ] ]

      p[ [ "8"   ] ].should eql [ 8,  nil  ]
      p[ [ "8.1" ] ].should eql [ nil, 8.1 ]
      p[ [ "8", "9" ] ].should eql [ 8, 9.0 ]
      -> do
        p[ [ "8.1", "8.2" ] ]
      end.should raise_error( ArgumentError,
                   ::Regexp.new( "\\Aunrecognized\\ argument" ) )
    end
  end
end
