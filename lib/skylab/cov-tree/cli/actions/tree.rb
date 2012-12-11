require 'set'

module Skylab::CovTree
  class CLI::Actions::Tree < CLI::Action

    @sides = [:test, :code] # order matters, left one gets the "plus"

    @colors = {
      [:branch].to_set      => :white,
      [:test, :code].to_set => :green,
      [:test].to_set        => :cyan,
      [:code].to_set        => :red,
    }

    def invoke
      a = []
      r = controller_class.new(list_as: list_as, path: path, stylus: self) do |o|
        o.on_error { |e| emit(:error, e) }
        case list_as
        when :tree
          o.on_anchor_point { |e| emit(:payload, "#{e.anchor_point.dir.pretty}/") }
          o.on_test_file    { |e| emit(:payload, "  #{e.test_file.relative_pathname}") }
        when :list
          o.on_test_file    { |e| emit(:payload, e.test_file.pathname.pretty.to_s) }
        end
        if list_as
          o.on_number_of_test_files do |e|
            emit(:info, "(#{e.number} test file#{s e.number} total)")
          end
        end
        o.on_tree_line_meta { |e| a << e }
      end.invoke
      a.any? and return _render_tree_lines a
      r
    end
    attr_accessor :list_as
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
      _use_types = n.leaf? ? n.types : [:branch]
      color = self.class.color(_use_types) and indicator = send(color, indicator)
      use_slugs = if 2 > n.isomorphic_slugs.length then n.isomorphic_slugs
                  elsif 1 < n.types.length         then n.isomorphic_slugs
                  else # n.types size is zero or one, in such cases we only
                    # want the main slug, not the isomorphic slugs (whose files don't exist)
                    [n.slug]
                  end
      slug = use_slugs.join(', ')
      if dn = n.slug_dirname
        a, b = use_slugs.length > 1 ? ['{', '}'] : ['', '']
        slug = "#{dn}#{n.path_separator}#{a}#{slug}#{b}"
      end
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
