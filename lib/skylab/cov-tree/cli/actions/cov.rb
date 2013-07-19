module Skylab::CovTree

  class CLI::Actions::Tree < CLI::Action

    @sides = [:test, :code] # order matters, left one gets the "plus"

    @colors = {
      [:branch].to_set      => :white,
      [:test, :code].to_set => :green,
      [:test].to_set        => :cyan,
      [:code].to_set        => :red,
    }

    params = ::Struct.new :list_as, :path, :verbose


    define_method :subinvoke do |params_h|     # quintessence of headless-like
                                               # pattern (hopefully), all
                                               # unpacked:

      p = params.new                           # we validate and internalize
      params_h.each { |k, v| p[k] = v }        # the params, turning them
      @list_as = p[:list_as]                   # into ivars or getters or w/e
      @path = p[:path]                         # and maybe defaults and
      @verbose = p[:verbose]                   # validation whatever

      k = CovTree::API::Actions.const_fetch local_normal_name # then we build the
      o = k.new self                           # corresponding API action,
                                               # with self as its request_client

      o.on_error { |e| error e }               # then for this particular action
                                               # we do lots of crazy
      o.on_info { |e| info e }                 # cockameme wiring ..

      case list_as
      when :tree
        o.on_anchor_point do |ap|
          payload "#{ ap.dir_pathname }/"
        end
        o.on_test_file do |e|
          test_file_relative_pathname =
            e.anchor.relative_path_to e.short_pathname
          payload "  #{ test_file_relative_pathname }" # indented with '  '
        end

      when :list
        o.on_test_file do |e|
          full_pathname = e.anchor.sub_anchor.join e.short_pathname
          payload "#{ full_pathname }"         # (why use escape_path? it
        end                                    # looks fine just to use the path
      end                                      # header that the user provided.)

      if list_as
        o.on_number_of_test_files do |num|
          info "(#{ num } test file#{ s num } total)"
        end
      end

      tree_lines = [ ]

      o.on_tree_line_meta do |e|
        tree_lines.push e
      end

                                               # now that it is all wired,
      res = o.invoke list_as: list_as,         # we invoke it, passing
        path: path, verbose: verbose           # it the appropriate params

      if ! tree_lines.empty?
        res = render_tree_lines tree_lines
      end

      res
    end

  protected

    attr_accessor :list_as

    attr_accessor :path

    def prerender_tree_line d
      n = d[:node]
      a, b = self.class.sides.map { |s| n.types.include? s }
      indicator = "[#{a ? '+':' '}|#{b ? '-':' '}]"
      use_types = n.is_leaf ? n.types : [:branch]
      color = self.class.color use_types
      indicator = send(color, indicator) if color
      use_slugs = if 2 > n.isomorphic_slugs.length then n.isomorphic_slugs
                  elsif 1 < n.types.length         then n.isomorphic_slugs
                  else # n.types size is zero or one, in such cases we only
                    # want the main slug, not the isomorphic slugs
                    [n.slug] # (whose files don't exist)
                  end
      slug = use_slugs.join ', '
      dn = n.slug_dirname
      if dn
        a, b = use_slugs.length > 1 ? ['{', '}'] : ['', '']
        slug = "#{ dn }#{ n.path_separator }#{ a }#{ slug }#{ b }"
      end
      ["#{ d[:prefix] }#{ slug }", indicator] # careful! escape codes have width
    end

    def render_tree_lines events
      matrix = events.map { |e| prerender_tree_line e }
      max = matrix.reduce( 0 ) { |m, x| (y = x.first.length) > m ? y : m }
      fmt = "%-#{ max }s  %s"
      matrix.each do |a|
        payload( fmt % a )
      end
      true
    end

    attr_reader :verbose
  end



  class << CLI::Actions::Tree

    attr_reader :colors

    def color types
      @colors[types.to_set] # nil ok
    end

    attr_reader :sides
  end
end
