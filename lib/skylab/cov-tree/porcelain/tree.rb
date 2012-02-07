module Skylab::CovTree
  class Porcelain::Tree
    SIDES = [:test, :code]
    include ::Skylab::Porcelain::TiteColor
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
      t, c = self.class::SIDES.map { |s| (Array === n.type) ? n.type.include?(s) : (s == n.type) }
      _indicator = "[#{t ? '+':' '}|#{c ? '-':' '}]"
      if (color = (t ? (c ? :green : :cyan) : (c ? :red : nil )))
        _indicator = send(color, _indicator)
      end
      _slug = n.slug
      _slug.kind_of?(Array) and _slug = _slug.join(', ')
      ["#{d[:prefix]}#{_slug}", _indicator]
    end
  end
  class << Porcelain::Tree
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
  end
end


