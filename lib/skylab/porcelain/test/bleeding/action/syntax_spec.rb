require_relative '../test-support'

module Skylab::Porcelain::Bleeding::TestSupport
  describe "You can reflect on the action's syntax" do
    extend ModuleMethods ; include InstanceMethods
    base_module!
    let(:klass) { self.send(:Akton) }
    let(:runtime) { build_action_runtime 'akton' }
    context "with regards to inferred syntaxes" do
      klass(:Akton) do
        extend Bleeding::ActionModuleMethods
        def invoke niggle=nil, naggle
        end
      end
      context "of arguments" do
        it "via the class"
        context "via the runtime" do
          let(:subject) { runtime.argument_syntax.string }
          specify { should eql('[<niggle>] <naggle>') }
        end
      end
      context "of options" do
        it "via the class"
        context "via the runtime (option_syntax is nil b/c that cannot be inferred)" do
          let(:subject) { runtime.option_syntax.string }
          specify { should be_nil }
        end
      end
      context "as a whole" do
        it "via the class"
        context "via the runtime" do
          let(:subject) { runtime.syntax }
          specify { should eql('[<niggle>] <naggle>') }
        end
      end
    end
    context "with a stated syntax (of options)" do
      klass(:Akton) do
        extend Bleeding::ActionModuleMethods
        option_syntax do |_|
          on('-x', 'wing fighter')
          on('-p<queue>', '--pee <queue>', "pee queue")
        end
        def invoke zoip=nil, voip, opts
        end
      end
      context "the syntax of options" do
        it "via the class"
        context "via the runtime" do
          let(:subject) { runtime.option_syntax.string }
          specify { should eql("[-x] [-p <queue>]") }
        end
      end
      context "the syntax feels good on the whole" do
        it "via the class"
        context "via the runtime", f:true do
          let(:subject) { runtime.syntax }
          specify { should eql('[-x] [-p <queue>] [<zoip>] <voip>') }
        end
      end
    end
  end
end
