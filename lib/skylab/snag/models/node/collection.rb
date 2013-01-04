module Skylab::Snag
  class Models::Node::Collection
    include Snag::Core::SubClient::InstanceMethods

    def add message, do_prepend_open_tag, dry_run, verbose
      res = false
      begin
        node = Models::Node::Controller.new request_client
        node.date_string = todays_date if false # off for now
        node.message = message
        node.do_prepend_open_tag = do_prepend_open_tag
        r = node.valid or break( res = r )
        res = manifest.add_node node,
          dry_run,
          verbose,
          -> x { escape_path x },
          -> x { error x },
          -> x { info x }
      end while nil
      res
    end

    def find list, query_sexp
      res = false
      begin
        flyweight = node_flyweight
        search = Models::Node::Search.new_valid self, list, query_sexp
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
      _snag_sub_client_init! request_client
      @node_flyweight = nil
      @manifest = manifest
    end

    def node_flyweight
      fw = nil
      begin
        break( fw = @node_flyweight ) if @node_flyweight
        fw = Models::Node::Flyweight.new self, @manifest.pathname
        @node_flyweight = fw
      end while nil
      fw
    end


    date_format = '%Y-%m-%d'

    define_method :todays_date do
      Snag::Services::DateTime.now.strftime date_format
    end
  end
end
