require 'skylab/semantic/core'

module Skylab::TreetopTools
  module Parser::InputAdapter::Types end
  g = ::Skylab::Semantic::Digraph.new
  Parser::InputAdapter::Types::STREAM = g.node!(:stream)
  Parser::InputAdapter::Types::FILE   = g.node!(:file, is: :stream)
  Parser::InputAdapter::Types::STRING = g.node!(:string)
end
