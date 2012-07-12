require 'set'

module Skylab::CovTree
  class CLI::Actions::Tree < CLI::Action
    @sides = [:test, :code] # order matters, left one gets the "plus"

    @colors = {
      [:test, :code].to_set => :green,
      [:test].to_set        => :cyan,
      [:code].to_set        => :red
    }

    def controller_class
      require ROOT.join('api/tree').to_s
      API::Actions::Tree
    end
    attr_accessor :do_list
    def emit(*a)
      @emitter.emit(*a)
    end
    attr_writer :emitter
    def initialize params
      params.each do |k, v|
        send("#{k}=", v)
      end
      @emitter or fail('no emitter')
    end
    def invoke
      a = []
      r = controller_class.new(do_list: do_list, path: path, stylus: self) do |o|
        thru = ->(e) { emit(e.type, e) }
        o.on_error(&thru)
        o.on_payload(&thru)
        o.on_line_meta { |e| a << e }
      end.invoke
      a.any? and return _render_tree_lines a
      r
    end
    def _render_tree_lines events
      _matrix = events.map { |e| _prerender_tree_line e.payload }
      max = _matrix.map{ |a| a.first.length }.max
      fmt = "%-#{max}s  %s"
      _matrix.each { |a| emit(:payload, fmt % a) }
      true
    end
    attr_accessor :path
    def _prerender_tree_line d
      n = d[:node]
      a, b = self.class.sides.map { |s| n.types.include?(s) }
      indicator = "[#{a ? '+':' '}|#{b ? '-':' '}]"
      color = self.class.color(n.types) and indicator = send(color, indicator)
      slug = n.slug
      slug.kind_of?(Array) and slug = slug.join(', ')
      ["#{d[:prefix]}#{slug}", indicator] # careful!  escape codes have width
    end
  end
  class << CLI::Actions::Tree
    attr_reader :colors
    def color types
      @colors[types.to_set] # nil ok
    end
    def factory params
      params = params.dup
      if params.delete(:rerun)
        require_relative 'rerun'
        CLI::Actions::Rerun
      else
        self
      end.new params
    end
    attr_reader :sides
  end
end
