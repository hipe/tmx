require_relative 'test-support.rb'

describe 'If you have an object "object" that has a ' <<
  "#{::Skylab::Headless::Parameter} \"foo\"" do

  extend ::Skylab::Headless::Parameter::TestSupport
  context 'and "foo" has the property "reader: true"' do
    defn do
      param :foo_readonly, reader: true
    end
    frame do
      it '"object.foo" is a reader, but you don\'t get "object.foo = x"' do
        object.foo_readonly.should be_nil
        object.send(:[]=, :foo_readonly, :biz)
        object.foo_readonly.should eql(:biz)
        -> { object.foo = :baz }.should raise_error(::NoMethodError)
      end
    end
  end
  context 'and "foo" has the property "writer: true"' do
    defn do
      param :foo_writeonly, writer: true
    end
    frame do
      it '"object.foo= x" is a writer but you don\'t get "object.foo"' do
        object.send(:[], :foo_writeonly).should be_nil
        object.foo_writeonly = :blue
        object.send(:[], :foo_writeonly).should eql(:blue)
        -> { object.foo_writeonly }.should raise_error(::NoMethodError)
      end
    end
  end
  context 'and "foo" has the property "accessor: true"' do
    defn do
      param :foo_accessor, accessor: true
    end
    frame do
      it '"object.foo" is a reader and "object.foo = x" is a writer' <<
        '(you get both)' do
        object.foo_accessor.should be_nil
        object.foo_accessor = :blue
        object.foo_accessor.should eql(:blue)
      end
    end
  end
end
