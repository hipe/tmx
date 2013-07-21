# [#bs-001]  # post-assembly-language-phase-phase

module Skylab::CovTree

  class CLI::Actions::Cov < CLI::Action

    SIDE_A = [ :test, :code ].freeze

    COLOR_H = {
      [ :branch ].to_set      => :white,
      [ :code, :test ].to_set => :green,  # order matters, see comment below
      [ :test ].to_set        => :cyan,
      [ :code ].to_set        => :red,
    }.tap { |h| h.values.map( & :freeze ) ; h.freeze }

    # order matters above - since test nodes get merged destructively into
    # code nodes, the order is as such and never the reverse.

    MetaHell::FUN::Fields_[ :client, self, :method, :absorb_params,
      :field_i_a, [ :list_as, :path, :be_verbose ] ]

    def invoke param_h
      absorb_params( * param_h.flatten )
      o = CovTree::API::Actions.const_fetch( local_normal_name ).new self
      o.on_error method( :error )
      o.on_info method( :info )
      o.prepare :list_as, @list_as, :path, @path, :be_verbose, @be_verbose
      r = false
      begin
        @error_count.zero? or break
        if (( i = o.get_mutex_list_as ))
          @card_a = nil
          send LIST_AS_H_.fetch( i ), o
        else
          wire_to_render_trees o
        end
        r = o.execute or break
        r = if @card_a.nil? then true
        elsif @card_a.length.nonzero?
          r = render_tree_lines
        end
      end while nil
      r
    end

    LIST_AS_H_ = {
      list: :list_as_list,
      test_tree_shallow: :list_as_test_tree_shallow
    }.freeze

  private

    def list_as_list o
      o.on_test_file do |e|
        full_pathname = e.hub.get_sub_hub_pn.join e.short_pathname
        payload "#{ full_pathname }"           # (why use escape_path? it
      end                                      # looks fine just to use the path
      show_number o                            # header that the user provided.)
      nil
    end

    def list_as_test_tree_shallow o
      o.on_hub_point do |ap|
        payload "#{ ap.path_moniker_stem }/"
      end
      o.on_test_file do |e|
        test_file_relative_pathname =
          e.hub.relative_path_to e.short_pathname
        payload "  #{ test_file_relative_pathname }"  # indented with '  '
      end
      show_number o
      nil
    end

    def show_number o
      o.on_number_of_test_files do |num|
        info "(#{ num } test file#{ s num } total)"
      end
    end

    def wire_to_render_trees o
      o.on_info_tree do |st|
        @infostream.puts "#{ em "#{ st.label }:" }"
        @infostream.puts st.tree.to_text
        nil
      end
      card_a = [ ]
      o.on_tree_line_card( & card_a.method( :<< ) )
      @card_a = card_a
      nil
    end

    BRANCH_A = [ :branch ].freeze

    def prerender_tree_line card
      n = card.node
      a, b = self.class.side_a.map { |s| n.tag_a.include? s }
      indicator = "[#{a ? '+':' '}|#{b ? '-':' '}]"
      use_types = n.is_leaf ? n.tag_a : BRANCH_A
      color = self.class.lookup_color_for_tag_a use_types
      indicator = send(color, indicator) if color
      if 1 < n.tag_a.length
        case (( a = n._isomorphic_key_a )).length
        when 0, 1, 2
          slug_s = a * ', '
        else
          slug_s = "#{ a.first }, #{ a.last }"
        end
      else
        slug_s = n.slug
      end
      [ "#{ card.prefix }#{ slug_s }", indicator ]  # (escape codes have width)
    end

    def render_tree_lines
      event_a = @card_a
      matrix = event_a.map( & method( :prerender_tree_line ) )
      max = matrix.reduce( 0 ) { |m, x| (y = x.first.length) > m ? y : m }
      fmt = "%-#{ max }s  %s"
      matrix.each do |a|
        payload( fmt % a )
      end
      true
    end
  end

  class << CLI::Actions::Cov

    def color_h
      self::COLOR_H
    end

    def lookup_color_for_tag_a tag_a
      as_set = tag_a.to_set
      color_h.fetch( as_set ) { }
    end

    def side_a
      self::SIDE_A
    end
  end
end
