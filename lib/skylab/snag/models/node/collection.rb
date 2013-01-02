module Skylab::Snag
  class Models::Node::Collection
    include Snag::Core::SubClient::InstanceMethods

    add_struct = ::Struct.new :message, :dry_run, :verbose

    define_method :add do |param_h| # called by api action(s)
      res = false
      begin
        p = add_struct.new
        param_h.each { |k, v| p[k] = v } # validates names
        res = manifest.add_node do |o|
          o.date = todays_date
          o.dry_run = p.dry_run
          o.error = -> x { error x }
          o.escape_path = -> x { escape_path x }
          o.info = -> x { info x }
          o.message = p.message
          o.verbose = p.verbose
        end
      end while nil
      res
    end


    def find search_param_h       # called by api action(s)
      res = false
      begin
        flyweight = node_flyweight
        search = Models::Node::Search.build self, search_param_h
        break if ! search

        enum = Models::Node::Enumerator.new do |y|
          enu = manifest.build_enum flyweight, -> m { error m }, -> m { info m}

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


#    def numbers &block
#      fail 'wat'
#      with_manifest do |o|
#        o.numbers( &block )
#      end
#    end
#


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
        fw = Models::Node.build_flyweight self, @manifest.pathname
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
