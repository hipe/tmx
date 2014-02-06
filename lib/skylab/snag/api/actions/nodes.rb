module Skylab::Snag

  module API::Actions::Nodes
    # gets sexed
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

    def execute
      if nodes
        @nodes.add @message,
          @do_prepend_open_tag,
          @dry_run,
          @be_verbose,
          -> n do
            call_digraph_listeners :new_node, n
          end
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
            invalid_node: :structural,
             output_line: :datapoint

    inflection.inflect.noun :plural

  private

    def execute
      res = nil
      begin
        break if ! nodes # we need them we want them, we want them now
        sexp = @query_sexp.dup if @query_sexp
        if @identifier_ref
          ( sexp ||= [ :and ] ).push [ :identifier_ref, @identifier_ref ]
        end
        if @include_all
          if sexp
            error "sorry - it doesn't make sense to use `all` with any #{
              }other search criteria"
            break( res = false )
          else
            sexp = [ :all ]
          end
        end
        sexp ||= [ :valid ]
        found = nodes.find( @max_count, sexp ) or break( res = found )
        @lines = Snag::Library_::Yielder::Mono.new do |txt|
          call_digraph_listeners :output_line, txt
          nil
        end
        @y = if @be_verbose
          render_node_as_yaml
        else
          render_node_tersely
        end
        res = render_nodes found
      end while nil
      res
    end

    # --*--

    def render_node_tersely
      m = @lines.method( :<< )
      ::Enumerator::Yielder.new do |n|
        @lines << n.first_line
        n.extra_line_a.each(& m ) if n.extra_lines_count.nonzero?
        nil
      end
    end

    field_names = Snag::Models::Node::Flyweight.field_names

    define_method :render_node_as_yaml do
      o = Snag::Text_::Yamlization.new field_names
      o.on_text_line(& @lines.method( :<< ) )
      o
    end

    def render_nodes nodes
      info "(looking at #{ escape_path manifest_pathname })"
      nodes.with_count!.each do |node|
        if node.valid?
          @y << node
        else
          call_digraph_listeners :invalid_node, node.invalid_reason.to_hash
        end
      end
      ct = nodes.seen_count
      case ct
      when 0
        call_digraph_listeners :info, "found no nodes #{ nodes.search.phrasal_noun_modifier }"
      when 1
        # ok
      else
        call_digraph_listeners :info, "found #{ ct } nodes #{ nodes.search.phrasal_noun_modifier}"
      end
      nil
    end
  end
end
