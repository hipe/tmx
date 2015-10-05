require_relative '../test-support'

describe '[fi] P - builder - given "object" with parameter "foo"' do

  extend Skylab::Fields::TestSupport
  use :parameter

  context 'and "foo" has the property of e.g. "builder: :foo_p"' do

    with do
      param :roland_808, :builder, :roland_808_p
      attr_accessor :roland_808_p
    end

    frame do

      before :each do
        @num_times = 0
        object_.roland_808_p = -> do
          "lawrence fishburne #{ @num_times += 1 }"
        end
      end

      context 'when the parameter value is falseish' do

        it '"object.foo" will call the builder proc (lazily) (once) ' <<
          'to initiate it' do

          @num_times.should eql(0)
          object = object_

          expect_unknown_ :roland_808, object

          oid = object.roland_808.object_id
          object.roland_808.should eql('lawrence fishburne 1')
          object.roland_808.should eql('lawrence fishburne 1')
          object.roland_808.object_id.should eql(oid)
          @num_times.should eql(1)
        end
      end

      context 'but when the parameter value is trueish' do

        it '"object.foo" will not call the builder proc ' do

          object = object_
          force_write_ :tha_synth, :roland_808, object
          @num_times.should eql(0)
          object.roland_808.should eql(:tha_synth)
          @num_times.should eql(0)
        end
      end
    end
  end
end
