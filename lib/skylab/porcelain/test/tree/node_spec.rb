require File.expand_path('../../support', __FILE__)
require File.expand_path('../../../tree/node', __FILE__)

module Skylab::Porcelain::TestNamespace
  include Skylab::Porcelain
  describe Tree::Node do
    let(:paths) { [
      'a',
      'bb/cc/dd',
      'bb/cc',
      'bb/cc/dd/ee'
    ] }
    it "does paths to tree and vice-versa" do
      node = Tree.from_paths(paths)
      paths_ = node.to_paths
      want = <<-HERE.deindent
       a
       bb/
       bb/cc/
       bb/cc/dd/
       bb/cc/dd/ee
      HERE
      have = paths_.join("\n")
      have.should eql(want)
    end
  end
end

