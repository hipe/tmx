module Skylab::Snag
  module Models::Node
    require_relative 'node/enumerator' # [#sl-124] preload bc toplevel exists
    require_relative 'node/file'       # [#sl-124] preload bc toplevel exists
  end
end
