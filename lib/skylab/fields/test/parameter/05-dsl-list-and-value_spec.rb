require_relative '../test-support'

describe '[fi] P - DSL lis[..]: given "object" with parameter "foo"' do

  extend Skylab::Fields::TestSupport
  use :parameter

  context 'and "foo" has the property of "dsl: :value"' do

    with do
      param :comment, dsl: :value
    end

    frame do

      it '"object.foo" raises error (only a writer not a reader)' do

        ->{ object.comment }.should raise_error(::ArgumentError, /0 for 1/)
      end

      it '"object.foo \'x\'" is a writer that sets the internal value' do

        object = send :object
        object.send(:known?, :comment).should eql(false)
        object.comment 'x'
        object.send(:[], :comment).should eql('x')
      end
    end
  end

  context 'and "foo" has the property of ' <<
     '"dsl: :value, pathname: true"' do

    with do
      param :comment, dsl: :value, pathname: true
    end

    frame do
      it '"object.foo \'x\'" will create a pathname as if a normal writer' do

        object = send :object
        object.comment 'x'
        object.send(:[], :comment).should be_kind_of(::Pathname)
      end
    end
  end

  context 'and "foo" has the property of "dsl: :list"' do

    with do
      param :topping, dsl: :list
    end

    frame do

      it '"object.foo" should not be a reader because it is a writer ' <<
          '(keep it orthoganal and "simple")' do
        -> { object.topping }.should raise_error( ::ArgumentError,
          /wrong number of arguments \(0 for 1\+\)/ )
      end

      it '(access "foo" internally to see that it starts out as nil ' <<
          'and not an array)' do
        object.send(:known?, :topping).should eql(false)
      end

      it '"object.foo "x" adds "x" to the foo list and so on ' <<
          'in the "overloaded (reader)/writer" way (hence dsl)' do

        object = send :object
        object.topping :sprinkles
        object.instance_variable_get('@topping').should eql([:sprinkles])
        object.topping :sparkles
        object.send(:[], :topping).should eql([:sprinkles, :sparkles])
      end
    end
  end

  context 'and "foo" has the properties ' <<
    '"dsl: :list, enum: [:up, :down, :over]" (CHECK THIS OUT ^_^:)' do

    capture_emit_lines_

    with do
      param :move, dsl: :list, enum: [:up, :down, :over]
    end

    frame do

      it '"object.foo :left" is invalid, (still) invokes client ui mechanics' do

        object.move :left
        @emit_lines_.first.should match(/left.+invalid.+move/)
      end

      it '"object.foo <valid> ; object.foo <invalid>" now works as ' <<
          'expected, as a map-reduce' do

        object = send :object
        object.send(:known?, :move).should eql(false)
        object.move :up
        object.move :over
        object.move :sideways
        object.move :down
        @emit_lines_.length.should eql(1)
        object.send(:[], :move).should eql([:up, :over, :down])
      end
    end
  end
end
