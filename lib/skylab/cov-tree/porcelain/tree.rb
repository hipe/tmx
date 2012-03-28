require 'set'

module Skylab::CovTree
  class Porcelain::Tree
    include ::Skylab::Porcelain::TiteColor

    @sides = [:test, :code] # order matters, left one gets the "plus"

    @colors = {
      [:test, :code].to_set => :green,
      [:test].to_set        => :cyan,
      [:code].to_set        => :red
    }

    def controller_class
      require ROOT.join('plumbing/tree').to_s
      Plumbing::Tree
    end
    def emit(*a)
      @emitter.emit(*a)
    end
    def initialize params
      @emitter = params.delete(:emitter) or raise("no emitter")
      @params = params
    end
    def invoke
      a = []
      r = controller_class.new(@params) do |o|
        thru = ->(e) { emit(e.type, e) }
        o.on_error &thru
        o.on_payload &thru
        o.on_line_meta { |e| a << e }
      end.invoke
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
      a, b = self.class.sides.map { |s| n.types.include?(s) }
      indicator = "[#{a ? '+':' '}|#{b ? '-':' '}]"
      color = self.class.color(n.types) and indicator = send(color, indicator)
      slug = n.slug
      slug.kind_of?(Array) and slug = slug.join(', ')
      ["#{d[:prefix]}#{slug}", indicator] # careful!  escape codes have width
    end
  end
  class << Porcelain::Tree
    attr_reader :colors
    def color types
      @colors[types.to_set] # nil ok
    end
    def error msg
      @emitter.emit(:error, msg)
      false
    end
    def factory params
      @emitter = params[:emitter] or fail("need an emitter")
      if params[:list] and params[:rerun]
        return error('Sorry, cannot use both "list" and "rerun" at the same time')
      elsif params[:rerun]
        params[:path] and
          return error("Sorry, cannot use both \"rerun\" and \"path\" (#{params[:path]}) at the same time")
        require File.expand_path('../rerun', __FILE__)
        klass = Porcelain::Rerun
      else
        klass = self
      end
      klass.new params
    end
    attr_reader :sides
  end
end


