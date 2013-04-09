require_relative 'emitter/test-support'

module ::Skylab::PubSub::TestSupport::Emitter

  # Quickie.

  describe "#{ PubSub }::Emitter" do

    extend Emitter_TestSupport

    # --*--

    context "when a class extends it" do

      context 'gives your class an "emits" method which:' do

        it "your class responds to it" do
          klass.should be_respond_to( :emits )
        end

        it "when called with an event graph, adds those types to the #{
            }types associated with the class" do

          klass.event_stream_graph.node_count.should eql( 0 )
          klass.send :emits, scream: :sound, yell: :sound
          klass.event_stream_graph.node_count.should eql( 3 )
        end
      end
    end

    context 'When you call "on_foo" with a block,' do

      inside do
        emits :foo
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
        x = emitter.on_foo(& nerk )
        x.object_id.should eql( nerk.object_id )
      end

      it "the call to emit( :foo ) - invokes the block." do
        touch_me[:touched].should eql( :was_not_touched )
        res = emitter.emit :foo
        touch_me[:touched].should eql( :it_was_touched )
        res.should eql( nil )
      end

      it "with `emits?` - you can see if it emits something" do
        emitter.emits?( :baz ).should eql( false )
        emitter.emits?( :foo ).should eql( true )
      end
    end

    context "this klass with a typical 3-node event stream graph" do

      inside do
        emits :informational, error: :informational, info: :informational
      end

      it "reflects on its event stream graph" do
        act = klass.event_stream_graph.describe
        exp = <<-HERE.unindent.strip
          informational
          error -> informational
          info -> informational
        HERE
        act.should eql( exp )
      end

      it "notifies subscribers of its child events" do
        msg = nil
        emitter.on_error do |event|
          msg = event.payload_a.first
        end
        emitter.emit :error, 'yes'
        msg.should eql( 'yes' )
      end

      it "notifies subscribers of parent events about child events" do
        msg = nil
        emitter.on_informational do |e|
          msg = "#{ e.stream_name }: #{ e.payload_a.first }"
        end
        emitter.emit :error, 'yes'
        msg.should eql( 'error: yes' )
      end

      it "will double-notify a single subscriber if it subscribes #{
          }to multiple facets of it" do
        chld = nil
        prnt = nil
        emitter.on_informational { |e| prnt = "#{e.stream_name}: #{e.payload_a.first}" }
        emitter.on_info          { |e| chld = "#{e.stream_name}: #{e.payload_a.first}" }
        emitter.emit :info, 'foo'
        chld.should eql( 'info: foo' )
        prnt.should eql( 'info: foo' )
      end

      it "but the listener can check the event-id of the event if it #{
          }wants to, it will be the same event" do
        id_one = id_two = nil
        emitter.on_informational { |e| id_one = e.event_id }
        emitter.on_info          { |e| id_two = e.event_id }
        emitter.emit( :info )
        ( !! id_one ).should eql( true )
        id_one.should eql( id_two )
        id_two.should be_kind_of( ::Fixnum )
      end
    end

    context "You can use the touch!/touched? facility on event objects #{
        }to track whether you've seen them (but this is a smell..)" do

      inside do
        emits :informational, error: :informational, info: :informational
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
        o.emit :informational
        c.values.should eql( [1, 0, 0] )
        o.emit :info
        c.values.should eql( [1, 1, 0] )
        o.emit :error
        c.values.should eql( [2, 1, 1] )
      end

      context "A touch will NOT happen automatically when payload is #{
        }accessed (duh)" do

        let :lines do [ ] end

        it "without touch check" do
          o = emitter
          o.on_informational { |e| lines << "inform:#{ e.payload_a.first }" }
          o.on_info          { |e| lines << "info:#{ e.payload_a.first }" }
          o.emit :info, "A"
          lines.should eql( %w(info:A inform:A) )
        end

        it 'with touch check' do
          o = emitter
          o.on_informational { |e| lines << "inform:#{ e.payload_a.first }" unless e.touched? }
          o.on_info          { |e| lines << "info:#{ e.payload_a.first }"   unless e.touched? }
          o.emit :info, "A"
          lines.should eql( %w( info:A inform:A ) )
        end

        it 'but with an explicit touch' do
          o = emitter
          o.on_informational do |e|
            lines << "inform:#{ e.touch!.payload_a.first }" unless e.touched?
          end
          o.on_info do |e|
            lines << "info:#{ e.touch!.payload_a.first }" unless e.touched?
          end
          o.emit :info, "A"
          lines.should eql( %w(info:A ) )
        end
      end
    end

    context "Let's play with some different types of event-type graphs." do

      def inside
        sg = stream_graph         # ^^ context of the test  ^^
        -> do                     # vv context of the class vv
          emits( *sg )
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
            } the root event" do
          o = emitter
          touched = 0
          o.on_all { |e| touched += 1 }
          o.emit :hello
          touched.should eql( 1 )
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
          @counts = Hash.new { |h, k| h[k] = 0 }
          o = emitter
          o.on_father { |e| @counts[:father] += 1 }
          o.on_son    { |e| @counts[:son]    += 1 }
          o.on_ghost  { |e| @counts[:ghost]  += 1 }

          emitter.emit which
          s = @counts.keys.map(& :to_s ).sort.join ' '
          s.should eql( 'father ghost son' )
          @counts.values.count{ |v| 1 == v }.should eql( 3 )
        end

        it "an emit to father emits to all three" do
          same :father
        end

        it "an emit to son emits to all three" do
          same :son
        end

        it "an emit to ghost emits to all three" do
          same :ghost
        end
      end
    end

    context "has a shorthand for creating emitter classes" do

      inside do
        emits :one
      end

      alias_method :normal_class, :klass

      let :shorthand_class do
        PubSub::Emitter.new :all, error: :all
      end

      it "which works" do
        o = normal_class.new
        s = nil
        o.on_one { |x| s = x.payload_a.first }
        o.emit :one, 'sone'
        s.should eql( 'sone' )
        o = shorthand_class.new
        o.on_all { |e| s = e.payload_a.first.to_s }
        o.emit :error, 'serr'
        s.should eql( 'serr' )
      end
    end

    context "will graphs defined in a parent class descend to child?" do

      inside do
        emits :informational, error: :informational, info: :informational
      end

      let :child_class do
        ::Class.new klass
      end

      it "YES" do
        ok = nil
        o = child_class.new
        o.on_informational { |e| ok = e }
        o.emit :info, "wankers"
        ok.payload_a.first.should eql( 'wankers' )
      end
    end
  end
end
