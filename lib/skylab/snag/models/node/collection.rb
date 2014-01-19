module Skylab::Snag

  class Models::Node::Collection

    include Snag::Core::SubClient::InstanceMethods

    def add message, do_prepend_open_tag, dry_run, verbose_x, new_node=nil
      r = false
      begin
        node = Models::Node::Controller.new request_client
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
        res = find( 1, [ :identifier_ref, node_ref ] ) or break
        fly = res.to_a.first      # just have faith in the system
        if ! fly
          not_found ||= -> nr do
            error "there is no node with the identifier #{ ick nr }"
          end
          break( res = not_found[ node_ref ] )
        end
        res = Models::Node::Controller.new self, fly
      end while nil
      res
    end

    def find max_count, query_sexp
      res = false
      begin
        flyweight = node_flyweight

        search = Models::Node::Search.new_valid self, max_count, query_sexp
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

    attr_reader :manifest # used in actions for now!

  private

    def initialize request_client, manifest
      @node_flyweight = nil
      @manifest = manifest
      super request_client
    end

    def node_flyweight
      @node_flyweight ||= begin
        Models::Node::Flyweight.new self, @manifest.pathname
      end
    end

    date_format = '%Y-%m-%d'

    define_method :todays_date do
      Snag::Library_::DateTime.now.strftime date_format
    end

    def my_callbacks_a
      @my_callbacks_a ||= [ :escape_path_p, method( :escape_path ),
        :error_p, method( :error ), :info_p, method( :info ),
        :raw_info_p, method( :on_raw_info ) ]
    end

    def on_raw_info raw_info
      @request_client.send :emit, :raw_info, raw_info  # #todo
      nil
    end
  end
end
