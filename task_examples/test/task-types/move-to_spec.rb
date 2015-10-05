require_relative 'test-support'

module Skylab::Dependency::TestSupport::Tasks

  describe "[de] task-types - move to" do

    extend TS_

    let(:context) { { } }

    let(:build_args) { { :move_to => move_to, :from => from } }

    let :subject do
      TaskTypes::MoveTo.new( build_args ) { |t| wire! t }
    end

    context "requires move_to and from" do

      let(:build_args) {  }

      it "and fails without it" do
        _rx = /missing required attributes: move_to, from/
        task = subject
        -> do
          task.invoke
        end.should raise_error ::RuntimeError, _rx
      end
    end

    context "when moving an existing file" do

      include Home_::Library_::FileUtils

      def fu_output_message str
        dputs "FOR TESTING: #{ str }" if do_debug
        NIL_
      end

      before :each do
        BUILD_DIR.prepare
        cp( (FIXTURES_DIR.join 'some-file.txt'),
            (BUILD_DIR.join 'some-file.txt'),
            verbose: true )
      end

      let(:from){ BUILD_DIR.join('some-file.txt') }

      context "to an available location" do
        let(:move_to) { BUILD_DIR.join('move-worked.txt') }
        it "should work and return true and call_digraph_listeners a shell" do
          from.should be_exist
          move_to.exist?.should eql false
          content = File.read(from)
          r = subject.invoke
          r.should eql(true)
          from.exist?.should eql false
          move_to.should be_exist
          File.read(move_to).should eql(content)
          fingers[:shell].last.should match(/mv .*some-file.txt .*move-worked.txt/)
        end
      end

      context "to an unavailable location" do
        let(:move_to) { FIXTURES_DIR.join('another-file.txt') }
        it "should return false and call_digraph_listeners an error" do
          r = subject.invoke
          r.should eql(false)
          fingers[:error].last.should match(/file exists.*another-file/)
        end
      end
    end

    context "when moving a nonexitant file" do
      let(:from) { "#{FIXTURES_DIR}/not-there" }
      let(:move_to) { "#{BUILD_DIR}/wherever" }
      it "should return false and call_digraph_listeners an error" do
        r = subject.invoke(context)
        r.should eql(false)
        fingers[:error].last.should match(/file not found.*not-there/)
      end
    end
  end
end
