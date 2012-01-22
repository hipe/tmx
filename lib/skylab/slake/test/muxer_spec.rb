require File.expand_path('../../muxer', __FILE__)
require File.expand_path('../support', __FILE__)

describe Skylab::Slake::Muxer do
  let(:klass) do
    Class.new.class_eval do
      extend Skylab::Slake::Muxer
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
  it "but the listener can check the event-id of the event if it wants to, it will be the same event" do
    id_one = id_two = nil
    emitter.on_informational { |e| id_one = e.event_id }
    emitter.on_info          { |e| id_two = e.event_id }
    emitter.emit(:info)
    id_one.should_not eql(nil)
    id_one.should eql(id_two)
    id_two.should be_kind_of(Fixnum)
  end
end

