module Skylab::TreetopTools

  module Parser::InputAdapter::Types
  end

  g = Library_::Basic::Digraph.new

  Parser::InputAdapter::Types::STREAM = g.node! :stream
  Parser::InputAdapter::Types::FILE   = g.node! :file, is: :stream
  Parser::InputAdapter::Types::STRING = g.node! :string

end
