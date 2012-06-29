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
    context "at level 0" do
      include ::Skylab::MetaHell::KlassCreator::InstanceMethods
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
            def execute fizzle, bazzle
              "yerp: #{fizzle.inspect} #{bazzle.inspect}"
            end
          end
        end
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
      _USAGE_RE =  /usage.+DORP <action> \[opts\] \[args\]/i
      _INVITE_RE =  /try DORP \[<action>\] -h for help/i
      should_usage_invite = ->(_) do
        specify { should be_event(1, :help, _USAGE_RE) }
        specify { should be_event(2, :help, _INVITE_RE) }
      end
      context "with no args" do
        before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
        let(:argv) { [] }
        specify { should be_event(0, :help, /expecting.+act1.+act2/i) }
        instance_eval(&should_usage_invite)
      end
      context "with bad args" do
        before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
        let(:argv) { ['foo', 'bar'] }
        specify { should be_event(0, :help, /invalid command.+foo.+expecting.+act1.+act2/i) }
        instance_eval(&should_usage_invite)
      end
      context "with bad opts" do
        before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
        let(:argv) { ['-x'] }
        specify { should be_event(0, :help, /invalid command "-x"/i) }
      end
      def self.should_show_index
        specify { should be_event(0, /usage.+DORP.+act1.+act2/i) }
        specify { should be_event(2, /act1/i) }
        specify { should be_event(3, /act2.+fooible/i) }
        specify { should be_event(4, /for help on a particular action/i) }
      end
      context "with help request at LVL0 (as -h)" do
        before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
        let(:argv) { ['-h'] }
        should_show_index
      end
      context "with help request at LVL0 (as help)" do
        before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
        let(:argv) { ['help'] }
        should_show_index
      end
      context "with a request for help on a valid action" do
        before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
        let(:argv) { ['-h', 'act2' ] }
        specify { should be_event(0, "usage: DORP act2 <fizzle> <bazzle>") }
        specify { should be_event(1, "description: fooibles your dooibles") }
      end
      context "with a request for help on an invalid action" do
        before(:all) { _emit_spy.no_debug! ; @subject = emit_spy.stack }
        let(:argv) { ['-h', 'whatevr' ] }
        specify { should be_event(0, /invalid command.+whatevr.+expecting.+act1.+act2/i) }
        specify { should be_event(1, nil) }
      end
    end
  end
end
