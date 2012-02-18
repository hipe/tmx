require File.expand_path('../../emitter', __FILE__)
require File.expand_path('../test-support', __FILE__)

describe Skylab::PubSub::Emitter do
  let(:klass) do
    Class.new.class_eval do
      extend Skylab::PubSub::Emitter
      emits :informational, :error => :informational, :info => :informational
      self
    end
  end
  let(:emitter) { klass.new }
  it "describes its tag graph" do
    emitter.class.event_cloud.describe.should eql(<<-HERE.deindent)
      informational
      error -> informational
      info -> informational
    HERE
  end
  it "notifies subscribers of its child events" do
    the_msg = nil
    emitter.on_error do |event|
      the_msg = event.message
    end
    emitter.emit(:error, 'yes')
    the_msg.should eql('yes')
  end
  it "notifies subscribers of parent events about child events" do
    the_msg = nil
    emitter.on_informational { |e| the_msg = "#{e.type}: #{e.message}" }
    emitter.emit(:error, 'yes')
    the_msg.should eql('error: yes')
  end
  it "will double-notify a single subscriber if it subscribes to multiple facets of it" do
    the_child_msg = nil
    the_parent_msg = nil
    emitter.on_informational { |e| the_parent_msg = "#{e.type}: #{e.message}" }
    emitter.on_info          { |e| the_child_msg  = "#{e.type}: #{e.message}" }
    emitter.emit(:info, "foo")
    the_child_msg.should eql("info: foo")
    the_parent_msg.should eql("info: foo")
  end
  it "but the listener can check the event-id of the event if it wants to, it will be the same event", {focus:true} do
    id_one = id_two = nil
    emitter.on_informational { |e| id_one = e.event_id }
    emitter.on_info          { |e| id_two = e.event_id }
    emitter.emit(:info)
    id_one.should_not eql(nil)
    id_one.should eql(id_two)
    id_two.should be_kind_of(Fixnum)
  end
  context "graphs" do
    let(:klass) do
      kg = klass_graph
      Class.new.class_eval do
        extend Skylab::PubSub::Emitter
        emits *kg
        self
      end
    end
    context "deep tree" do
      let(:klass_graph){[
        :all,
        :error => :all,
        :info => :all,
        :hello => :info
      ]}
      it "works" do
        emitter.tap do |e|
          touched = 0
          e.on_all { |e| touched += 1 }
          e.emit(:hello)
          touched.should eql(1)
        end
      end
    end
    context "simple circular" do
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
      it ("works a") { same(:father) }
      it ("works b") { same(:son) }
      it ("works c") { same(:ghost) }
    end
  end
end

