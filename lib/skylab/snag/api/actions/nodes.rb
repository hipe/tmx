module Skylab::Snag
  module API::Actions::Nodes
    # gets sexed
  end

  class API::Actions::Nodes::Add < API::Action

    inflection.inflect.noun :singular

    attribute :do_prepend_open_tag, default: false
    attribute :dry_run
    attribute :message,          :required => true
    attribute :verbose

    emits :all, :error => :all, :info => :all, :payload => :all

  protected

    def execute
      nodes.add message,
        do_prepend_open_tag,
        dry_run,
        verbose
    end
  end


  class API::Actions::Nodes::Reduce < API::Action

    inflection.inflect.noun :plural

    attribute :all
    attribute :identifier
    attribute :max_count
    attribute :query_sexp
    attribute :verbose, default: true

    emits payload: :all,
             info: :all,
            error: :all,
     invalid_node: :info  # hm..

  protected

    def execute
      res = nil
      begin
        break if ! nodes # we need them we want them, we want them now
        sexp = query_sexp.dup if query_sexp
        ( sexp ||= [:and] ).push [:identifier, identifier] if identifier
        if all
          if sexp
            error "sorry - it doesn't make sense to use `all` with any #{
            }other search criteria"
            break( res = false )
          else
            sexp = [:all]
          end
        end
        sexp ||= [:valid]
        found = nodes.find( max_count, sexp ) or break( res = found )
        @render_item = if verbose
          build_yamlizer
        else
          build_terse_node_renderer
        end
        res = render_nodes found
      end while nil
      res
    end

    # --*--

    def build_terse_node_renderer
      -> node do
        emit :payload, node.first_line
        if node.extra_lines_count > 0
          node.extra_lines.each do |line|
            emit :payload, line
          end
        end
        nil
      end
    end

    field_names = Snag::Models::Node::Flyweight.field_names

    define_method :build_yamlizer do
      Snag::CLI::Yamlizer.new field_names do |o|
        o.on_line do |e|
          emit :payload, e
          nil
        end
      end
    end

    def render_nodes nodes
      info "(looking at #{ escape_path manifest_pathname })"
      nodes.with_count!.each do |node|
        if node.valid?
          @render_item[ node ]
        else
          emit :invalid_node, node.invalid_reason.to_h
        end
      end
      ct = nodes.last_count
      case ct
      when 0
        emit :info, "found no nodes #{ nodes.search.phrasal_noun_modifier }"
      when 1
        # ok
      else
        emit :info, "found #{ ct } nodes #{ nodes.search.phrasal_noun_modifier}"
      end
      nil
    end
  end
end
