# [#bs-001]  # post-assembly-language-phase-phase

module Skylab::SubTree

  SubTree::Library_.touch :Set

  class CLI::Actions::Cov < CLI::Action

    def initialize
      @card_a = []
    end

    def receive_payload_event ev  # assume 'ok'
      send :"receive_payload_#{ ev.terminal_channel_i }", ev
    end

    def receive_payload_hub_point ev
      send :"receive_payload_hub_when_#{ ev.list_as }", ev
    end

    def receive_payload_test_file ev
      send :"send_payload_test_file_when_#{ ev.list_as }", ev
    end

    def receive_payload_tree_line_card ev
      @card_a.push ev.card
      nil
    end

    def receive_payload_hub_when_list ev
      # nothing.
    end

    def receive_payload_hub_when_test_tree_shallow ev
      send_payload_string "#{ ev.hub.test_dir_pn.to_path }"
    end

    def receive_payload_number_of_test_files ev
      send_info_string_for_number_of_test_files ev
    end

    def receive_payload_done_with_tree ev
      tl_g_a_a = []
      max_width_d = 0
      @card_a.each do |card|
        tl, g = treeline_and_glyphage_for_card card
        tl_g_a_a.push [ tl, g ]
        if max_width_d < tl.length
          max_width_d = tl.length
        end
      end
      fmt = "%-#{ max_width_d }s  %s"
      tl_g_a_a.each do |tl_g|
        send_payload_string fmt % tl_g
      end
      nil
    end

  private

    # ~ senders & support

    def treeline_and_glyphage_for_card card
      n = card.node
      a, b = SIDE_A__.map do |s|
        n.tag_a.include? s
      end
      glyphage = "[#{ a ? '+' : SPACE_ }|#{ b ? '-' : SPACE_ }]"
      use_types = if n.is_leaf
        n.tag_a
      else
        BRANCH_A_
      end
      color_i = Lookup_color_for_tag_a__[ use_types ]
      if color_i
        glyphage = expression_agent.stylize glyphage, color_i  # or `stylify`
        # (remember escape codes have width)
      end
      if 1 < n.tag_a.length
        a = n._isomorphic_key_a
        slug_s = if a.length < 3
          a * ', '
        else
          # ick - [ "foo", " foo [ & bar ]", "bar" ]
          "#{ a.first }, #{ a.last }"
        end
      else
        slug_s = n.slug
      end
      [ "#{ card.prefix }#{ slug_s }", glyphage ]
    end
    #
    BRANCH_A_ = [ :branch ].freeze

    SIDE_A__ = [ :test, :code ].freeze

    Lookup_color_for_tag_a__ = -> tag_a do
      COLOR_H__.fetch tag_a.to_set do end
    end

    COLOR_H__ = {
      [ :branch ].to_set      => :white,
      [ :code, :test ].to_set => :green,  # order matters, see comment below
      [ :test ].to_set        => :cyan,
      [ :code ].to_set        => :red,
    }.tap { |h| h.values.map( & :freeze ) ; h.freeze }

    # order matters above - since test nodes get merged destructively into
    # code nodes, the order is as such and never the reverse.


    def send_payload_test_file_when_list ev
      # note we don't mess with reaching e-scape_path logic thru `pth` - it
      # looks fine just to display the path relativized to the argument path

      _full_pn = ev.hub.sub_hub_pathname.join ev.short_pathname
      send_payload_string _full_pn.to_path
      nil
    end

    def send_payload_test_file_when_test_tree_shallow ev
      _rel_path = ev.hub.relative_path_to ev.short_pathname
      send_payload_string "  #{ _rel_path }"  # indented with '  '
      nil
    end

    def send_info_string_for_number_of_test_files ev
      d = ev.count
      case ev.scope_symbol
      when :in_hub
        s = expression_agent.calculate do
          "(#{ d } test file#{ s d } in hub)"
        end
      when :grand_total
        s = expression_agent.calculate do
          "(#{ d } test file#{ s d } in all)"
        end
      else
        s = expression_agent.calculate do
          "(#{ d } test file#{ s d } total)"
        end
      end
      send_info_string s
      nil
    end

    def other
      hub = ev.hub
      tdpn = hub.test_dir_pn  # OR 'get_sub_hub_pn'
      scn = hub.to_local_test_pathname_scan
      while pn = scn.gets
        _full = tdpn.join pn
        $stderr.puts "  #{ _full }"
      end
      nil
    end
  end
end
