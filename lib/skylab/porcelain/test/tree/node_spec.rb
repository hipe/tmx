require_relative 'test-support'

module Skylab::Porcelain::TestNamespace

  describe Porcelain::Tree do

    let(:paths) { [
      'a',
      'bb/cc/dd',
      'bb/cc',
      'bb/cc/dd/ee'
    ] }

    it "does paths to tree and vice-versa" do
      node = Porcelain::Tree.from :paths, paths
      paths_ = node.to_paths
      want = <<-HERE.unindent
       a
       bb/
       bb/cc/
       bb/cc/dd/
       bb/cc/dd/ee
      HERE
      have = "#{paths_.join("\n")}\n"
      have.should eql(want)
    end

    context "with regards to longest common base path" do
      let(:tree) { Porcelain::Tree.from :paths, paths }
      let :subject do tree.longest_common_base_path end
      context "when empty" do
        let(:paths) { %w() }
        it("nil")   { subject.should be_nil }
      end
      context "when 1x1" do
        let(:paths) { %w(one) }
        it("one")   { subject.should eql(['one']) }
      end
      context "when 1x2" do
        let(:paths) { %w(one/two) }
        it("two")   { subject.should eql(['one', 'two']) }
      end
      context "when 1x3" do
        let(:paths) { %w(one/two/three) }
        it("three") { subject.should eql(%w(one two three)) }
      end
      context "when 2x1 (different)" do
        let(:paths) { %w(one two) }
        it("nope")  { subject.should be_nil }
      end
      context "when 2x1 (same)" do
        let(:paths) { %w(yup yup) }
        it("yup")   { subject.should eql(['yup']) }
      end
      context "when 2x2 (some)" do
        let(:paths) { %w(a/b a/c) }
        it("some")  { subject.should eql(['a']) }
      end
      context "when 2x2 (none)" do
        let(:paths) { %w(x/a y/a) }
        it("none")  { subject.should be_nil }
      end
      context "when 2x2 (all)" do # actually should become 1x2
        let(:paths) { %w(p/q p/q) }
        it("all")   { subject.should eql(%w(p q)) }
      end
      context "when 3x3 (some)" do
        let(:paths) { %w(a/b/c a/b/f/g a/b/f/h a/b/l/m/n) }
        it("some")  { subject.should eql(%w(a b)) }
      end
    end
  end
end
