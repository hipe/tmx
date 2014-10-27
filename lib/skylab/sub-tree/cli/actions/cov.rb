# [#bs-001]  # post-assembly-language-phase-phase

module Skylab::SubTree

  SubTree::Library_.touch :Set

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

    Lib_::Basic_fields[ :client, self,
      :absorber, :absrb_iambic_fully,
      :field_i_a, [ :list_as, :path, :be_verbose ] ]

    def initialize
      @error_count = 0
    end

    def init_for_invocation svcs
      @infostream, @cli_client_emit_p = svcs.at :errstream, :emit_proc
      self
    end

    def invoke param_h
      absrb_iambic_fully param_h.flatten
      o = corresponding_api_action_class.new.
        init_for_invocation_with_services get_services
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

    def get_services
      Services_For_API_Action_.new self
    end
    #
    Services_For_API_Action_ = SubTree::Lib_::Iambic[
      :receive_error_event, -> { method :error_event_notify },
      :receive_error_string, -> { method :error_string_notify },
      :receive_info_string,  -> { method :info_string_notify } ]

    p = Lib_::Method_lib[].curry.unbound instance_method :emit_from_parent

    def error_event_notify e
      @error_count += 1
      _error_event_notify e
      nil
    end

    define_method :_error_event_notify, & p.curry[ :error_event ]

    def error_string_notify s
      @error_count += 1
      _error_string_notify s
      nil
    end

    define_method :_error_string_notify, & p.curry[ :error_string ]

    define_method :info_string_notify, & p.curry[ :info_string ]

    def some_expression_agent
      SubTree::CLI.some_expression_agent
    end

    def list_as_list o
      o.on_test_file do |e|
        full_pathname = e.hub.get_sub_hub_pn.join e.short_pathname
        send_payload_string "#{ full_pathname }"           # (why use e-scape_path? it
      end                                      # looks fine just to use the path
      show_number o                            # header that the user provided.)
      nil
    end

    def list_as_test_tree_shallow o
      o.on_hub_point do |ap|
        send_payload_string "#{ ap.path_moniker_stem }/"
      end
      o.on_test_file do |e|
        test_file_relative_pathname =
          e.hub.relative_path_to e.short_pathname
        send_payload_string "  #{ test_file_relative_pathname }"  # indented with '  '
      end
      show_number o
      nil
    end

    def show_number o
      o.on_number_of_test_files do |d|
        _s = some_expression_agent.calculate do
          "(#{ d } test file#{ s d } total)"
        end
        info_string_notify _s
        nil
      end
      nil
    end

    def wire_to_render_trees o
      io = @infostream
      some_expression_agent.calculate do
        o.on_info_tree do |st|
          io.puts "#{ em "#{ st.label }:" }"
          io.puts st.tree.to_text
        end
      end
      o.on_tree_line_card( & (( @card_a = [ ] )).method( :<< ) )
      nil
    end

    def render_tree_lines
      event_a = @card_a
      @expression_agent ||= some_expression_agent
      a_a = event_a.map( & method( :treeline_and_glyphage_for_card ) )
      max = a_a.reduce 0 do |m, x| m < (( y = x.first.length )) ? y : m end
      fmt = "%-#{ max }s  %s"
      a_a.each do |a|
        send_payload_string fmt % a
      end
      true
    end
    #
    define_method :send_payload_string, & p.curry[ :payload_string ]
    #
    def treeline_and_glyphage_for_card card
      n = card.node
      a, b = self.class.side_a.map { |s| n.tag_a.include? s }
      glyphage = "[#{ a ? '+' : SPACE_}|#{ b ? '-' : SPACE_ }]"
      use_types = n.is_leaf ? n.tag_a : BRANCH_A_
      color_i = self.class.lookup_color_for_tag_a( use_types ) and
        glyphage = @expression_agent.stylize( color_i, glyphage )
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
      [ "#{ card.prefix }#{ slug_s }", glyphage ]  # (escape codes have width)
    end
    #
    BRANCH_A_ = [ :branch ].freeze
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
