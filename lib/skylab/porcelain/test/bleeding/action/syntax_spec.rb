require_relative 'test-support'

module Skylab::Porcelain::TestSupport::Bleeding::Action # #po-008
  describe "You can reflect on the action's syntax" do
    extend Action_TestSupport

    incrementing_anchor_module!


    let(:klass) { self.send(:Akton) } # #refactor

    let(:runtime) { build_action_runtime 'akton' }
    context "with regards to inferred syntaxes" do
      klass :Akton do
        extend Bleeding::Action
        def invoke wiggle=nil, waggle
        end
      end
      context "of arguments" do
        it "via the class - works" do
          str = klass.argument_syntax.string
          str.should eql( '[<wiggle>] <waggle>' )
        end
        it "via the runtime - works" do
          str = runtime.argument_syntax.string
          str.should eql( '[<wiggle>] <waggle>' )
        end
      end
      context "of options" do
        it "via the class (option syntax is nil b/c that cannot be inferred)" do
          str =  klass.option_syntax.string
          str.should be_nil
        end
        it "via the runtime (option_syntax is nil b/c that cannot be inferred)" do
          str = runtime.option_syntax.string
          str.should be_nil
        end
      end
      context "as a whole" do
        it "via the class" do
          str = klass.syntax
          str.should eql('[<wiggle>] <waggle>')
        end
        it "via the runtime" do
          str = runtime.syntax
          str.should eql('[<wiggle>] <waggle>')
        end
      end
    end
    context "with a stated syntax (of options)" do
      klass :Akton do
        extend Bleeding::Action
        option_syntax do |_|
          on('-x', 'wing fighter')
          on('-p<queue>', '--pee <queue>', "pee queue")
        end
        def invoke zoip=nil, voip, opts
        end
      end
      context "the syntax of options" do
        it "via the class" do
          str = klass.option_syntax.string
          str.should eql('[-x] [-p <queue>]')
        end
        it "via the runtime" do
          rt = runtime
          str = rt.option_syntax.string
          str.should eql("[-x] [-p <queue>]")
        end
      end
      context "the syntax feels good on the whole" do
        it "via the class" do
          str = klass.syntax
          str.should eql('[-x] [-p <queue>] [<zoip>] <voip>')
        end
        it "via the runtime" do
          str = runtime.syntax
          str.should eql('[-x] [-p <queue>] [<zoip>] <voip>')
        end
      end
    end
  end
end
