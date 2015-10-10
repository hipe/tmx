require_relative 'test-support'

module Skylab::TaskExamples::TestSupport::Tasks

  describe "[de] task-types - tarball to " do  # :+#no-quickie because: nested `before`

    extend TS_

    let :context do
      { build_dir: BUILD_DIR.to_s }
    end

    let :subject do
      TaskTypes::TarballTo.new( build_args ) { |t| wire! t }
    end

    context "with bad build args" do

      let( :build_args ) { { } }

      it "throws an exception about what it needs" do
        ->() { subject.invoke }.should raise_exception(RuntimeError,
          /missing required attributes:? from, tarball_to/
        )
      end
    end

    context "with good build args (no interpolation)" do
      before :all do
        FILE_SERVER.run
      end

      before :each do
        BUILD_DIR.prepare
      end

      let(:to ) { BUILD_DIR.join 'ohai' }

      let :build_args do
        { tarball_to: to,
          from: 'http://localhost:1324/mginy-0.0.1.tar.gz'
        }
      end

      it "must work" do
        r = subject.invoke
        r.should eql(true)
        # the below is temporary, it is not to spec afaik
        fingers[:shell].last.should match(/curl -o.*tar\.gz.*tar\.gz/)
      end
    end
  end
end
