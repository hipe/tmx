module Skylab::Snag

  class Models::Node::Collection__

    def initialize manifest, _API_client
      @API_client = _API_client
      @manifest = manifest
    end

    attr_reader :manifest  # used in actions for now

    def add message, do_prepend_open_tag, dry_run, verbose_x, delegate

      o = Models::Node.build_controller delegate, @API_client
      o.message = message
      o.do_prepend_open_tag = do_prepend_open_tag
      if o.is_valid
        ok = @manifest.add_node o, dry_run, verbose_x
        ok and delegate.receive_new_node( o ) || ok  # :+[#062] upgrade result
      else
        o.result_value
      end
    end

    def changed node, is_dry_run, verbose_x
      node.delegate or self._SANITY
      @manifest.change_node node, is_dry_run, verbose_x
    end

    def fetch_node node_ref, delegate
      @q = build_query [ :identifier_ref, node_ref ], A_COUNT_OF_ONE__, delegate
      @q and via_query_fetch_node delegate
    end
  private
    def via_query_fetch_node delegate
      nodes = reduce_all_nodes_via_query @q
      fly = nodes.gets
      if fly
        fly.collapse delegate, @API_client
      else
        when_not_found delegate
      end
    end
    A_COUNT_OF_ONE__ = 1

    def when_not_found delegate
      _ev = Snag_::Model_::Event.inline :node_not_found, :query, @q do |y, o|
        y << "there is no node #{ o.query.phrasal_noun_modifier }"
      end
      delegate.receive_error_event _ev
    end
  public

    def build_query query_sexp, max_count, delegate
      Node_.build_valid_query query_sexp, max_count, delegate
    end

    def reduce_all_nodes_via_query q
      scan = all.reduce_by do |node|
        q.match? node
      end
      if q.max_count
        scan = scan.stop_when do |_|
          q.it_is_time_to_stop
        end
      end
      scan
    end

    def all
      Node_.build_scan_from_lines @manifest.manifest_file.normalized_line_producer
    end

    Node_ = Models::Node
  end
end
