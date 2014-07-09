module Skylab::Snag

  class Models::Node::Search

    include Snag_::Core::SubClient::InstanceMethods

    def self.new_valid request_client, max_count, query_sexp
      o = new request_client, max_count, query_sexp
      o.valid
    end

    positive_integer_rx = %r{\A\d+\z}

    define_method :max_count= do |integer_ref|
      begin
        if integer_ref
          if ::Fixnum === integer_ref
            integer = integer_ref
          elsif positive_integer_rx =~ integer_ref
            integer = integer_ref.to_i
          else
            error "must look like integer: #{ integer_ref }"
            break
          end
          @counter = 0
          @max_count = integer
        else
          @counter = nil
          @max_count = nil
        end
      end while nil
      integer_ref
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

  private

    module Query_Nodes_
      def self.new_valid request_client, query_sexp
        klass = Autoloader_.const_reduce [ query_sexp.first ], self
        klass.new_valid request_client, query_sexp
      end
    end

    class Query_Nodes_::And
      def self.new_valid request_client, query_sexp
        a = query_sexp[ 1 .. -1 ].map do |x|
          klass = Autoloader_.const_reduce [ x.first ], Query_Nodes_
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
    private
      def initialize request_client, a
        @elements = a
      end
    end

    # --*--

    class Query_Nodes_::All
      def self.new_valid request_client, sexp
        new request_client
      end
      def match? node
        true
      end
      def phrase
        "either validity or no validity"
      end
    private
      def initialize request_client
      end
    end

    class Query_Nodes_::HasTag
      def self.new_valid request_client, sexp
        tag = sexp[1]
        normalized_tag_name = Models::Tag.normalize tag,
          -> invalid do
            request_client.send :error, ( invalid.render_under request_client )
          end
        if normalized_tag_name
          new request_client, normalized_tag_name
        else
          normalized_tag_name
        end
      end
      def match? node
        if node.valid
          @tag_rx =~ node.first_line_body or
          if node.extra_lines_count > 0
            node.extra_line_a.index { |x| @tag_rx =~ x }
          end
        end
      end
      def phrase
        "tag ##{ @tag }"
      end
    private
      def initialize request_client, tag
        @tag = tag
        @tag_rx = /(?:^|[[:space:]])##{ ::Regexp.escape tag }\b/
      end
    end

    class Query_Nodes_::IdentifierRef
      def self.new_valid request_client, sexp
        identifier_body = sexp[1] # prefixes might bite [#019]
        normalized = Models::Identifier.normalize identifier_body,
          -> invalid do
            request_client.send :error, ( invalid.render_under request_client )
          end,
          -> info do
            request_client.send :info, ( info.render_under request_client )
          end
        normalized ? new( request_client, normalized ) : normalized
      end
      def match? node
        if node.valid
          @identifier_rx =~ node.identifier_body
        end
      end
      def phrase
        "identifier starting with \"#{ @identifier.body }\""
      end
    private
      def initialize request_client, identifier_struct
        @identifier = identifier_struct
        @identifier_rx = /\A#{ ::Regexp.escape @identifier.body }/ # [#019]
      end
    end

    class Query_Nodes_::Valid
      def self.new_valid *a
        new( *a )
      end
      def match? node
        node.valid
      end
      def phrase
        'validity'
      end
    private
      def initialize request_client, _
      end
    end

    def initialize emitter, max_count, query_sexp
      super emitter
      @counter = nil
      @max_count = nil
      self.max_count = max_count if max_count
      @query = Query_Nodes_.new_valid self, query_sexp
      if ! @query && 0 == error_count          # catches some thing earlier..
        error "failed to build query for one weird old reason" # last resort
      end
    end
  end
end
