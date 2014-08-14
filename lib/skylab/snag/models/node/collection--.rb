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
        node.date_string = todays_date if false  # off for now
        node.message = message
        node.do_prepend_open_tag = do_prepend_open_tag
        r = node.valid or break
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
      res = nil
      begin
        res = find [ :identifier_ref, node_ref ], A_COUNT_OF_ONE__
        res or break
        fly = res.to_a.first      # just have faith in the system
        if ! fly
          not_found ||= -> nr do
            error "there is no node with the identifier #{ ick nr }"
          end
          break( res = not_found[ node_ref ] )
        end
        res = Models::Node.build_controller fly, self
      end while nil
      res
    end
    A_COUNT_OF_ONE__ = 1

    def find query_sexp, max_count
      res = false
      begin
        flyweight = node_flyweight

        search = Models::Node.build_valid_search query_sexp, max_count, self

        break if ! search

        enum = Models::Node::Enumerator.new do |y|
          enu = manifest.curry_enum :flyweight, flyweight, :error_p,
            method( :error ), :info_p, method( :info )

          enu = enu.filter! -> yy, xx do
            if search.match? xx
              yy << xx
            end
          end

          enu.each do |x|
            y << x
          end
        end
        enum.search = search
        res = enum
      end while nil
      res
    end

  private

    def node_flyweight
      @node_flyweight ||= Models::Node.build_flyweight @manifest.pathname
    end

    date_format = '%Y-%m-%d'

    define_method :todays_date do
      Snag_::Library_::DateTime.now.strftime date_format
    end

    def my_callbacks_a
      @my_callbacks_a ||= [ :escape_path_p, method( :escape_path ),
        :error_p, method( :error ), :info_p, method( :info ),
        :raw_info_p, method( :on_raw_info ) ]
    end

    def on_raw_info raw_info
      @request_client.send :call_digraph_listeners, :raw_info, raw_info  # #todo
      nil
    end
  end
end
