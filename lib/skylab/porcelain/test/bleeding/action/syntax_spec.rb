require_relative '../test-support'

module Skylab::Porcelain::Bleeding::TestSupport
  describe "You can reflect on the action's syntax" do
    extend ModuleMethods ; include InstanceMethods
    base_module!
    let(:klass) { self.send(:Akton) }
    let(:runtime) { build_action_runtime 'akton' }
    context "with regards to inferred syntaxes" do
      klass :Akton do
        extend Bleeding::ActionModuleMethods
        def invoke wiggle=nil, waggle
        end
      end
      context "of arguments" do
        context "via the class" do
          let(:subject) { klass.argument_syntax.string }
          specify { should eql('[<wiggle>] <waggle>') }
        end
        context "via the runtime" do
          let(:subject) { runtime.argument_syntax.string }
          specify { should eql('[<wiggle>] <waggle>') }
        end
      end
      context "of options" do
        context "via the class (option syntax is nil b/c that cannot be inferred)" do
          let(:subject) { klass.option_syntax.string }
          specify { should be_nil }
        end
        context "via the runtime (option_syntax is nil b/c that cannot be inferred)" do
          let(:subject) { runtime.option_syntax.string }
          specify { should be_nil }
        end
      end
      context "as a whole" do
        context "via the class" do
          let(:subject) { klass.syntax }
          specify { should eql('[<wiggle>] <waggle>') }
        end
        context "via the runtime" do
          let(:subject) { runtime.syntax }
          specify { should eql('[<wiggle>] <waggle>') }
        end
      end
    end
    context "with a stated syntax (of options)" do
      klass :Akton do
        extend Bleeding::ActionModuleMethods
        option_syntax do |_|
          on('-x', 'wing fighter')
          on('-p<queue>', '--pee <queue>', "pee queue")
        end
        def invoke zoip=nil, voip, opts
        end
      end
      context "the syntax of options" do
        context "via the class" do
          let(:subject) { klass.option_syntax.string }
          specify { should eql('[-x] [-p <queue>]') }
        end
        context "via the runtime" do
          let(:subject) { runtime.option_syntax.string }
          specify { should eql("[-x] [-p <queue>]") }
        end
      end
      context "the syntax feels good on the whole" do
        context "via the class" do
          let(:subject) { klass.syntax }
          specify { should eql('[-x] [-p <queue>] [<zoip>] <voip>') }
        end
        context "via the runtime" do
          let(:subject) { runtime.syntax }
          specify { should eql('[-x] [-p <queue>] [<zoip>] <voip>') }
        end
      end
    end
  end
end
