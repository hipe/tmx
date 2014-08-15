module Skylab::Snag

  class Models::Node::Collection__

    include Snag_::Core::SubClient::InstanceMethods

    def initialize manifest, client
      @manifest = manifest
      @node_flyweight = nil
      super client
    end

    attr_reader :manifest  # used in actions for now

    def add message, do_prepend_open_tag, dry_run, verbose_x, new_node=nil
      r = false
      begin
        node = Models::Node.build_controller request_client
        # node.date_string = todays_date   # [#058] #open
        node.message = message
        node.do_prepend_open_tag = do_prepend_open_tag
        r = node.is_valid or break
        r = manifest.add_node_notify node, * my_callbacks_a,
          :is_dry_run, dry_run, :verbose_x, verbose_x
        r and new_node[ node ]
      end while nil
      r
    end

    def changed node, is_dry_run, verbose_x
      manifest.change_node_notify node, * my_callbacks_a,
        :is_dry_run, is_dry_run, :verbose_x, verbose_x
    end

    def fetch_node node_ref, not_found=nil
      @not_found_p = nil
      @q = build_query [ :identifier_ref, node_ref ], A_COUNT_OF_ONE__
      @q and via_query_fetch_node
    end
  private
    def via_query_fetch_node
      nodes = reduce_all_nodes_via_query @q
      node = nodes.gets
      if node
        Node_.build_controller node, self
      else
        when_not_found
      end
    end
    A_COUNT_OF_ONE__ = 1

    def when_not_found
      p = @not_found_p ; q = @q
      ev = Snag_::Model_::Event.inline :node_not_found, :query, q do |y, o|
        y << "there is no node #{ o.query.phrasal_noun_modifier }"
      end
      if p
        p[ ev ]
      else
        error_event ev
      end
    end
  public

    def build_query query_sexp, max_count
      Node_.build_valid_query query_sexp, max_count, self
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

  private

    def node_flyweight
      @node_flyweight ||= Models::Node.build_flyweight
    end

    date_format = '%Y-%m-%d'

    define_method :todays_date do
      Snag_::Library_::DateTime.now.strftime date_format
    end

    def my_callbacks_a
      @my_callbacks_a ||= [ :escape_path_p, method( :escape_path ),
        :error_event_p, method( :error_event ),
        :info_event_p, method( :info_event ),
        :raw_info_p, method( :on_raw_info ) ]
    end

    def on_raw_info raw_info
      @request_client.send_to_listener :raw_info, raw_info
      nil
    end

    Node_ = Models::Node
  end
end
