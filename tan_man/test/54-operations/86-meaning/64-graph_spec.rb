require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - meaning graph (resolving (i.e expand NT into N T's))" do

    TS_[ self ]
    use :models_meaning

    # ~( (for now, let legacy code remain as is but blow up when etc)
    def self.let sym, & p
      :graph == sym || TS_.no
      yes = nil
      define_method :graph do
        yes && TS_.no
        yes = true
        _graph = instance_exec( & p )
        _graph  # #todo
      end
    end
    # ~)

    context "with an empty graph" do

      let :graph do
        graph_from
      end

# (1/N)
      it "any meaning - KeyError" do
        begin
          graph.meaning_values_via_meaning_name 'foo'
        rescue ::KeyError => e
        end
        e.message =~ /\Akey not found: :foo\z/ or fail
      end
    end

    context "with a graph with one terminal node of meaning" do

      shared_subject :graph do
        graph_from( [ 'red', 'color=#fa0schwartz' ] )
      end

# (2/N)
      it "the one meaning - you got it" do
        arr = graph.meaning_values_via_meaning_name 'red'
        expect( arr.length ).to eql 1
        expect( arr[0] ).to eql 'color=#fa0schwartz'
      end

# (3/N)
      it "an unknown meaning - KeyError" do
        begin
          graph.meaning_values_via_meaning_name 'foo'
        rescue ::KeyError => e
        end
        e.message =~ /\Akey not found: :foo\b/ or fail
      end
    end

    context "with a graph with one non-terminal node of meaning" do

      let :graph do
        graph_from( [ 'angry-color', 'red' ] )
      end

# (4/N)
      it "the one meaning - nerp" do

        ev = nil

        arr = graph.meaning_values_via_meaning_name 'angry-color' do | *, & ev_p |
          ev = ev_p[]
          :_TM_NO_SEE_
        end

        arr == false || fail
        trail_a = ev.trail_a
        expect( trail_a.length ).to eql 2
        expect( trail_a ).to eql [ :'angry-color', :red ]
      end
    end

    context "with a graph with one NT and one T (related)" do

      shared_subject :graph do
        graph_from( ['happy-color', 'foo=bar'],
                     ['happy', 'happy-color'] )
      end

# (5/N)
      it "the NT meaning - T" do
        arr = graph.meaning_values_via_meaning_name 'happy'
        expect( arr.length ).to eql 1
        expect( arr[0] ).to eql 'foo=bar'
      end

# (6/N)
      it "the T meaning - T" do
        arr = graph.meaning_values_via_meaning_name 'happy-color'
        expect( arr.length ).to eql 1
        expect( arr[0] ).to eql 'foo=bar'
      end
    end

    context "a NT meaning that splays out into multiple terminal meanings" do

      let :graph do
        graph_from(
          [ 'zero-day', 'important' ],
          [ 'zero-day', 'urgent' ],
          [ 'urgent', 'color=red' ],
          [ 'urgent', 'border=heavy' ],
          [ 'important', 'border=heavy' ],
          [ 'important', 'icon=star' ] )
      end

# (7/N)
      it "resolves to the four terminal meanings along six arcs" do
        expect( graph.meaning_values_via_meaning_name( 'zero-day' ) ).to eql(
          [ "border=heavy", "icon=star", "color=red", "border=heavy" ]
        )
      end
    end

    context "in a diamond graph, won't repeat meanings" do

      let :graph do
        graph_from(
          [ 'appliance', 'category=appliance' ],
          [ 'clock', 'appliance' ],
          [ 'radio', 'appliance' ],
          [ 'clock-radio', 'clock' ],
          [ 'clock-radio', 'radio' ] )
      end

# (8/N)
      it " - resolves to just the one nerk" do
        term_a = graph.meaning_values_via_meaning_name 'clock-radio'
        expect( term_a.length ).to eql 1
        expect( term_a[ 0 ] ).to eql 'category=appliance'
      end
    end

    context "if unresolvable you get a semantic trail!" do

      let :graph do
        graph_from(
          [ 'done-color', 'green' ],
          [ 'finished', 'done-color' ] )
      end

# (9/N)
      it "which is cool for rich error reporting" do

        ev = nil

        arr = graph.meaning_values_via_meaning_name 'finished' do | *, & ev_p |
          ev = ev_p[]
          :_TM_NO_SEE_
        end

        arr == false || fail

        trail_a = ev.trail_a
        stack_a = [ "#{ trail_a.last } has no meaning." ]
        if 1 < trail_a.length
          stack_a << "#{ trail_a[-2] } means #{ trail_a[-1] }, but "
          trail_a.pop
        end
        while 1 < trail_a.length
          stack_a << "#{ trail_a[-2] } means #{ trail_a[-1] } and "
          trail_a.pop
        end
        msg = stack_a.reverse.join
        exp = "finished means done-color and done-color means green, #{
          }but green has no meaning."
        expect( msg ).to eql exp
      end
    end

    context "simple circular" do

      let :graph do
        graph_from(
          [ 'yin', 'yang' ],
          [ 'yang', 'yin' ] )
      end

      -> do

        exp = 'yin -> yang -> yin'

# (10/N)
        it "- circular dependency: #{ exp }" do

          ev = nil

          arr = graph.meaning_values_via_meaning_name 'yin' do | *, & ev_p |
            ev = ev_p[]
            :_TM_NO_SEE_
          end

          arr == false || fail
          expect( ev.reason ).to eql :circular
          expect( ev.trail_a.join( ' -> ' ) ).to eql exp
        end
      end.call
    end


    context "deeper circular" do

      let :graph do
        graph_from(
          [ 'fear', 'anger' ],
          [ 'anger', 'hate' ],
          [ 'hate', 'suffering' ],
          [ 'suffering', 'fear' ] )
      end

      -> do

        exp = "fear -> anger -> hate -> suffering -> fear"

# (11/N)
        it "- circ dep: #{ exp }" do

          ev = nil
          _x = graph.meaning_values_via_meaning_name 'fear' do | *, & ev_p |
            ev = ev_p[]
            :_TM_NO_SEE_
          end

          ev.trail_a.join( ' -> ' ) == exp || fail

          _x == false || fail

        end
      end.call
    end
  end
end
