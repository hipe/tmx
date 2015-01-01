module Skylab::Snag

  class Models::Node::Query__

    class << self

      def normal query_sexp, max_count, delegate
        o = new query_sexp, max_count, delegate
        o.valid
      end

      private :new
    end

    def initialize query_sexp, max_count, delegate
      @counter = nil
      @error_count = 0
      @falseish = UNABLE_
      @delegate = delegate  # before below
      if max_count
        self.max_count = max_count
      else
        @max_count = nil
      end
      qry = Query_Nodes_.normal query_sexp, delegate
      if qry
        @query = qry
      else
        @error_count += 1
      end
    end

    attr_reader :max_count

    def valid
      is_valid ? self : UNABLE_
    end

    def is_valid
      @error_count.zero?
    end

    def max_count= integer_x
      if integer_x
        x = rslv_some_valid_max_count integer_x
        if x
          @counter = 0 ; @max_count = x
        end
      else
        @counter = @max_count = nil
      end
      integer_x
    end
  private
    def rslv_some_valid_max_count x
      if x.respond_to? :integer? and x.integer?
        x
      elsif POSITIVE_INTEGER_RX__ =~ x
        x.to_i
      else
        send_error_string say_not_integer x
        UNABLE_
      end
    end
    POSITIVE_INTEGER_RX__ = %r{\A\d+\z}
    def say_not_integer x
      "must look like integer: #{ x }"
    end
  public

    def phrasal_noun_modifier
      "with #{ @query.phrase }"
    end

    def match? node
      ok = @query.match? node
      if @counter and ok
        @counter += 1
      end
      ok
    end

    def it_is_time_to_stop
      @max_count == @counter
    end

  private
    def send_error_string s
      @error_count += 1
      @delegate.receive_error_string s
    end

    module Query_Nodes_  # #borrow-indent

    def self.normal query_sexp, delegate
      _cls = Autoloader_.const_reduce [ query_sexp.first ], self
      _cls.normal query_sexp, delegate
    end

    class And

      def self.normal query_sexp, delegate
        a = query_sexp[ 1 .. -1 ].map do |x|
          klass = Autoloader_.const_reduce [ x.first ], Query_Nodes_
          klass.normal x, delegate
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

      def self.normal _sexp, _delegate
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

      def self.normal sexp, delegate
        tag_i = sexp.fetch 1
        tag_i_ = Models::Tag.normalize_stem_i tag_i,
          -> ev do
            delegate.receive_error_event ev
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
        if node.is_valid
          @tag_rx =~ node.first_line_body or
          if node.extra_lines_count > 0
            node.extra_line_a.index { |x| @tag_rx =~ x }
          end
        end
      end
    end

    class IdentifierRef

      class << self

        def normal sexp, delegate
          identifier_body = sexp[ 1 ]  # prefixes might bite [#019]
          normal = Models::Identifier.normal identifier_body, delegate
          normal and new normal
        end
      end

      def initialize identifier_o
        @identifier = identifier_o
        @identifier_rx = /\A#{ ::Regexp.escape @identifier.body_s }/  # [#019]
      end

      def phrase
        "identifier starting with \"#{ @identifier.body_s }\""
      end

      def match? node
        if node.is_valid
          @identifier_rx =~ node.identifier_body
        end
      end
    end

    class Valid

      def self.normal _sexp, _delegate
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
        node.is_valid
      end
    end
    end # payback-indent
  end
end
