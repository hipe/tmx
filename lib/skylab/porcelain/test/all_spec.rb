require 'stringio'
require File.expand_path('../../all', __FILE__)


module Skylab::Porcelain::Test
  Porcelain = ::Skylab::Porcelain
  class StringIo < ::StringIO
    def to_s
      rewind
      read
    end
    def match x
      to_s.match x
    end
  end
  describe Porcelain do
    describe "extended by a class allows that" do
      let(:klass) do
        Class.new.class_eval do
          extend Porcelain
          def foo ; end
          def bar ; end
        private
          def baz ; end
          self
        end
      end
      let(:child_class) do
        Class.new(klass).class_eval do
          def she_bang ; end
          self
        end
      end
      it "the class's public instance methods will make up its public interface / api (actions)" do
        klass.actions.map(&:name).should eql([:help, :foo, :bar])
      end
      it "the class can access the action property by name (which is a dashed version of the method name)" do
        child_class.actions[:'she-bang'].name.should eql(:'she-bang')
      end
      it "although it is an enumerator, the actions knob returns a consistent object per action" do
        oid = child_class.actions[:'she-bang'].object_id
        child_class.actions[:'she-bang'].object_id.should eql(oid)
        child_class.actions.detect{ |a| a.name == :'she-bang' }.object_id.should eql(oid)
      end
      it "any child class of the class will also have this property and inherit the list of actions from its parent" do
        child_class.actions.map(&:name).should eql([:help, :foo, :bar, :'she-bang'])
      end
    end
    describe "A DSL" do
      let(:klass) do
        Class.new.class_eval do
          extend Porcelain
          option_syntax { }
          argument_syntax '<foo>'
          def bar foo ; end
          self
        end
      end
      it "is used for defining option and argument syntax" do
        klass.actions[:bar].argument_syntax.to_s.should eql('<foo>')
      end
      describe "Argument Syntax" do
        it "lets you inspect the number of parameters" do
          klass.actions[:bar].argument_syntax.count.should eql(1)
        end
        def _ str
          __(str).first
        end
        def __ str
           Porcelain::ArgumentSyntax.parse(str)
        end
        describe "required parameter (a [1..1] ranged parameter)" do
          let(:parameter) {  _ '<foo>' }
          it("knows it is required") { parameter.required?.should eql(true) }
          it("unparses correctly") { parameter.to_s.should eql('<foo>') }
        end
        describe "optional parameter (a [0..1] ranged parameter)" do
          let(:parameter) { _ '[<foo>]' }
          it("knows it is not required") { parameter.required?.should eql(false) }
          it("unparses like so") { parameter.to_s.should eql('[<foo>]') }
        end
        describe "a [1..] ranged parameter" do
          let(:parameter) { _ '<foo>[<foo>[...]]' }
          it("knows it is required") { parameter.required?.should eql(true) }
          it("unparses like so") { parameter.to_s.should eql('<foo> [<foo>[...]]') }
          context do
            let(:parameter) { _ '<foo> [..]' }
            it("can also be notated this way") { parameter.required?.should eql(true) }
            it("but unparses the same as above") { parameter.to_s.should eql('<foo> [<foo>[...]]') }
          end
        end
        describe "a [0..] ranged parameter" do
          let(:parameter) { _ '[<foo> [<foo> [...]]]' }
          it("knows it is not required") { parameter.required?.should eql(false) }
          it("unparses like so") { parameter.to_s.should eql('[<foo> [<foo>[...]]]') }
          context do
            let(:parameter) { _ '[<foo> [..]]' }
            it("can also be notated in this way") { parameter.required?.should eql(false) }
            it("but unparses the same as above") { parameter.to_s.should eql('[<foo> [<foo>[...]]]') }
          end
        end
        describe "glob" do
          it "can be one optional parameter at the end" do
            __('<a> [<b> [<b> [..]]]').count.should eql(2)
          end
          it "can be one required parameter at the end" do
            __('<a> <b> [<b> [..]]').count.should eql(2)
          end
          it "can be the only parameter, and required" do
            __('<a> [<a> [..]]').count.should eql(1)
          end
          it "can be the only parameter, and optional" do
            __('[<a> [<a> [..]]]').count.should eql(1)
          end
          it "cannot occur more than once" do
            lambda{ __('<a> [<b> [..]] [<c> [..]]') }.should raise_exception(/cannot .+ more than once/i)
            lambda{ __('[<b> [..]] [<c> [..]] <a>') }.should raise_exception(/cannot .+ more than once/i)
            lambda{ __('<a> [<b> [..]] [<c> [..]] <d>') }.should raise_exception(/cannot .+ more than once/i)
          end
          it "cannot occur at the beginning (for now)" do
            lambda{ __('<a> [<a> [..]] <b>') }.should raise_exception(/cannot .+ at the beginning/i)
          end
          it "cannot occur in the middle" do
            lambda{ __('<a> [<b> [..]] <c>') }.should raise_exception(/cannot .+ in the middle/i)
          end
        end
        describe "optional" do
          it "can occur more than once at the end" do
            __('<a> [<b>] [<c>]').count.should eql(3)
          end
          it "cannot occur at the beginning" do
            lambda{ __('[<a>] <b>') }.should raise_exception(/optionals cannot occur at the beginning/i)
          end
          it "cannot occur in the middle" do
            lambda{ __('<a> [<b>] <c>') }.should raise_exception(/optionals cannot occur in the middle/i)
          end
          describe "can occur in conjunction with globs, provided the above rules are followed" do
            it "with a trailing optional glob" do
              __('<a> [<b>] [<c>] [<d> [<d> [..]]]').count.should eql(4)
            end
            it "but not with a trailing required glob, e.g." do
              lambda{ __('<a> [<b>] [<c>] <d> [<d> [..]]') }.should raise_exception(/optionals cannot occur in the middle/i)
            end
          end
        end
      end
    end
    describe "invocation happens with a call to invoke() (pass it ARGV) that" do
      include Porcelain::Styles # unstylize
      Porcelain::Runtime.send(:define_method, :invocation_name) { 'yourapp' }
      let(:expecting_foo_bar) { /expecting \{help\|foo\|bar\}/i }
      let(:instance) do
        klass.new do |app|
          app.on_all { |e| stderr.puts unstylize(e) ; false and $stderr.puts(e) }
        end
      end
      let(:klass) do
        Class.new.class_eval do
          extend Porcelain
          def foo ; end
          def bar ; end
        private
          def baz ; end
          self
        end
      end
      let(:stderr) { StringIo.new }
      it "with empty argv it complains, lists available actions and invites to more help" do
        instance.invoke []
        stderr.should match(expecting_foo_bar)
        stderr.should match(/try yourapp -h for help/i)
      end
      it "with a bad action name it complains, lists available actions and invites to more help" do
        instance.invoke ['derpis']
        stderr.should match(/invalid action: derpis/i)
        stderr.should match(expecting_foo_bar)
      end
      it "with -h or --help as the first argument, you get help (listing of avaiable commands)" do
        instance.invoke ['-h']
        stderr.should match(/usage: yourapp \{help\|foo\|bar\}/i)
        stderr.should match(/for help on a particular subcommand/i)
      end
      it "with -h (or help) followed by an action name, you get action-specific help" do
        instance.invoke ['-h', 'foo']
        stderr.should match(/syntax: yourapp foo/)
      end
    end
  end
end

