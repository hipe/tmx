require File.expand_path('../../emitter', __FILE__)
require File.expand_path('../test-support', __FILE__)

describe Skylab::PubSub::Emitter do
  let(:klass) do
    Class.new.class_eval do
      extend GSkylab::PubSub::Emitter
      emits :informational, :error => :informational, :info => :informational
      self
    end
  end
  let(:instance) { klass.new }
  let(:emitter) { klass.new }
  def _see o
    "#<#{o.class}:0x%x>" % [o.object_id]
  end
  context 'when extended by a class' do
    let(:inside) { ->(_) { } }
    let(:klass) do
      o = self
      Class.new.class_eval do
        extend Skylab::PubSub::Emitter
        def self.to_s ; 'Foo' end
        class_eval(& o.inside)
        self
      end
    end
    subject { klass }
    context 'gives your class an "emits" method which:' do
      specify { should be_respond_to(:emits) }
      it 'when called with an event graph, adds those types to the types associated with the class' do
        klass.event_cloud.size.should eql(0)
        klass.emits :scream => :sound, :yell => :sound
        klass.event_cloud.size.should eql(3)
      end
      context "Let's learn about emits() with a story about a class named Foo." do
        context 'At first, the Foo class of course does not have a method called "on_bar", it:' do
          specify { should_not be_public_method_defined(:on_bar) }
        end
        context 'Once it declares that it emits an event of type :bar' do
          let(:inside) { ->(_) { emits :bar } }
          context 'then gets a method called "on_bar":, i.e. it:' do
            specify { should be_public_method_defined(:on_bar) }
          end
          context 'then with objects of class Foo you can then call on_bar.' do
            context 'It expects you to call on_bar with a block, not doing so:' do
              subject { ->() { instance.on_bar } }
              specify { should raise_exception(ArgumentError, /no block given/i) }
            end
            context 'When you call "on_bar" with a block,' do
              let(:touch_me) { { touched: :was_not_touched } }
              let(:instance) do
                o = klass.new
                o.on_bar { touch_me[:touched] = :it_was_touched }
                o
              end
              context '(the well-formed call to on_bar will return your same instance again, for chaining:)' do
                let(:instance) { klass.new }
                subject { _see(instance.on_bar{ || }) }
                specify { should eql(_see instance) }
              end
              context  'the handler block will not have been called at first. Out of the box the canary:' do
                subject { touch_me[:touched] }
                specify { should eql(:was_not_touched) }
                context 'but if you then emit one such event with a call to "emit(:bar)", the canary:' do
                  before { instance.emit(:bar) }
                  specify { should eql(:it_was_touched) }
                end
              end
            end
          end
        end
      end
    end
  end
  it 'describes its tag graph' do
    emitter.class.event_cloud.describe.should eql(<<-HERE.unindent.strip)
      informational
      error -> informational
      info -> informational
    HERE
  end
  it 'notifies subscribers of its child events' do
    the_msg = nil
    emitter.on_error do |event|
      the_msg = event.message
    end
    emitter.emit(:error, 'yes')
    the_msg.should eql('yes')
  end
  it 'notifies subscribers of parent events about child events' do
    the_msg = nil
    emitter.on_informational { |e| the_msg = "#{e.type}: #{e.message}" }
    emitter.emit(:error, 'yes')
    the_msg.should eql('error: yes')
  end
  it 'will double-notify a single subscriber if it subscribes to multiple facets of it' do
    the_child_msg = nil
    the_parent_msg = nil
    emitter.on_informational { |e| the_parent_msg = "#{e.type}: #{e.message}" }
    emitter.on_info          { |e| the_child_msg  = "#{e.type}: #{e.message}" }
    emitter.emit(:info, 'foo')
    the_child_msg.should eql('info: foo')
    the_parent_msg.should eql('info: foo')
  end
  it 'but the listener can check the event-id of the event if it wants to, it will be the same event' do
    id_one = id_two = nil
    emitter.on_informational { |e| id_one = e.event_id }
    emitter.on_info          { |e| id_two = e.event_id }
    emitter.emit(:info)
    id_one.should_not eql(nil)
    id_one.should eql(id_two)
    id_two.should be_kind_of(Fixnum)
  end
  context 'With regards to the parameters passed to your event handlers' do
    let(:emits) { ->(_) { } }
    let(:klass) do
      o = self
      Class.new.class_eval do
        extend ::Skylab::PubSub::Emitter
        class_eval(& o.emits)
        self
      end
    end
    context 'with a simple emit interface of one event type' do
      let(:emits) { ->(_) { emits :bar } }
      let(:canary) { { } }
      context "when you emit a :bar type event with zero arguments" do
        context 'if your event handler takes a variable number of arguments, emitting such an event' do
          let(:instance) do
            klass.new.on_bar { |*a| canary[:args] = a } # expects chaining-style return value
          end
          subject { canary[:args] }
          context 'with zero payload arguments passes zero to your handlers.' do
            before  { instance.emit(:bar) }
            specify { should eql([]) }
          end
          context 'with one payload argument passes one to your handlers.' do
            before  { instance.emit(:bar, 'foo') }
            specify { should eql(['foo']) }
          end
          context 'with two payload arguments passes two to your handlers.' do
            before  { instance.emit(:bar, 'one', 2) }
            specify { should eql(['one', 2]) }
          end
        end
        context 'if your event handler takes exactly one argument, emitting such an event' do
          let(:instance) do
            klass.new.on_bar { |one| canary[:arg] = one } # expects chaining-style return value
          end
          subject { canary[:arg] }
          context 'with zero payload arguments passes one event object to your handlers.' do
            before  { instance.emit(:bar) }
            specify { should be_kind_of(::Skylab::PubSub::Event) }
            context "whose payload" do
              subject { canary[:arg].payload }
              specify { should eql([]) }
            end
          end
          context 'with one payload argument passes one to your handlers.' do
            before  { instance.emit(:bar, 'foo') }
            specify { should be_kind_of(::Skylab::PubSub::Event) }
            context "whose payload" do
              subject { canary[:arg].payload }
              specify { should eql(['foo']) }
            end
          end
          context 'with two payload arguments passes two to your handlers.' do
            before  { instance.emit(:bar, 'foo', 'baz') }
            specify { should be_kind_of(::Skylab::PubSub::Event) }
            context "whose payload" do
              subject { canary[:arg].payload }
              specify { should eql(['foo', 'baz']) }
            end
          end
        end
        context 'if your event handler takes exactly two arguments, emitting such an event' do
          let(:instance) do
            klass.new.on_bar { |a, b| canary[:args] = [a, b] } # expects chaining-style return value
          end
          subject { canary[:args] }
          context 'with zero payload arguments passes two nils to your handlers.' do
            before  { instance.emit(:bar) }
            specify { should eql([nil, nil]) }
          end
          context 'with one payload "foo" argument passes to following to your handlers:' do
            before  { instance.emit(:bar, 'foo') }
            specify { should eql(['foo', nil]) }
          end
          context 'with two payload arguments passes two to your handlers.' do
            before  { instance.emit(:bar, 'one', 2) }
            specify { should eql(['one', 2]) }
          end
        end
      end
    end
  end
  context "You can use the touch!/touched? facility on event objects to track whether you've seen them" do
    it 'by explicitly touching and checking for touched?' do
      emitter.tap do |e|
        c = Struct.new(:a, :i, :e).new(0, 0, 0)
        e.on_informational { |e| if ! e.touched? then e.touch! ; c.a += 1  end }
        e.on_info { |e| c.i += 1 ; e.touch! }
        e.on_error { |e| c.e += 1 }
        e.emit(:informational)
        c.values.should eql([1, 0, 0])
        e.emit(:info)
        c.values.should eql([1, 1, 0])
        e.emit(:error)
        c.values.should eql([2, 1, 1])
      end
    end
    context 'A touch will happen automatically when a message is accessed ("to_s" is aliases to "message")' do
      it 'without touch check' do
        emitter.tap do |e|
          lines = []
          e.on_informational { |e| lines << "inform:#{e}" }
          e.on_info          { |e| lines << "info:#{e}" }
          e.emit(:info, "A")
          lines.should eql(%w(info:A inform:A))
        end
      end
      it 'with touch check' do
        emitter.tap do |e|
          lines = []
          e.on_informational { |e| lines << "inform:#{e}" unless e.touched? }
          e.on_info          { |e| lines << "info:#{e}"   unless e.touched? }
          e.emit(:info, "A")
          lines.should eql(%w(info:A))
        end
      end
    end
  end
  context "Let's play with some different types of event-type graphs." do
    let(:klass) do
      kg = klass_graph
      Class.new.class_eval do
        extend Skylab::PubSub::Emitter
        emits *kg
        self
      end
    end
    context 'With an event-type tree three levels deep and two wide,' do
      let(:klass_graph){[
        :all,
        :error => :all,
        :info => :all,
        :hello => :info
      ]}
      it 'triggering an event on a deepest child will trigger the root event' do
        emitter.tap do |e|
          touched = 0
          e.on_all { |e| touched += 1 }
          e.emit(:hello)
          touched.should eql(1)
        end
      end
    end
    context "With an event type tree that is a simple circular directed graph (a triangle)," do
      let(:klass_graph) {[{
        :father => :son,
        :ghost  => :father,
        :son    => :ghost
      }]}
      before(:each) do
        @counts = Hash.new { |h, k| h[k] = 0 }
        emitter.tap do |e|
          e.on_father { |e| @counts[:father] += 1 }
          e.on_son    { |e| @counts[:son]    += 1 }
          e.on_ghost  { |e| @counts[:ghost]  += 1 }
        end
      end
      def same which
        emitter.emit(which)
        @counts.keys.map(&:to_s).sort.join(' ').should eql('father ghost son')
        @counts.values.count{ |v| 1 == v }.should eql(3)
      end
      it ('an emit to this one emits to all three') { same(:father) }
      it ('an emit to this one emits to all three') { same(:son) }
      it ('an emit to this one emits to all three') { same(:ghost) }
    end
  end
  context "has a shorthand" do
    let(:normal_class) do
      Class.new.class_eval do
        extend Skylab::PubSub::Emitter
        emits :one
        self
      end
    end
    let(:shorthand_class) do
      Skylab::PubSub::Emitter.new(:all, :error => :all)
    end
    it 'which works', {f:true} do
      e = normal_class.new
      s = nil
      e.on_one { |x| s = x.to_s }
      e.emit(:one, 'sone')
      s.should eql('sone')
      e = shorthand_class.new
      e.on_all { |e| s = e.to_s }
      e.emit(:error, 'serr')
      s.should eql('serr')
    end
  end
end

