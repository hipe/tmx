require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] digraph" do

    TS_[ self ]
    use :digraph

    # --*--

    context "when a class extends it" do

      context 'gives your class an "listeners_digraph" method which:' do

        it "your class responds to it" do
          expect( klass.singleton_class ).to be_private_method_defined :listeners_digraph
        end

        it "when called with an event graph, adds those types to the #{
            }types associated with the class" do

          cls = klass
          expect( cls.event_stream_graph.node_count ).to be_zero
          cls.send :listeners_digraph, scream: :sound, yell: :sound
          expect( cls.event_stream_graph.node_count ).to eql 3
        end
      end
    end

    context 'When you call "on_foo" with a block,' do

      inside do
        listeners_digraph :foo
      end

      let :touch_me do
        { touched: :was_not_touched }
      end

      let :emitter do
        o = klass.new
        o.on_foo { touch_me[:touched] = :it_was_touched }
        o
      end

      it "the well-formed call to `on_foo` will result in #{
          }the same proc you gave it, for chaining" do
        nerk = -> { }
        x = emitter.on_foo( & nerk )
        expect( x.object_id ).to eql nerk.object_id
      end

      it "the call to call_digraph_listeners( :foo ) - invokes the block." do
        expect( touch_me[:touched] ).to eql( :was_not_touched )
        res = emitter.call_digraph_listeners :foo
        expect( touch_me[:touched] ).to eql( :it_was_touched )
        expect( res ).to be_nil
      end

      it "with `callback_digraph_has?` - you can see if it emits something" do
        expect( emitter.callback_digraph_has?( :baz ) ).to eql false
        expect( emitter.callback_digraph_has?( :foo ) ).to eql true
      end
    end

    context "this klass with a typical 3-node event stream graph" do

      inside do
        listeners_digraph :informational, error: :informational, info: :informational
      end

      it "reflects on its event stream graph" do
        act = klass.event_stream_graph.describe_digraph :with_spaces, :with_solos
        exp = <<-HERE.unindent.strip
          informational
          error -> informational
          info -> informational
        HERE
        expect( act ).to eql exp
      end

      it "notifies subscribers of its child events" do
        msg = nil
        emitter.on_error do |event|
          msg = event.payload_a.first
        end
        emitter.call_digraph_listeners :error, 'yes'
        expect( msg ).to eql 'yes'
      end

      it "notifies subscribers of parent events about child events" do
        msg = nil
        emitter.on_informational do |e|
          msg = "#{ e.stream_symbol }: #{ e.payload_a.first }"
        end
        emitter.call_digraph_listeners :error, 'yes'
        expect( msg ).to eql 'error: yes'
      end

      it "will double-notify a single subscriber if it subscribes #{
          }to multiple facets of it" do
        chld = nil
        prnt = nil
        emitter.on_informational { |e| prnt = "#{e.stream_symbol}: #{e.payload_a.first}" }
        emitter.on_info          { |e| chld = "#{e.stream_symbol}: #{e.payload_a.first}" }
        emitter.call_digraph_listeners :info, 'foo'
        expect( chld ).to eql 'info: foo'
        expect( prnt ).to eql 'info: foo'
      end

      it "but the listener can check the event-id of the event if it #{
          }wants to, it will be the same event" do
        id_one = id_two = nil
        emitter.on_informational { |e| id_one = e.event_id }
        emitter.on_info          { |e| id_two = e.event_id }
        emitter.call_digraph_listeners :info
        expect( ( !! id_one ) ).to eql true
        expect( id_one ).to eql id_two
        expect( id_two ).to be_kind_of ::Integer
      end
    end

    context "You can use the touch!/touched? facility on event objects #{
        }to track whether you've seen them (but this is a smell..)" do

      inside do
        listeners_digraph :informational, error: :informational, info: :informational
      end

      it 'by explicitly touching and checking for touched?' do
        o = emitter
        c = ::Struct.new( :a, :i, :e ).new( 0, 0, 0 )
        o.on_informational do |e|
          if ! e.touched?
            e.touch!
            c.a += 1
          end
        end
        o.on_info do |e|
          c.i += 1
          e.touch!
        end
        o.on_error do |e|
          c.e += 1
        end
        o.call_digraph_listeners :informational
        expect( c.values ).to eql [ 1, 0, 0 ]
        o.call_digraph_listeners :info
        expect( c.values ).to eql [ 1, 1, 0 ]
        o.call_digraph_listeners :error
        expect( c.values ).to eql [ 2, 1, 1 ]
      end

      context "A touch will NOT happen automatically when payload is #{
        }accessed (duh)" do

        let :lines do [ ] end

        it "without touch check" do
          o = emitter
          o.on_informational { |e| lines << "inform:#{ e.payload_a.first }" }
          o.on_info          { |e| lines << "info:#{ e.payload_a.first }" }
          o.call_digraph_listeners :info, "A"
          expect( lines ).to eql %w( info:A inform:A )
        end

        it 'with touch check' do
          o = emitter
          o.on_informational { |e| lines << "inform:#{ e.payload_a.first }" unless e.touched? }
          o.on_info          { |e| lines << "info:#{ e.payload_a.first }"   unless e.touched? }
          o.call_digraph_listeners :info, "A"
          expect( lines ).to eql %w( info:A inform:A )
        end

        it 'but with an explicit touch' do
          o = emitter
          o.on_informational do |e|
            lines << "inform:#{ e.touch!.payload_a.first }" unless e.touched?
          end
          o.on_info do |e|
            lines << "info:#{ e.touch!.payload_a.first }" unless e.touched?
          end
          o.call_digraph_listeners :info, "A"
          expect( lines ).to eql %w( info:A )
        end
      end
    end

    context "Let's play with some different types of event-type graphs." do

      def inside
        sg = stream_graph         # ^^ context of the test  ^^
        -> do                     # vv context of the class vv
          listeners_digraph( *sg )
        end
      end

      context 'With an event-type tree three levels deep and two wide,' do

        let :stream_graph do [
          :all,
          error: :all,
          info: :all,
          hello: :info
        ] end

        it "triggering an event on a deepest child will trigger #{
            }the root event" do
          o = emitter
          touched = 0
          o.on_all { |e| touched += 1 }
          o.call_digraph_listeners :hello
          expect( touched ).to eql 1
        end
      end

      context "With an event stream graph that is a simple circular #{
          }directed graph (a triangle)," do

        let :stream_graph do [
          father: :son,
          ghost: :father,
          son: :ghost
        ] end

        def same which
          @counts = Hash.new { |h, k| h[ k ] = 0 }
          o = emitter
          o.on_father { |e| @counts[ :father ] += 1 }
          o.on_son    { |e| @counts[ :son ]    += 1 }
          o.on_ghost  { |e| @counts[ :ghost ]  += 1 }

          emitter.call_digraph_listeners which
          s = @counts.keys.map( & :to_s ).sort.join ' '
          expect( s ).to eql 'father ghost son'
          expect( @counts.values.count{ |v| 1 == v } ).to eql 3
        end

        it "an call_digraph_listeners to father emits to all three" do
          same :father
        end

        it "an call_digraph_listeners to son emits to all three" do
          same :son
        end

        it "an call_digraph_listeners to ghost emits to all three" do
          same :ghost
        end
      end
    end

    context "has a shorthand for creating emitter classes" do

      inside do
        listeners_digraph :one
      end

      alias_method :normal_class, :klass

      let :shorthand_class do
        Home_::Digraph.new :all, error: :all
      end

      it "which works" do
        o = normal_class.new
        s = nil
        o.on_one { |x| s = x.payload_a.first }
        o.call_digraph_listeners :one, 'sone'
        expect( s ).to eql 'sone'
        o = shorthand_class.new
        o.on_all { |e| s = e.payload_a.first.to_s }
        o.call_digraph_listeners :error, 'serr'
        expect( s ).to eql 'serr'
      end
    end

    context "will graphs defined in a parent class descend to child?" do

      inside do
        listeners_digraph :informational, error: :informational, info: :informational
      end

      let :child_class do
        ::Class.new klass
      end

      it "YES" do
        ok = nil
        o = child_class.new
        o.on_informational { |e| ok = e }
        o.call_digraph_listeners :info, "wankers"
        expect( ok.payload_a.first ).to eql 'wankers'
      end
    end
  end
end
