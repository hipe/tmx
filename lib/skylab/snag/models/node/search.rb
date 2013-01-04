module Skylab::Snag
  class Models::Node::Search
    include Snag::Core::SubClient::InstanceMethods

    def self.new_valid request_client, max_count, query_sexp
      o = new request_client, max_count, query_sexp
      o.valid
    end

    positive_integer_rx = %r{\A\d+\z}

    define_method :max_count= do |num_s|
      if num_s
        if positive_integer_rx =~ num_s
          @counter = 0
          @max_count = num_s.to_i
        else
          error "must look like integer: #{ num_s }"
        end
      else
        @max_count = @counter = nil
      end
      num_s
    end

    def match? node
      b = @query.match? node
      if @counter and b
        if ( @counter += 1 ) >= @max_count
          throw :last_item, node
        end
      end
      b
    end

    def phrasal_noun_modifier
      "with #{ @query.phrase }"
    end

    def valid
      0 == error_count ? self : false
    end

  protected

    module Query_Node_
      extend MetaHell::Boxxy
      def self.new_valid request_client, query_sexp
        klass = const_fetch query_sexp.first
        klass.new_valid request_client, query_sexp
      end
    end

    class Query_Node_::And
      def self.new_valid request_client, query_sexp
        a = query_sexp[ 1 .. -1 ].map do |x|
          klass = Query_Node_.const_fetch x.first
          klass.new_valid request_client, x
        end
        rs = nil
        if ! a.index { |x| ! x }
          if a.length < 2
            rs = a.first
          else
            rs = new request_client, a
          end
        end
        rs
      end
      def match? node
        ! detect { |x| ! x.match?( node ) }
      end
      def phrase
        @elements.map(&:phrase).join ' and '
      end
    protected
      def initialize request_client, a
        @elements = a
      end
    end

    # --*--

    class Query_Node_::All
      def self.new_valid request_client, sexp
        new request_client
      end
      def match? node
        true
      end
      def phrase
        "either validity or no validity"
      end
    protected
      def initialize request_client
      end
    end

    class Query_Node_::HasTag
      def self.new_valid request_client, sexp
        tag = sexp[1]
        normalized = Models::Tag.normalize tag,
          -> invalid do
            request_client.send :error, ( invalid.render_for request_client )
          end
        normalized ? new( request_client, normalized ) : normalized
      end
      def match? node
        if node.valid
          @tag_rx =~ node.first_line_body or
          if node.extra_lines_count > 0
            node.extra_lines.index { |x| @tag_rx =~ x }
          end
        end
      end
      def phrase
        "tag ##{ @tag }"
      end
    protected
      def initialize request_client, tag
        @tag = tag
        @tag_rx = /(?:^|[[:space:]])##{ ::Regexp.escape tag }\b/
      end
    end

    class Query_Node_::Identifier
      def self.new_valid request_client, sexp
        identifier_string = sexp[1]
        normalized = Models::Identifier.normalize identifier_string,
          -> invalid do
            request_client.send :error, ( invalid.render_for request_client )
          end,
          -> info do
            request_client.send :info, ( info.render_for request_client )
          end
        normalized ? new( request_client, normalized ) : normalized
      end
      def match? node
        if node.valid
          @identifier_rx =~ node.identifier_string
        end
      end
      def phrase
        "identifer starting with \"#{ @identifier.identifier }\""
      end
    protected
      def initialize request_client, identifier_struct
        @identifier = identifier_struct
        @identifier_rx = /\A#{ ::Regexp.escape @identifier.identifier }/
      end
    end

    class Query_Node_::Valid
      def self.new_valid *a
        new( *a )
      end
      def match? node
        node.valid
      end
      def phrase
        'validity'
      end
    protected
      def initialize request_client, _
      end
    end

    def initialize emitter, max_count, query_sexp
      _snag_sub_client_init! emitter
      @counter = nil
      @max_count = nil
      self.max_count = max_count if max_count
      @query = Query_Node_.new_valid self, query_sexp
      if ! @query && 0 == error_count          # catches some thing earlier..
        error "failed to build query for one weird old reason" # last resort
      end
    end
  end
end
