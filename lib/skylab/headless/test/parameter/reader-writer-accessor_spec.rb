require_relative 'test-support'

describe "[hl] parameter reader-writer-accesor (with param 'foo'..)" do

  extend ::Skylab::Headless::TestSupport::Parameter

  context 'and "foo" has the property "reader: true"' do
    with do
      param :foo_readonly, reader: true
    end
    frame do
      it '"object.foo" is a reader, but you don\'t get "object.foo = x"' do
        object.send(:known?, :foo_readonly).should eql(false)
        object.send(:[]=, :foo_readonly, :biz)
        object.send(:known?, :foo_readonly).should eql(true)
        object.foo_readonly.should eql(:biz)
        -> { object.foo = :baz }.should raise_error(::NoMethodError)
      end
    end
  end

  context 'and "foo" has the property "writer: true"' do
    with do
      param :foo_writeonly, writer: true
    end
    frame do
      it '"object.foo= x" is a writer but you don\'t get "object.foo"' do
        object.send(:known?, :foo_writeonly).should eql(false)
        object.foo_writeonly = :blue
        object.send(:known?, :foo_writeonly).should eql(true)
        object.send(:[], :foo_writeonly).should eql(:blue)
        -> { object.foo_writeonly }.should raise_error(::NoMethodError)
      end
    end
  end

  context 'and "foo" has the property "accessor: true"' do
    with do
      param :foo_accessor, accessor: true
    end
    frame do
      it '"object.foo" is a reader and "object.foo = x" is a writer' <<
          '(you get both)' do
        object.send(:known?, :foo_accessor).should eql(false)
        object.foo_accessor = :blue
        object.send(:known?, :foo_accessor).should eql(true)
        object.foo_accessor.should eql(:blue)
      end
    end
  end
end
