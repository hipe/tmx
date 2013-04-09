require_relative 'graph/test-support'

module Skylab::TanMan::TestSupport::Models::Meaning::Graph

  # Quickie

  describe "#{ TanMan::Models::Meaning::Graph } - #{
      }RESOLVING means turning a meaning into a list #{
      }of one or more terminal meanings, So if if you try resolve" do

    extend TanMan::TestSupport::Models::Meaning::Graph

    context "with an empty graph" do
      let :graph do
        graph_from [ ]
      end

      it "any meaning - KeyError" do
        -> do
          graph.resolve_meaning_strings 'foo', nil
        end.should raise_error( ::KeyError, /key not found: :foo/ )
      end
    end

    context "with a graph with one terminal node of meaning" do

      let :graph do
        graph_from [ [ 'red', 'color=#fa0schwartz' ] ]
      end

      it "the one meaning - you got it" do
        arr = graph.resolve_meaning_strings 'red', nil
        arr.length.should eql( 1 )
        arr[0].should eql( 'color=#fa0schwartz' )
      end

      it "an unknown meaning - KeyError" do
        -> do
          graph.resolve_meaning_strings 'foo', nil
        end.should raise_error( ::KeyError, /key not found: :foo/ )
      end
    end

    context "with a graph with one non-terminal node of meaning" do

      let :graph do
        graph_from [ [ 'angry-color', 'red' ] ]
      end

      it "the one meaning - nerp" do
        interm = nil
        arr = graph.resolve_meaning_strings 'angry-color', -> x do
          interm = x
        end
        trail_a = interm.trail_a
        trail_a.length.should eql( 2 )
        trail_a.should eql( [ :'angry-color', :red ] )
        arr.should eql( false )
      end
    end

    context "with a graph with one NT and one T (related)" do

      let :graph do
        graph_from [ ['happy-color', 'foo=bar'],
                     ['happy', 'happy-color'] ]
      end

      it "the NT meaning - T" do
        arr = graph.resolve_meaning_strings 'happy', nil
        arr.length.should eql( 1 )
        arr[0].should eql( 'foo=bar' )
      end

      it "the T meaning - T" do
        arr = graph.resolve_meaning_strings 'happy-color', nil
        arr.length.should eql( 1 )
        arr[0].should eql( 'foo=bar' )
      end
    end

    context "a NT meaning that splays out into multiple terminal meanings" do

      let :graph do
        graph_from [
          [ 'zero-day', 'important' ],
          [ 'zero-day', 'urgent' ],
          [ 'urgent', 'color=red' ],
          [ 'urgent', 'border=heavy' ],
          [ 'important', 'border=heavy' ],
          [ 'important', 'icon=star' ]
        ]
      end

      it "resolves to the four terminal meanings along six arcs" do
        term_a = graph.resolve_meaning_strings 'zero-day', nil
        term_a.should eql(
          [ "border=heavy", "icon=star", "color=red", "border=heavy" ]
        )
      end
    end

    context "in a diamond graph, won't repeat meanings" do

      let :graph do
        graph_from [
          [ 'appliance', 'category=appliance' ],
          [ 'clock', 'appliance' ],
          [ 'radio', 'appliance' ],
          [ 'clock-radio', 'clock' ],
          [ 'clock-radio', 'radio' ]
        ]
      end

      it " - resolves to just the one nerk" do
        term_a = graph.resolve_meaning_strings 'clock-radio', nil
        term_a.length.should eql( 1 )
        term_a[ 0 ].should eql( 'category=appliance' )
      end
    end

    context "if unresolvable you get a semantic trail!" do

      let :graph do
        graph_from [
          [ 'done-color', 'green' ],
          [ 'finished', 'done-color' ]
        ]
      end

      it "which is cool for rich error reporting" do
        interm = nil
        arr = graph.resolve_meaning_strings 'finished', -> x do
          interm = x
        end
        trail_a = interm.trail_a
        arr.should eql( false )
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
        graph_from [
          [ 'yin', 'yang' ],
          [ 'yang', 'yin' ]
        ]
      end

      -> do

        exp = 'yin -> yang -> yin'

        it "- circular dependency: #{ exp }" do
          interm = nil
          arr = graph.resolve_meaning_strings 'yin', -> x { interm = x }
          arr.should eql( false )
          interm.reason.should eql( :circular )
          interm.trail_a.join( ' -> ' ).should eql( exp )
        end
      end.call
    end


    context "deeper circular" do

      let :graph do
        graph_from [
          [ 'fear', 'anger' ],
          [ 'anger', 'hate' ],
          [ 'hate', 'suffering' ],
          [ 'suffering', 'fear' ]
        ]
      end

      -> do

        exp = "fear -> anger -> hate -> suffering -> fear"

        it "- circ dep: #{ exp }" do
          interm = nil
          graph.resolve_meaning_strings 'fear', -> x { interm = x }
          interm.trail_a.join( ' -> ' ).should eql( exp )
        end
      end.call
    end
  end
end
