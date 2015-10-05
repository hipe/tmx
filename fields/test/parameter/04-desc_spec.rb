require_relative '../test-support'

describe '[fi] P - desc: given "object" with parameter "foo"' do

  extend Skylab::Fields::TestSupport
  use :parameter

  let :lovely do
    the_class_.parameters.fetch :lovely
  end

  context 'and "foo" assigns a desc using the DSL' do

    with do

      param(:lovely) do

        desc 'this is a lovely parameter'
      end
    end

    frame do

      it '"foo.desc" is an array with the description' do

        lovely.desc_array.should eql [ 'this is a lovely parameter' ]
      end
    end
  end

  context 'and "foo" does not assign a desc using the DSL' do

    with do
      param :lovely
    end

    frame do

      it '"foo.desc" will be nil (not an empty array' do

        lovely.desc_array.should be_nil
      end
    end
  end
end
