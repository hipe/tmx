require File.expand_path('../../../skylab', __FILE__)

require 'skylab/slake/muxer'

module Skylab::CovTree
  class Porcelain
    extend ::Skylab::Porcelain
    extend ::Skylab::Slake::Muxer
    emits :all, :info => :all, :error => :all, :payload => :all
    porcelain { blacklist /^on_.*/ }
    argument_syntax '[<path>]'
    option_syntax do |ctx|
      on('-l', '--list', "shows a list of matched test files and returns.") { ctx[:list] = true }
    end
    def tree path=nil, ctx
      require File.expand_path('../plumbing/tree', __FILE__)
      Plumbing::Tree.new(path, ctx) do |o|
        thru = ->(e) { emit(e.type, e) }
        o.on_error &thru
        o.on_payload &thru
        o.on_line_meta do |e|
          emit(:payload, "#{e.data[:prefix]}#{_render_node(e.data[:node])}")
        end
      end.run
    end
  private
    def _render_node node
      "#{node.key}"
    end
  end
end

module Skylab::CovTree::Plumbing
end

