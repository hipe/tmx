require_relative 'test-support'

describe 'If you have an object "object" that has a ' <<
  "#{::Skylab::Headless::Parameter} \"foo\"" do

  extend ::Skylab::Headless::Parameter::TestSupport
  context 'and "foo" has the property of e.g. "builder: :foo_f"' do
    defn do
      param :roland_808, builder: :roland_808_f
      attr_accessor :roland_808_f
    end
    frame do
      before do
        @num_times = 0
        object.roland_808_f = -> { "lawrence fishburne #{@num_times += 1}" }
      end
      context 'when the parameter value is falseish' do
        it '"object.foo" will call the builder proc (lazily) (once) ' <<
          'to initiate it' do
          @num_times.should eql(0)
          object.send(:[], :roland_808).should be_nil
          oid = object.roland_808.object_id
          object.roland_808.should eql('lawrence fishburne 1')
          object.roland_808.should eql('lawrence fishburne 1')
          object.roland_808.object_id.should eql(oid)
          @num_times.should eql(1)
        end
      end
      context 'but when the parameter value is trueish' do
        before do
          object.send(:[]=, :roland_808, :tha_synth)
        end
        it '"object.foo" will not call the builder proc ' do
          @num_times.should eql(0)
          object.roland_808.should eql(:tha_synth)
          @num_times.should eql(0)
        end
      end
    end
  end
end
