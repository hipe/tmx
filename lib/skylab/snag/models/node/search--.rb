module Skylab::Snag

  class Models::Node::Search__

    include Snag_::Core::SubClient::InstanceMethods

    def self.new_valid query_sexp, max_count, client
      o = new query_sexp, max_count, client
      o.valid
    end

    def initialize query_sexp, max_count, client
      @counter = nil
      super client  # before next line
      if max_count
        self.max_count = max_count
      else
        @max_count = nil
      end
      @query = Query_Nodes_.new_valid query_sexp, self
    end

    def valid
      error_count.zero? ? self : UNABLE_
    end

    def max_count= integer_ref
      begin
        if integer_ref
          if ::Fixnum === integer_ref
            integer = integer_ref
          elsif POSITIVE_INTEGER_RX__ =~ integer_ref
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
    POSITIVE_INTEGER_RX__ = %r{\A\d+\z}

    def phrasal_noun_modifier
      "with #{ @query.phrase }"
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

    module Query_Nodes_  # #borrow-indent

    def self.new_valid query_sexp, client
      _cls = Autoloader_.const_reduce [ query_sexp.first ], self
      _cls.new_valid query_sexp, client
    end

    class And

      def self.new_valid query_sexp, client
        a = query_sexp[ 1 .. -1 ].map do |x|
          klass = Autoloader_.const_reduce [ x.first ], Query_Nodes_
          klass.new_valid x, client
        end
        if ! a.index { |x| ! x }
          if a.length < 2
            rs = a.first
          else
            rs = new a
          end
        end
        rs
      end

      def initialize a
        @elements = a
      end

      def phrase
        @elements.map( & :phrase ).join ' and '
      end

      def match? node
        ! detect { |x| ! x.match?( node ) }
      end
    end

    class All

      def self.new_valid _sexp, _client
        ALL__
      end

      def initialize
        freeze
      end

      ALL__ = new

      def phrase
        PHRASE__
      end
      PHRASE__ = "either validity or no validity".freeze

      def match? node
        true
      end
    end

    class HasTag

      def self.new_valid sexp, client
        tag_i = sexp.fetch 1
        tag_i_ = Models::Tag.normalize_stem_i tag_i,
          -> ev do
            client.error ev.render_under client
          end
        tag_i_ and new tag_i_
      end

      def initialize valid_tag_stem_i
        @tag_rx = /(?:^|[[:space:]])##{ ::Regexp.escape valid_tag_stem_i }\b/
        @valid_tag_stem_i = valid_tag_stem_i
      end

      def phrase
        "tag ##{ @valid_tag_stem_i }"
      end

      def match? node
        if node.valid
          @tag_rx =~ node.first_line_body or
          if node.extra_lines_count > 0
            node.extra_line_a.index { |x| @tag_rx =~ x }
          end
        end
      end
    end

    class IdentifierRef

      def self.new_valid sexp, client
        identifier_body = sexp[1]  # prefixes might bite [#019]
        normalized = Models::Identifier.normalize identifier_body,
          -> invalid do
            client.send :error, ( invalid.render_under client )
          end,
          -> info do
            client.send :info, ( info.render_under client )
          end
        normalized and new normalized
      end

      def initialize identifier_struct
        @identifier = identifier_struct
        @identifier_rx = /\A#{ ::Regexp.escape @identifier.body }/  # [#019]
      end

      def phrase
        "identifier starting with \"#{ @identifier.body }\""
      end

      def match? node
        if node.valid
          @identifier_rx =~ node.identifier_body
        end
      end
    end

    class Valid

      def self.new_valid _sexp, _client
        VALID__
      end

      def initialize
        freeze
      end

      VALID__ = new

      def phrase
        PHRASE__
      end
      PHRASE__ = 'validity'.freeze

      def match? node
        node.valid
      end
    end
    end # payback-indent
  end
end
