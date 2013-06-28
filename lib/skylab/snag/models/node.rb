module Skylab::Snag

  module Models::Node

    require_relative 'node/enumerator'  # [#mh-035] preload bc toplevel exists

    max_lines_per_node = 2

    define_singleton_method :max_lines_per_node do max_lines_per_node end
  end
end
