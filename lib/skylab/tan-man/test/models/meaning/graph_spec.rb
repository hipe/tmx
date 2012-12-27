require_relative 'graph/test-support'


module Skylab::TanMan::TestSupport::Models::Meaning::Graph


  # Quickie

  describe "#{ TanMan::Models::DotFile::Meaning::Graph } - #{
    }RESOLVING means turning a meaning into a list #{
    }of one or more terminal meanings, So if if you try resolve" do

    extend TanMan::TestSupport::Models::Meaning::Graph
    context "with an empty graph" do
      let :graph do
        graph_from [ ]
      end

      it "any meaning - KeyError" do
        meaning = new_meaning 'foo', 'bar'
        -> do
          graph.resolve meaning, nil
        end.should raise_error( ::KeyError, /key not found: :foo/ )
      end
    end


    context "with a graph with one terminal node of meaning" do

      let :graph do
        graph_from [ [ 'red', 'color=#fa0schwartz' ] ]
      end

      it "the one meaning - you got it" do
        meaning = _meaning 'red'
        arr = graph.resolve meaning, nil
        arr.length.should eql(1)
        arr.first.should eql(meaning)
      end

      it "an unknown meaning - KeyError" do
        meaning = new_meaning 'foo', 'bar'
        -> do
          graph.resolve meaning, nil
        end.should raise_error( ::KeyError, /key not found: :foo/ )
      end
    end


    context "with a graph with one non-terminal node of meaning" do

      let :graph do
        graph_from [ [ 'angry-color', 'red' ] ]
      end

      it "the one meaning - nerp" do
        meaning = _meaning 'angry-color'
        nerp = nil
        arr = graph.resolve meaning, -> x do
          nerp = x
        end
        nerp.trail.length.should eql(1)
        nerp.trail.first.should eql(meaning)
        arr.should eql(false)
      end
    end


    context "with a graph with one NT and one T (related)" do

      let :graph do
        graph_from [ ['happy-color', 'foo=bar'],
                     ['happy', 'happy-color'] ]
      end

      it "the NT meaning - T" do
        nt = _meaning 'happy'
        t = _meaning 'happy-color'
        arr = graph.resolve nt, nil
        arr.length.should eql(1)
        arr.first.should eql(t)
      end

      it "the T meaning - T" do
        nt = _meaning 'happy'
        t = _meaning 'happy-color'
        arr = graph.resolve t, nil
        arr.length.should eql(1)
        arr.first.should eql(t)
      end
    end


    context "a NT meaning that splays out into multiple terminal meanings" do
      let :graph do
        graph_from [
          ['zero-day', 'important'],
          ['zero-day', 'urgent'],
          ['urgent', 'color=red'],
          ['urgent', 'border=heavy'],
          ['important', 'border=heavy'],
          ['important', 'icon=star']
        ]
      end
      it "resolves to 3 unique definitions but gives you 4 meanings!" do
        top = _meaning 'zero-day' # *NOTE* this has multiple meanings
        arr = graph.resolve top, nil
        arr.map(&:symbol).should eql([:important, :important, :urgent, :urgent])
        arr.map(&:value).should eql(
          ["border=heavy", "icon=star", "color=red", "border=heavy"] )
      end
    end

    context "in a diamond graph, won't repeat meanings" do
      let :graph do
        graph_from [
          ['appliance', 'category=appliance'],
          ['clock', 'appliance'],
          ['radio', 'appliance'],
          ['clock-radio', 'clock'],
          ['clock-radio', 'radio']
        ]
      end

      it " - resolves to just the one nerk" do
        top = _meaning 'clock-radio' # *NOTE* this has multiple meanings
        arr = graph.resolve top, nil
        arr.length.should eql(1)
      end
    end

    context "if unresolvable you get a semantic trail!" do
      let :graph do
        graph_from [
          ['done-color', 'green'],
          ['finished', 'done-color']
        ]
      end
      it "which is cool for rich error reporting" do
        top = _meaning 'finished'
        nerp = nil
        arr = graph.resolve top, -> x do
          nerp = x
        end
        o = nerp.trail.shift
        a = [ "#{ o.name } means #{ o.value }" ]
        while o_ = nerp.trail.shift
          o = o_
          a.push " and #{ o.name } means #{ o.value }"
        end
        a.push ", but #{ o.value } has no meaning."
        exp = "finished means done-color and done-color means green, #{
          }but green has no meaning."
        a.join.should eql(exp)
      end
    end


    circ_str = -> nerp do
      nerp.trail.map { |m| "#{ m.name } -> #{ m.value }" }.join ', '
    end


    context "simple circular" do
      let :graph do
        graph_from [
          ['yin', 'yang'],
          ['yang', 'yin']
        ]
      end
      -> do
        exp = 'yin -> yang, yang -> yin'
        it "- circular dependency: #{ exp }" do
          top = _meaning 'yin'
          nerp = nil
          arr = graph.resolve top, -> x { nerp = x }
          arr.should eql( false )
          nerp.reason.should eql( :circular )
          msg = circ_str[ nerp ]
          msg.should eql( exp )
        end
      end.call
    end


    context "deeper circular" do
      let :graph do
        graph_from [
          ['fear', 'anger'],
          ['anger', 'hate'],
          ['hate', 'suffering'],
          ['suffering', 'fear']
        ]
      end

      -> do
        exp = "fear -> anger, anger -> hate, hate -> suffering, #{
          }suffering -> fear"

        it "- circ dep: #{ exp }" do
          top = _meaning 'fear'
          nerp = nil
          graph.resolve top, -> x { nerp = x }
          msg = circ_str[ nerp ]
          msg.should eql( exp )
        end
      end.call
    end
  end
end
