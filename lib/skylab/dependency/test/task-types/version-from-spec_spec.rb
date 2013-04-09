require_relative 'test-support'

module Skylab::Dependency::TestSupport::Tasks

  # Quickie!

  describe TaskTypes::VersionFrom do

    extend Tasks_TestSupport

    let(:klass) { TaskTypes::VersionFrom }
    let(:log) { Dependency::Services::StringIO.new }
    let(:must_be_in_range) { nil }
    let(:parse_with) { '/(\d+\.\d+\.\d+)/' }
    let(:version_from) { 'echo "version 1.2.34 is the version"' }
    let :subject do
      klass.new(
        :must_be_in_range => must_be_in_range,
        :parse_with => parse_with,
        :version_from => version_from
      ) do |t|
        t.on_all do |e|
          debug_event e if do_debug
          log.puts e.text
        end
      end
    end
    context "when reporting a version" do
      let(:context) { { :show_version => true } }
      context 'without using a regex' do
        let(:parse_with) { nil }
        it "just reports the output" do
          subject.invoke context
        end
      end
      context 'with a regex' do
        context('against a matching output') do
          let(:version_from) { 'echo "ver 1.3.78 is it"' }
          it "shows the matched portion of the output" do
            subject.invoke context
          end
        end
        context 'against a non-matching output' do
          let(:version_from) { 'echo "ver A.B.foo"' }
          it "shows all of the output" do
            subject.invoke context
          end
        end
      end
    end
    context "when checking a version" do
      let(:context) { { } }
      let(:must_be_in_range) { '1.2+' }
      context "with a bad 'must_be_in_range' assertion" do
        let(:must_be_in_range) { '~> 1.2' }
        it "fails" do
          lambda{ subject.invoke context }.should(
            raise_error(/Bad range assertion/)
          )
        end
      end
      context "without a 'must_be_in_range' assertion" do
        let(:must_be_in_range) { nil }
        it "fails" do
          lambda{ subject.invoke context }.should(
            raise_error(/do not use.*without.*must be in range/i)
          )
        end
      end
      context "when the regex matches" do
        context "and the version matches" do
          let(:version_from) { 'echo "ver 1.2.1"' }
          it "says that it matches" do
            subject.invoke( context ).should eql( true )
            log.string.include?('version 1.2.1 is in range 1.2+').should eql(true)
          end
        end
        context "and the version does not match" do
          let(:version_from) { 'echo "version 0.0.1"' }
          it "says that is doesn't match" do
            subject.invoke( context ).should eql( false )
            unstylize( log.string ).should match(
              /\bversion mismatch: needed 1\.2\+ had 0\.0\.1\b/i
            )
          end
        end
      end
      context "when the regex does not match" do
        let(:version_from) { 'echo "version A.B.C"' }
        it "reports a failure" do
          subject.invoke(context).should eql(false)
          log.string.include?('needed 1.2+ had version A.B.C').should eql(true)
        end
      end
    end
  end
end
