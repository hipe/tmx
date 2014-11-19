module Skylab::TreetopTools

  Parser::InputAdapter::Types = ::Module.new

  g = LIB_.digraph.new

  Parser::InputAdapter::Types::STREAM = g.node! :stream
  Parser::InputAdapter::Types::FILE   = g.node! :file, is: :stream
  Parser::InputAdapter::Types::STRING = g.node! :string

end
