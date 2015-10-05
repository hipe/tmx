require_relative '../test-support'

describe "[fi] P - reader-writer-accessor (with param 'foo'..)" do

  extend Skylab::Fields::TestSupport
  use :parameter

  context '`reader`' do

    with do
      param :foo_readonly, :reader
    end

    frame do

      it '"object.foo" is a reader, but you don\'t get "object.foo = x"' do

        object = object_

        expect_unknown_ :foo_readonly, object

        force_write_ :biz, :foo_readonly, object

        object.foo_readonly.should eql(:biz)

        object.respond_to?( :foo_readonly= ).should eql false

      end
    end
  end

  context '`writer`' do

    with do
      param :foo_writeonly, :writer
    end

    frame do

      it '"object.foo= x" is a writer but you don\'t get "object.foo"' do

        object = object_

        expect_unknown_ :foo_writeonly, object

        object.foo_writeonly = :blue

        force_read_( :foo_writeonly, object ).should eql :blue

        object.respond_to?( :foo_writeonly ).should eql false
      end
    end
  end

  context '`accessor`' do

    with do
      param :foo_accessor, :accessor
    end

    frame do

      it '"object.foo" is a reader and "object.foo = x" is a writer' <<
          '(you get both)' do

        object = object_

        expect_unknown_ :foo_accessor, object

        object.foo_accessor = :blue

        object.foo_accessor.should eql(:blue)
      end
    end
  end
end
