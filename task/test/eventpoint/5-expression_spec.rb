require_relative '../test-support'

module Skylab::Task::TestSupport

  describe "[ta] eventpoint - articulator" do

    TS_[ self ]
    use :eventpoint

    it "this generates a simple articulator class." do

      _Wing_Wang_Predicate = _subject.
        new( :wing, :wang, -> do
          "wing is: #{ @wing }, wang: #{ @wang }"
        end )

      obj = _Wing_Wang_Predicate.new 'DING', 'DANG'

      obj.wing.should eql 'DING'

      obj.wang.should eql 'DANG'

      obj.instance_exec( & obj.articulation_proc ).should eql "wing is: DING, wang: DANG"
    end

    it "with `articulate_self` pass the same fields in as arguments" do

      o = _subject.new( :a, :b, -> a, b { "#{ a } + #{ b }" } )

      o[ "one", "two" ].articulate_self.should eql "one + two"
    end

    it "definine the articulator with ony one function" do

      o = _subject.new do |a, b|
        "#{ a } + #{ b }"
      end

      o[ "one", "two" ].articulate_self.should eql "one + two"
    end

    it "other times you might do clever things with the rendering context" do

      _Error_Predicate = _subject.new(
        :name, :val, -> o do
          n, v = o.at :name, :val
          "#{ n } had a #{ em 'bad' } issue - #{ v }"
        end )

      err = _Error_Predicate.new 'I', 'burnout'

      o = ::Object.new
      def o.em s ; "__#{ s.upcase }__" end

      exp = "I had a __BAD__ issue - burnout"
      ( o.instance_exec err, & err.articulation_proc ).should eql exp
    end

    it "write your proc signature however you like, e.g use `to_a`" do
      _Art = _subject.new :up, :down, -> up, down do
        "#{ up } and #{ down }"
      end

      p = _Art.new( 'hi', 'lo' )
      p.articulation_proc[ * p.to_a ].should eql 'hi and lo'
    end

    it "articulators have a stupid simple but powerful algorithm for inflection" do

      o = _subject

      _NP = o[ :a, -> a { a * ' and ' } ]

      _VP = o[ :tense, :a, -> t, a do
        :present == t ? ( 1 == a.length ? 'has' : 'have' ) : 'had'
      end ]

      ( _NP[ [ 'jack' ] ] | _VP[ :present ] ).inflect.should eql "jack has"

      ( _NP[ %w(Jack Jill) ] | _VP[ :present ] ).inflect.should eql "Jack and Jill have"

      ( _NP[ %w( Jack ) ] | _VP[ :past ] ).inflect.should eql "Jack had"
    end

    def _subject
      subject_::Expression_
    end
  end
end
