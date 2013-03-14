module Skylab::Snag

  class Models::Node::Collection

    include Snag::Core::SubClient::InstanceMethods

    def add message, do_prepend_open_tag, dry_run, verbose_x, new_node=nil
      res = false
      begin
        node = Models::Node::Controller.new request_client
        node.date_string = todays_date if false # off for now
        node.message = message
        node.do_prepend_open_tag = do_prepend_open_tag
        r = node.valid or break( res = r )
        res = manifest.add_node node,
          dry_run,
          verbose_x,
          method( :escape_path ),
          method( :error ),
          method( :info ),
          -> raw_info do  # let's try not to style these..
            @request_client.send :emit, :raw_info, raw_info
          end
        new_node[ node ] if res
      end while nil
      res
    end

    def changed node, dry_run, verbose_x
      manifest.change_node node, dry_run, verbose_x,
        method( :escape_path ),
        method( :error ),
        method( :info ),
        -> raw_info do
          @request_client.send :emit, :raw_info, raw_info
        end
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
          enu = manifest.build_enum flyweight, -> m { error m }, -> m { info m }

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

  protected

    def initialize request_client, manifest
      _snag_sub_client_init request_client
      @node_flyweight = nil
      @manifest = manifest
    end

    def node_flyweight
      @node_flyweight ||= begin
        Models::Node::Flyweight.new self, @manifest.pathname
      end
    end

    date_format = '%Y-%m-%d'

    define_method :todays_date do
      Snag::Services::DateTime.now.strftime date_format
    end
  end
end
