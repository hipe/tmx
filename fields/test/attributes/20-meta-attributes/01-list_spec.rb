require_relative '../../test-support'

module Skylab::Fields::TestSupport

  if false
  context 'and "foo" is DSL (list)' do

    with do
      param :topping, :DSL, :list
    end

    frame do

      it '"object.foo" should not be a reader because it is a writer ' <<
          '(keep it orthoganal and "simple")' do

        object = object_

        -> { object.topping }.should raise_error( ::ArgumentError,
          /\Awrong number of arguments \(0 for 1/ )
      end

      it '(access "foo" internally to see that it starts out as nil ' <<
          'and not an array)' do

        expect_unknown_ :topping, object_
      end

      it '"object.foo "x" adds "x" to the foo list and so on ' <<
          'in the "overloaded (reader)/writer" way (hence dsl)' do

        object = object_
        object.topping :sprinkles
        object.instance_variable_get('@topping').should eql([:sprinkles])
        object.topping :sparkles
        force_read_( :topping, object ).should eql [ :sprinkles, :sparkles ]
      end
    end
  end
  end
end
