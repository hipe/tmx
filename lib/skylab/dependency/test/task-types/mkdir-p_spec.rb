require_relative 'test-support'

module Skylab::Dependency::TestSupport::Tasks

  describe "[de] task-types - mkdir p" do  # :+#no-quickie because: nested `before`

    extend TS_

    let :subject do
      TaskTypes::MkdirP
    end

    let :all do
      lambda do |t|
        t.on_all do |e|
          debug_event e if do_debug
          stderr << e.text
        end
      end
    end

    it "won't build an empty object" do
      _rx = /unhandled event streams?.+all.+info/
      -> do
        subject.new
      end.should raise_error ::RuntimeError, _rx
    end

    context "as empty" do

      let :subject do
        TaskTypes::MkdirP.new(&all)
      end

      it "whines about required arg missing if you try to run it" do
        _rx = /missing required attributes?: .*mkdir_p/
        -> do
          subject.invoke
        end.should raise_exception ::RuntimeError, _rx
      end
    end

    context "when the required parameters are present" do

      let :dir_arg do
        "#{ BUILD_DIR }/foo/bar"
      end

      let :subject do
        TaskTypes::MkdirP.new( :mkdir_p => dir_arg, &all )
      end

      context "with regards to dry_run" do

        before :each do
          subject.context = context
        end

        context "by default" do

          let( :context ) { { } }

          it "o" do
            should_not be_dry_run
          end
        end

        context "with dry run in context" do

          let( :context ) { { :dry_run => true } }

          it "o" do
            should be_dry_run
          end

          context "when invoked" do

            let( :stderr ) { "" }

            before :each do
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

                let :subject do
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
