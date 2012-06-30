require_relative 'test-support'

module ::Skylab::Porcelain::Bleeding::TestSupport
  module RuntimeInstanceMethods
    def emit k, v
      @runtime.emit SimplifiedEvent.new(k, unstylize(v))
    end
    def initialize rt
      @program_name = 'DORP'
      @runtime = rt
    end
  end
  describe "#{Bleeding::Runtime}" do
    include ::Skylab::MetaHell::KlassCreator::InstanceMethods
    def self.argv *argv
      let(:argv) { argv }
    end
    attr_reader :cli_runtime
    let(:_emit_spy) { ::Skylab::TestSupport::EmitSpy.new }
    let(:emit_spy) do
      @cli_runtime = my_klass.new(es = _emit_spy)
      es.formatter = ->(e) { "#{e.type.inspect}<-->#{e.message.inspect}" }
      @invoke_result = @cli_runtime.invoke(argv)
      es
    end
    attr_reader :invoke_result, :my_klass, :subject
    context "at level 0" do
      before(:all) do
        @my_klass = self.klass(:MyKloss, extends: Bleeding::Runtime) do # @todo try deeper names
          o = self
          include RuntimeInstanceMethods
          class o::MyAction
            extend Bleeding::Action
          end
          module o::Actions
          end
          class o::Actions::Act1 < o::MyAction
          end
          class o::Actions::Act2 < o::MyAction
            desc 'fooibles your dooibles'
            def invoke fizzle, bazzle
              "yerp: #{fizzle.inspect} #{bazzle.inspect}"
            end
          end
        end
      end
      _USAGE_RE =  /usage.+DORP <action> \[opts\] \[args\]/i
      _INVITE_RE =  /try DORP \[<action>\] -h for help/i
      should_usage_invite = ->(_) do
        specify { should be_event(1, :help, _USAGE_RE) }
        specify { should be_event(2, :help, _INVITE_RE) }
      end
      context "with no args" do
        before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
        argv
        specify { should be_event(0, :help, /expecting.+act1.+act2/i) }
        instance_eval(&should_usage_invite)
      end
      context "with bad args" do
        before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
        argv 'foo', 'bar'
        specify { should be_event(0, :help, /invalid command.+foo.+expecting.+act1.+act2/i) }
        instance_eval(&should_usage_invite)
      end
      context "with bad opts" do
        before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
        argv '-x'
        specify { should be_event(0, :help, /invalid command "-x"/i) }
      end
      def self.should_show_index
        specify { should be_event(0, /usage.+DORP.+act1.+act2/i) }
        specify { should be_event(2, /act1/i) }
        specify { should be_event(3, /act2.+fooible/i) }
        specify { should be_event(4, /for help on a particular action/i) }
      end
      context "-h" do
        before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
        argv '-h'
        should_show_index
      end
      context "help" do
        before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
        argv 'help'
        should_show_index
      end
      context "-h <valid action>" do
        before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
        argv '-h', 'act2'
        specify { should be_event(0, "usage: DORP act2 <fizzle> <bazzle>") }
        specify { should be_event(1, "description: fooibles your dooibles") }
      end
      context "-h <invalid action>" do
        before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
        argv '-h', 'whatevr'
        specify { should be_event(0, /invalid command.+whatevr.+expecting.+act1.+act2/i) }
        specify { should be_event(1, nil) }
      end
    end
    context "at level 1 (the command 'pony')" do
      before(:all) do
        @my_klass = self.klass(:MyKliss, extends: Bleeding::Runtime) do
          o = self
          include RuntimeInstanceMethods
          class o::MyAction
            extend Bleeding::Action
          end
          module o::Actions
          end
          module o::Actions::Pony
            extend Bleeding::Namespace
          end
          class o::Actions::Pony::Create < o::MyAction
          end
          class o::Actions::Pony::PutDown < o::MyAction
            def invoke oingo=nil, boingo
              emit(:ze_payload, "yerp-->#{oingo.inspect}<-->#{boingo.inspect}<--")
              :you_put_down_the_pony
            end
          end
          class o::Actions::Pony::PutUp < o::MyAction
            option_syntax.help_enabled = true
            def invoke
              emit(:mein_payload, "yoip")
            end
          end
        end
      end
      context "just it" do
        before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
        argv  'pony'
        it "shouldn't actually require an extended module as a namespace, just a plain module @todo"
         specify { should be_event(0, /expecting.+create.+put-down/i) }
      end
      context "-h it" do
        it "is a bug @todo"
      end
      context "it -h" do
        it "is a bug @todo"
      end
      context "at level 2" do
        _INVALID_EXPECTING = /invalid command.+nerk.+expecting.+create.+put-down/i
        context "with a bad name" do
          context "just it" do
            before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
            argv  'pony', 'nerk'
            specify { should be_event(0, _INVALID_EXPECTING) }
            it "should be consistent in its use of the term {action|command} @todo"
          end
          context "-h it" do
            before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
            argv 'pony', '-h', 'nerk'
            specify { should be_event(0, :error, _INVALID_EXPECTING) }
          end
          context "it -h" do
            before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
            argv 'pony', 'nerk', '-h'
            specify { should be_event(0, :help, _INVALID_EXPECTING) }
          end
        end
        context "with an amibiguous name" do
          before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
          argv 'pony', 'put'
          specify { should be_event(0, :help, /ambiguous comand .+put.+did you mean put-down or put-up\?/i) }
        end
        context "with a good name" do
          context "unambiguous fuzzy" do
            _USAGE = /usage.+DORP pony put-down \[<oingo>\] <boingo>/i
            context "just it does cute sytax thing" do
              before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
              argv  'pony', 'put-d'
              specify { should be_event(0, :syntax_error, /missing.+argument.+boingo/i) }
              specify { should be_event(1, _USAGE) }
              specify { should be_event(2, /try DORP pony put-down -h for help/i) }
            end
            context "-h it" do
              before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
              argv 'pony', '-h', 'put-d'
              specify { should be_event(0, :help, _USAGE) }
              specify { should be_event(1, nil) }
            end
            context "it -h out of the box will process it as an arg" do
              before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
              argv 'pony', 'put-d', '-h'
              specify { should be_event(0, :ze_payload, 'yerp-->nil<-->"-h"<--') }
              specify { should be_event(1, nil) }
            end
          end
          context "exact match, with a thing with no option syntax but help enabled" do
            _TRAILING_SPACE = "usage: DORP pony put-up "
            context "it -h" do
              before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
              argv 'pony', 'put-up', '-h'
              it "fix trailing space @todo"
              specify { should be_event(:help, _TRAILING_SPACE) }
            end
            context "-h it" do
              before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
              argv 'pony', '-h', 'put-up'
              specify { should be_event(:help, _TRAILING_SPACE) }
            end
          end
        end
      end
    end
  end
end
