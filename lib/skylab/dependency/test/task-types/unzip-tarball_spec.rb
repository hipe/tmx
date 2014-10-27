require_relative 'test-support'

module Skylab::Dependency::TestSupport::Tasks

  describe "[de] task-types unzip tarball" do   # :+#no-quickie because: nested `before`

    extend TS_

    let :subject do
      TaskTypes::UnzipTarball.new( build_args ) { |t| wire! t }
    end

    context "with no build args" do
      let(:build_args) { {  } }
      let(:context) { { } }
      it "whines about missing required fields" do
        lambda{ subject.invoke }.should raise_exception(
          RuntimeError, /missing required attributes: unzip_tarball, build_dir/
        )
      end
    end

    context "with good build args" do
      let(:build_args) { { :unzip_tarball => unzip_tarball } }
      let(:context) { { :build_dir => BUILD_DIR } }
      context "when tarball does not exist" do
        let(:unzip_tarball) { "#{FIXTURES_DIR}/not-there.tar.gz" }
        it "whines (returns false, emits error)" do
          r = subject.invoke
          r.should eql(false)
          fingers[:error].length.should eql(1)
          fingers[:error][0].should match(/tarball not found.*not-there/)
        end
      end
      context "when the tarball exists" do
        let(:unzip_tarball) { FIXTURES_DIR.join('mginy-0.0.1.tar.gz') }
        before :each do
          # BUILD_DIR.verbose = true  # e.g.
          BUILD_DIR.prepare
          BUILD_DIR.copy(unzip_tarball)
        end
        context "when the target directery exists" do
          before(:each) { BUILD_DIR.mkdir("#{BUILD_DIR}/mginy", verbose: false) }
          it "emits a notice, returns true" do
            r = subject.invoke
            r.should eql(true)
            fingers[:info].length.should eql(1)
            fingers[:info].first.should match(/exists, won't tar extract: .*mginy/)
          end
        end
        context "when it's not a tarball" do
          let(:unzip_tarball) { FIXTURES_DIR.join('not-a-tarball.tar.gz') }
          it "returns false, emits original error" do
            r = subject.invoke
            r.should eql(false)
            fingers[:error].length.should eql(1)
            fingers[:error].first.should match(/failed to unzip.*unrecognized archive format/i)
          end
        end
        context "when it is a tarball and the target directory does not exist" do
          it "returns true, emits shell and tar errstream" do
            r = subject.invoke
            r.should eql(true)
            fingers[:shell].length.should eql(1)
            fingers[:shell].first.should match(/cd .*build-dependency.*tar -xzvf mginy.*/)
            tgt = <<-HERE.unindent.strip
              x mginy/
              x mginy/README
            HERE
            fingers[:err].join('').strip.should eql(tgt)
            # fingers[:err].length.should eql(2)
          end
        end
      end
    end
  end
end
