require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - meaning graph (resolving (i.e expand NT into N T's))" do

    TS_[ self ]
    use :the_method_called_let
    use :models_meaning_graph

    context "with an empty graph" do

      let :graph do
        graph_from
      end

      it "any meaning - KeyError" do
        -> do
          graph.meaning_values_via_meaning_name 'foo'
        end.should raise_error( ::KeyError, /key not found: :foo/ )
      end
    end

    context "with a graph with one terminal node of meaning" do

      let :graph do
        graph_from( [ 'red', 'color=#fa0schwartz' ] )
      end

      it "the one meaning - you got it" do
        arr = graph.meaning_values_via_meaning_name 'red'
        arr.length.should eql( 1 )
        arr[0].should eql( 'color=#fa0schwartz' )
      end

      it "an unknown meaning - KeyError" do
        -> do
          graph.meaning_values_via_meaning_name 'foo'
        end.should raise_error( ::KeyError, /key not found: :foo/ )
      end
    end

    context "with a graph with one non-terminal node of meaning" do

      let :graph do
        graph_from( [ 'angry-color', 'red' ] )
      end

      it "the one meaning - nerp" do

        ev = nil

        arr = graph.meaning_values_via_meaning_name 'angry-color' do | *, & ev_p |
          ev = ev_p[]
          :_TM_NO_SEE_
        end

        arr == false || fail
        trail_a = ev.trail_a
        trail_a.length.should eql( 2 )
        trail_a.should eql( [ :'angry-color', :red ] )
      end
    end

    context "with a graph with one NT and one T (related)" do

      let :graph do
        graph_from( ['happy-color', 'foo=bar'],
                     ['happy', 'happy-color'] )
      end

      it "the NT meaning - T" do
        arr = graph.meaning_values_via_meaning_name 'happy'
        arr.length.should eql( 1 )
        arr[0].should eql( 'foo=bar' )
      end

      it "the T meaning - T" do
        arr = graph.meaning_values_via_meaning_name 'happy-color'
        arr.length.should eql( 1 )
        arr[0].should eql( 'foo=bar' )
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

      it "resolves to the four terminal meanings along six arcs" do
        graph.meaning_values_via_meaning_name( 'zero-day' ).should eql(
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

      it " - resolves to just the one nerk" do
        term_a = graph.meaning_values_via_meaning_name 'clock-radio'
        term_a.length.should eql( 1 )
        term_a[ 0 ].should eql( 'category=appliance' )
      end
    end

    context "if unresolvable you get a semantic trail!" do

      let :graph do
        graph_from(
          [ 'done-color', 'green' ],
          [ 'finished', 'done-color' ] )
      end

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
        msg.should eql( exp )
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

        it "- circular dependency: #{ exp }" do

          ev = nil

          arr = graph.meaning_values_via_meaning_name 'yin' do | *, & ev_p |
            ev = ev_p[]
            :_TM_NO_SEE_
          end

          arr == false || fail
          ev.reason.should eql :circular
          ev.trail_a.join( ' -> ' ).should eql exp
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
