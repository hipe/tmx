require_relative 'test-support'

module Skylab::Dependency::TestSupport::Tasks

  # (not Q-uickie - `before` used below)

  describe TaskTypes::Get do

    extend Tasks_TestSupport

    let(:build_dir) { BUILD_DIR }
    let(:context) { { :build_dir => build_dir } }
    let(:host) { ::Pathname.new('http://localhost:1324/') }
    let(:klass) { TaskTypes::Get }
    let(:log) { Dependency::Services::StringIO.new }
    before(:each) { BUILD_DIR.prepare }
    before(:all) { FILE_SERVER.run }

    subject do
      klass.new(
        :from => from,
        :get => get
      ) { |t| wire! t }
    end
    context "when requesting one file", slow:true do
      let(:from) { nil }
      let(:get) { ::Pathname.new File.join(host, uri) }
      let(:uri) { "some-file.txt" }
      let(:source_file_path) { FILE_SERVER.doc_root_pathname.join uri }
      context "that exists" do
       it "puts it in the basket, the requested file, byte per byte" do
          subject.invoke(context)
          (exp = BUILD_DIR.join(get.basename)).should be_exist
          (File.stat(exp).size).should be > 0
          File.read(exp).should eql(File.read(source_file_path))
        end
        it "shows a shell equivalent (with curl) of the action" do
          r = subject.invoke(context)
          fingers[:shell].grep(/curl -o/).length.should be > 0
          r.should eql(true)
        end
      end
      context "that does not exit" do
        let(:uri) { "not/there.txt" }
        it "should emit error, return false, but not raise" do
          r = subject.invoke(context)
          fingers[:error].grep(/file not found/i).length.should be > 0
          r.should eql(false)
        end
      end
    end
    context "when requesting several files", slow:true do
      def build_dir_files
        Dir.new(BUILD_DIR).entries.select{ |x| x !~ /^\./ }.sort
      end
      context "that do exist" do
        let(:from) { host }
        let(:get) { %w(some-file.txt another-file.txt) }
        it "puts all of the files in the baseket" do
          subject.invoke(context)
          fingers[:shell].grep(/some-file/).length.should be 1
          fingers[:shell].grep(/another-file/).length.should be 1
          # ohai = Dir.new(BUILD_DIR).map { |x| x }
          build_dir_files.join(' ').should eql('another-file.txt some-file.txt')
        end
      end
      context "of which a subset do not exist" do
        let(:from) { host }
        let(:get) { %w(not-there.txt another-file.txt) }
        it "whines on the files that dont exist, returns false, gets the files that do" do
          r = subject.invoke(context)
          r.should eql(false)
          fingers[:error].should be_include("File not found: http://localhost:1324/not-there.txt")
          build_dir_files.should eql(['another-file.txt'])
        end
      end
    end
  end
end
