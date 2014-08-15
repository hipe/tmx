module Skylab::Snag

  module API::Actions::Nodes

    Autoloader_[ self, :boxxy ]  # :+[#cb-041] this is a hybrid boxxy node.
  end

  class API::Actions::Nodes::Add < API::Action

    attribute :be_verbose
    attribute :do_prepend_open_tag, default: false
    attribute    :dry_run
    attribute    :message, required: false

    listeners_digraph  info: :lingual,
                 new_node: :datapoint,
                 raw_info: :datapoint

    inflection.inflect.noun :singular

  private

    def if_nodes_execute
      @nodes.add @message,
        @do_prepend_open_tag,
        @dry_run,
        @be_verbose,
        -> n do
          send_to_listener :new_node, n
        end
    end
  end

  class API::Actions::Nodes::Reduce < API::Action

    attribute :be_verbose, default: true
    attribute :include_all  # (includes invalid nodes)
    attribute :identifier_ref
    attribute  :max_count
    attribute :query_sexp

    listeners_digraph  info: :lingual,
            invalid_node: :datapoint,
             output_line: :datapoint

    inflection.inflect.noun :plural

  private

    def if_nodes_execute
      @sexp = nil
      @query_sexp and @sexp = @query_sexp.dup
      if @identifier_ref
        ( @sexp ||= [ :and ] ).push [ :identifier_ref, @identifier_ref ]
      end
      ok = ! @include_all || when_include_all_resolve_sexp
      ok &&= from_any_OK_sexp_resolve_query
      ok &&= from_query_resolve_scan
      ok && execute_with_scan
    end

    def when_include_all_resolve_sexp
      if @sexp
        error_string say_cannot_all
      else
        @sexp = [ :all ]
        ACHIEVED_
      end
    end

    def from_any_OK_sexp_resolve_query
      @sexp ||= [ :valid ]
      @query = @nodes.build_query @sexp, @max_count
      @query and ACHIEVED_
    end

    def from_query_resolve_scan
      @scan = @nodes.all
      @scan = @scan.reduce_by { |_| @total_count += 1 }
      @scan = @scan.reduce_by do |node|
        _pass = @query.match? node
        _pass
      end
      @scan = @scan.reduce_by { |_| @pass_count += 1 }
      if @query.max_count
        @scan = @scan.stop_when do |_|
          _stop = @query.it_is_time_to_stop
          _stop
        end
      end
      @pass_count = @total_count = 0
      ACHIEVED_
    end

    def execute_with_scan
      @lines = Monadic_Yielder__.new do |txt|
        send_to_listener :output_line, txt
        nil
      end
      @y = if @be_verbose
        render_node_as_yaml
      else
        render_node_tersely
      end
      in_scan_render_nodes
    end

    def say_cannot_all
      "sorry - it doesn't make sense to use `all` #{
        }with any other search criteria"
    end

    def render_node_tersely
      m = @lines.method( :<< )
      ::Enumerator::Yielder.new do |n|
        @lines << n.first_line
        n.extra_line_a.each(& m ) if n.extra_lines_count.nonzero?
        nil
      end
    end

    field_names = Snag_::Models::Node.main_field_names

    define_method :render_node_as_yaml do
      o = Snag_::Text_::Yamlization.new field_names
      o.on_text_line(& @lines.method( :<< ) )
      o
    end

    def in_scan_render_nodes
      scan = @scan
      info_string "(looking at #{ escape_path manifest_pathname })"
      scan.each do |node|
        if node.is_valid
          @y << node
        else
          send_to_listener :invalid_node, node
        end
      end
      case 1 <=> @pass_count
      when -1 ; when_found_multiple
      when  0 ; when_found_one
      when  1 ; when_not_found
      end
    end

    # these behaviors as such are not quite appropriate for the API :+[#061]

    def when_not_found
      info_string "of #{ @total_count } searched, found no node #{
        }#{ @query.phrasal_noun_modifier }"
      NEUTRAL_
    end

    def when_found_one
      if @be_verbose
        when_found_one_and_verbose
      else
        NEUTRAL_
      end
    end

    def when_found_one_and_verbose
      info_string "looked at #{ @total_count } nodes to find this one #{
       }#{ @query.phrasal_noun_modifier }"
      NEUTRAL_
    end

    def when_found_multiple
      _s = if @total_count == @pass_count
        "found #{ @pass_count } nodes "
      else
        "of #{ @total_count } seen nodes found #{ @pass_count } "
      end
      info_string "#{ _s }#{ @query.phrasal_noun_modifier }"
      NEUTRAL_
    end

    class Monadic_Yielder__ < ::Enumerator::Yielder
      def << x  # was once nec. for [cb] digraph to see an arity of 1. still?
        super
      end
      alias_method :yield, :<<
    end
  end
end
