module Skylab::Snag
  class Models::Node::Search
    include Snag::Core::SubClient::InstanceMethods

    def self.new_valid request_client, last, query_sexp
      o = new request_client, last, query_sexp
      o.valid
    end

    positive_integer_rx = %r{\A\d+\z}

    define_method :last= do |num_s|
      if num_s
        if positive_integer_rx =~ num_s
          @counter = 0
          @last = num_s.to_i
        else
          error "must look like integer: #{ num_s }"
        end
      else
        @last = @counter = nil
      end
      num_s
    end

    def match? node
      b = @query.match? node
      if @counter and b
        if ( @counter += 1 ) >= @last
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
        if ! a.detect { |x| ! x }
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

    class Query_Node_::HasTag
      def self.new_valid request_client, sexp
        tag = sexp[1]
        if Models::Tag.rx =~ tag
          new request_client, tag
        else
          request_client.send :error, "tag must be composed of 'a-z' - #{
            }invalid tag name: #{ tag }"
          false
        end
      end
      def match? node
        @tag_rx =~ node.first_line_body or
        if node.extra_lines_count > 0
          node.extra_lines.index { |x| @tag_rx =~ x }
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

    def initialize emitter, last, query_sexp
      _snag_sub_client_init! emitter
      @counter = nil
      @last = nil
      self.last = last if last
      @query = Query_Node_.new_valid self, query_sexp
    end
  end
end
