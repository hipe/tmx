require_relative 'test-support'

describe "[hl] parameter builder - with an object w/ param 'foo'" do

  # (no quickie because nested `before`)

  extend ::Skylab::Headless::TestSupport::Parameter

  context 'and "foo" has the property of e.g. "builder: :foo_p"' do
    with do
      param :roland_808, builder: :roland_808_p
      attr_accessor :roland_808_p
    end
    frame do
      before :each do
        @num_times = 0
        object.roland_808_p = -> { "lawrence fishburne #{@num_times += 1}" }
      end
      context 'when the parameter value is falseish' do
        it '"object.foo" will call the builder proc (lazily) (once) ' <<
          'to initiate it' do
          @num_times.should eql(0)
          object.send(:known?, :roland_808).should be false
          # object.send(:[], :roland_808).should be_nil
          oid = object.roland_808.object_id
          object.roland_808.should eql('lawrence fishburne 1')
          object.roland_808.should eql('lawrence fishburne 1')
          object.roland_808.object_id.should eql(oid)
          @num_times.should eql(1)
        end
      end
      context 'but when the parameter value is trueish' do
        before :each do
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
