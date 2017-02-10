require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] event - structured expressive" do

    TS_[ self ]
    use :memoizer_methods

    # NOTE - these are doctest tests. they are generated from the comments
    # in the asset code. that is why they are so hard to read :(

    # at writing we have moved this pair here (asset and test) from
    # elsewhere without regenerating it anew..
    # it's not even clear if etc..

    it "loads" do
      _subject_module
    end

    context "this is a class that makes classes, similar to platform ::Struct." do

      before :all do
        X_e_e_Wing_Wang_Predicate = _Subject.new :wing, :wang, -> do
          "wing is: #{ @wing }, wang: #{ @wang }"
        end
      end

      shared_subject :expr do
        X_e_e_Wing_Wang_Predicate.new 'DING', 'DANG'
      end

      it "if we want we can read those member values with readers" do
        expr.wing.should eql 'DING'
        expr.wang.should eql 'DANG'
      end

      it "expression object" do
        expr.instance_exec( & expr.expression_proc ).should eql "wing is: DING, wang: DANG"
      end
    end

    context "alternately you can define the proc to take arguments" do

      before :all do
        X_e_e_ArgTaker = _Subject.new :a, :b, -> a, b { "#{ a } + #{ b }" }
      end

      it "call `string_via_express` to produce an expression string" do
        _expr = X_e_e_ArgTaker[ "one", "two" ]  # same as `.new(..)`

        _expr.string_via_express.should eql "one + two"
      end
    end

    context "even better, you can define the articulation class with only a" do

      before :all do
        X_e_e_EvenBetter = _Subject.new do |a, b|
          "#{ a } + #{ b }"
        end
      end

      it "are. (we have used platform proc reflection to get those names)" do
        X_e_e_EvenBetter.members.should eql [ :a, :b ]
      end

      it "and we can express like the \"arg taker\" form above" do
        _expr = X_e_e_EvenBetter.new "one", "two"
        _expr.string_via_express.should eql "one + two"
      end
    end

    context "because the expression proc is exposed as the ordinary proc that it" do

      before :all do
        module X_e_e_My

          class CustomExpressionAgent
            def em s
              "__#{ s.upcase }__"
            end
          end

          cls = Skylab::Common::Event::StructuredExpressive

          ErrorPredicate = cls.new( :name, :value, -> me do
            n, v = me.at :name, :value
            "#{ n } had a #{ em 'bad' } issue - #{ v }"
          end )
        end
      end

      it "allowing for a bit of dependency injection" do

        expr = X_e_e_My::ErrorPredicate.new 'I', 'burnout'

        _expag = X_e_e_My::CustomExpressionAgent.new

        _s = _expag.instance_exec expr, & expr.expression_proc

        _s.should eql "I had a __BAD__ issue - burnout"
      end
    end

    context "`to_a` is available.." do

      before :all do
        X_e_e_Pair = _Subject.new :up, :down, -> up, down do
          "#{ up } and #{ down }"
        end
      end

      it "..if for example you wanted to mimic `string_via_express`" do
        expr = X_e_e_Pair.new 'hi', 'lo'
        ( expr.expression_proc[ * expr.to_a ] ).should eql 'hi and lo'
      end
    end

    context "expression instances have a stupid simple but powerful algorithm" do

      before :all do

        module X_e_e_These

          o = Skylab::Common::Event::StructuredExpressive

          NP = o.new :a, -> a { a * ' and ' }

          VP = o.new :tense, :a, -> t, a do
            :present == t ? ( 1 == a.length ? 'has' : 'have' ) : 'had'
          end
        end
      end

      it "it's a bit obtuse (i don't understand it today) but it's almost magical" do

        o = X_e_e_These
        vp = o::VP ; np = o::NP

        ( np[ [ 'jack' ] ] | vp[ :present ] ).inflect.should eql "jack has"

        ( np[ %w(Jack Jill) ] | vp[ :present ] ).inflect.should eql "Jack and Jill have"

        ( np[ %w( Jack ) ] | vp[ :past ] ).inflect.should eql "Jack had"
      end
    end

    def self._Subject
      Home_::Event::StructuredExpressive
    end

    def _Subject  # eew r.s only
      self.class._Subject
    end

    alias_method :_subject_module, :_Subject  # for hand-written tests, looks better
  end
end
