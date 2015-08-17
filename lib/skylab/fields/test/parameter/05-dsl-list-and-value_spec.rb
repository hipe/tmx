require_relative '../test-support'

describe '[fi] P - DSL lis[..]: given "object" with parameter "foo"' do

  extend Skylab::Fields::TestSupport
  use :parameter

  context 'and "foo" has the meta property of DSL (atom)' do

    with do
      param :comment, :DSL, :atom
    end

    frame do

      it '"object.foo" raises error (only a writer not a reader)' do

        object = object_
        ->{ object.comment }.should raise_error(::ArgumentError, /0 for 1/)
      end

      it '"object.foo \'x\'" is a writer that sets the internal value' do

        object = object_

        expect_unknown_ :comment, object

        object.comment 'x'
        force_read_( :comment, object ).should eql 'x'
      end
    end
  end

  context 'and "foo" is DSL (atom), `perthnerm`' do

    with do
      const_set :Parameter, Skylab::Fields::TestSupport::Parameter.Frookie
      param :comment, :DSL, :atom, :perthnerm
    end

    frame do
      it '"object.foo \'x\'" will create a pathname as if a normal writer' do

        object = object_
        object.comment 'x'
        force_read_( :comment, object ).class.should eql ::Pathname
      end
    end
  end

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

  context 'and "foo" is DSL (list), `enum` ( `up`, `down`, `over` )' do

    with do
      param :move, :DSL, :list, :enum, [ :up, :down, :over ]
    end

    spy_on_events_

    frame do

      it '"object.foo :left" is invalid, (still) invokes client ui mechanics' do

        object_.move :left
        _expect_this_was_not_ok :left
      end

      it '"object.foo <valid> ; object.foo <invalid>" now works as ' <<
          'expected, as a map-reduce' do

        object = object_

        expect_unknown_ :move, object

        object.move :up
        object.move :over
        object.move :sideways
        object.move :down
        force_read_( :move, object ).should eql [ :up, :over, :down ]
      end

      def _expect_this_was_not_ok sym

        expect_not_OK_event :invalid_property_value,
          "invalid move (ick :#{ sym.id2name }), expecting { up | down | over }"
      end
    end
  end
end
