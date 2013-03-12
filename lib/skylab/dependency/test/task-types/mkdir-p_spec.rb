require_relative 'test-support'

module Skylab::Dependency::TestSupport::Tasks

  # (not Q-uickie - `before` used below)

  describe TaskTypes::MkdirP do

    extend Tasks_TestSupport

    subject { TaskTypes::MkdirP }
    let(:all) do
      lambda do |t|
        t.on_all do |e|
          debug_event e if do_debug
          stderr << e.text
        end
      end
    end
    it "won't build an empty object" do
      -> do
        subject.new
      end.should raise_error( ::RuntimeError,
        /unhandled stream\(s\): .*all.+info/i )
    end
    context "as empty" do
      subject do
        TaskTypes::MkdirP.new(&all)
      end
      it "whines about required arg missing if you try to run it" do
        lambda { subject.invoke }.should(
          raise_exception(RuntimeError, /missing required attributes?: .*mkdir_p/)
        )
      end
    end
    context "when the required parameters are present" do
      let(:dir_arg) { "#{BUILD_DIR}/foo/bar" }
      subject do
        TaskTypes::MkdirP.new( :mkdir_p => dir_arg, &all)
      end
      context "with regards to dry_run" do
        before { subject.context = context }
        context "by default" do
          let( :context ) { { } }
          it { should_not be_dry_run }
        end
        context "with dry run in context" do
          let( :context ) { { :dry_run => true } }
          it { should be_dry_run }
          context "when invoked" do
            let( :stderr ) { "" }
            before do
              BUILD_DIR.prepare
            end
            context "a two-element do-hah" do
              context "with default max_depth" do
                it "will not go because it is past max depth" do
                  subject.invoke
                  stderr.should match(/more than 1 levels? deep/)
                end
              end
              context "with max_depth increased to two" do
                subject do
                  TaskTypes::MkdirP.new(:mkdir_p => dir_arg, :max_depth => 2, &all)
                end
                it "will go becuase it is equal to max depth" do
                  subject.invoke
                  stderr.should match(%r{mkdir -p .*foo/bar})
                end
              end
            end
          end
        end
      end
    end
  end
end

