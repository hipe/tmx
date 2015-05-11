require_relative 'test-support'

describe '[hl] If you have an object "object" that has a ' <<
  "#{::Skylab::Headless::Parameter} \"foo\"" do

  extend ::Skylab::Headless::TestSupport::Parameter
  let(:lovely) { klass.parameters[:lovely] }
  context 'and "foo" assigns a desc using the DSL' do
    with do
      param(:lovely) do
        desc 'this is a lovely parameter'
      end
    end
    frame do
      it '"foo.desc" is an array with the description' do
        lovely.desc.should eql(['this is a lovely parameter'])
      end
    end
  end
  context 'and "foo" does not assign a desc using the DSL' do
    with do
      param :lovely
    end
    frame do
      it '"foo.desc" will be nil (not an empty array' do
        lovely.desc.should be_nil
      end
    end
  end
end
