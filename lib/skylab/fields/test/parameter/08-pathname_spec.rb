require_relative '../test-support'

describe '[fi] P - given object "object" with parameter "foo"' do

  extend Skylab::Fields::TestSupport
  use :parameter

  context 'and "foo" has the property "pathname: true"' do

    context '"pathname: true" alone, (i.e. you don\'t specify a writer)' do

      it 'you get bucked - i.e. no passthru filters without writers' do

        e = nil

        cls = ::Class.new
        sub = subject_module_

        cls.class_exec do
          sub::Definer[ self ]
          begin
            param :foo, pathname: true
          rescue ::RuntimeError => e
          end
        end

        e.message.should match %r(\bcan't use 'pathname' without a writer\b)i
      end
    end

    context 'but if you do specify a writer (note order must not matter)' do

      context '"pathname: true, writer: true" (e.g. writer at tail of props)' do

        with do
          param :foo, pathname: true, writer: true
        end

        frame do

          it "you get no reader" do
            _you_get_no_reader
          end

          it "converts to pathname at calltime" do
            _converts_to_pathname_at_calltime
          end

          it "setting to falseish works" do
            _setting_to_falseish_works
          end
        end
      end

      context '"writer: true, pathname: true" (i.e. writer at head of props)' do

        with do
          param :foo, writer: true, pathname: true
        end

        frame do

          it "you get no reader" do
            _you_get_no_reader
          end

          it "converts to pathname at calltime" do
            _converts_to_pathname_at_calltime
          end

          it "setting to falseish works" do
            _setting_to_falseish_works
          end
        end
      end

      def _you_get_no_reader

        object.respond_to?( :foo ).should eql false
      end

      def _converts_to_pathname_at_calltime

        o = object
        o.foo = 'x'
        o.send( :[], :foo ).should be_kind_of ::Pathname
      end

      def _setting_to_falseish_works

        o = object
        o.foo = false
        o.send( :[], :foo ).should eql false
      end
    end
  end
end
