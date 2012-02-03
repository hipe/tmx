require File.expand_path('../../../skylab', __FILE__)

require 'skylab/slake/muxer'
require 'skylab/porcelain/tite-color'

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
      self.class::Tree.new(self).run(path, ctx)
    end
  end
  class Porcelain::Tree
    include ::Skylab::Porcelain::TiteColor
    def emit(*a)
      @emitter.emit(*a)
    end
    def initialize emitter
      @emitter = emitter
    end
    def run path, ctx
      require File.expand_path('../plumbing/tree', __FILE__)
      a = []
      r = Plumbing::Tree.new(path, ctx) do |o|
        thru = ->(e) { emit(e.type, e) }
        o.on_error &thru
        o.on_payload &thru
        o.on_line_meta { |e| a << e }
      end.run
      a.any? and return _render_tree_lines a
      r
    end
    def _render_tree_lines events
      _matrix = events.map { |e| _prerender_tree_line e.data }
      max = _matrix.map{ |a| a.first.length }.max
      fmt = "%-#{max}s  %s"
      _matrix.each { |a| emit(:payload, fmt % a) }
      true
    end
    def _prerender_tree_line d
      n = d[:node]
      t, c = [:test, :code].map { |s| (Array === n.type) ? n.type.include?(s) : (s == n.type) }
      _indicator = "[#{t ? '+':' '}|#{c ? '-':' '}]"
      if (color = (t ? (c ? :green : :cyan) : (c ? :red : nil )))
        _indicator = send(color, _indicator)
      end
      _slug = n.slug
      _slug.kind_of?(Array) and _slug = _slug.join(', ')
      ["#{d[:prefix]}#{_slug}", _indicator]
    end
  end
end

