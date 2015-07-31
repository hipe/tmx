require_relative 'test-support'
require 'pathname' # already required by whoever but whatever

describe '[hl] If you have an object "object" that has a ' <<
  "#{::Skylab::Headless::Parameter} \"foo\" " do

  extend ::Skylab::Headless::TestSupport::Parameter
  context 'and "foo" has the property "pathname: true"' do
    context '"pathname: true" alone, (i.e. you don\'t specify a writer)' do
      it 'you get bucked - i.e. no passthru filters without writers' do
        -> do
          self.class.with do
            param :foo, pathname: true
          end
        end.should raise_error(
          ::RuntimeError, /can't use 'pathname' without a writer/i)
      end
    end
    def self.you_get_no_reader
      it '"object.foo" is not defined for you (no reader)' do
        -> { object.foo }.should raise_error(::NoMethodError)
      end
    end
    def self.you_get_a_writer
      it '"object.foo =\'x\'" turns \'x\' into a Pathname at calltime' do
        object.foo = 'x'
        object.send(:[], :foo).should be_kind_of(::Pathname)
      end
      it '"object.foo = <a falseish>" will set the param to that value' do
        object.foo = 'x'
        object.send(:[], :foo).should be_kind_of(::Pathname)
        object.foo = false
        object.send(:[], :foo).should eql(false)
      end
    end
    context 'but if you do specify a writer (note order must not matter)' do
      context '"pathname: true, writer: true" (e.g. writer at tail of props)' do
        with do
          param :foo, pathname: true, writer: true
        end
        frame do
          you_get_no_reader
          you_get_a_writer
        end
      end
      context '"writer: true, pathname: true" (i.e. writer at head of props)' do
        with do
          param :foo, writer: true, pathname: true
        end
        frame do
          you_get_no_reader
          you_get_a_writer
        end
      end
    end
  end
end
