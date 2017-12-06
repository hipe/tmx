# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownUnparseMagnetics_::Delimiter_via_String < Common_::Dyadic

    # the surface forms that delimiters take is (for our purposes)
    # unlimited, however there is a finite set of delimiter categories
    # whose membership we must determine for the particluar delimiter,
    # for reasons.
    #
    # mainly, in implementation of our #spot2.1 optimistic escaping, we
    # need to know exactly what character or characters we need to worry
    # about escaping.
    #
    # this isn't purely a function of the accompanying `node_type` of node
    # that holds the delimiter. so for example, a `dstr` can be delimited
    # with a double quote `"foo"` or something fancy like `%(foo)`. the
    # respective escaping policies that correspond to these delimiters are
    # different.
    #
    # likewise this isn't purely a function of the delimiter used because,
    # for example, the open curly bracket `{` has different implications for
    # optimistic escaping depending on whether it delimits a hash or a block.
    #
    # in all of these four cases, the implied escaping policy is decidedly
    # different; and knowing the difference is at the heart of escaping
    # theory.
    #
    # as such, we take a two step approach: first, the set of all possible
    # delimiters is reduced by the `node_type`. then we resolve which
    # delimiter is used using expectations determined by the node type.
    #
    # what we are left with is a fully qualified, parsed delimiter that
    # knows its deep semantic associations.
    #
    # :#spot2.3

    # #open [#007.U] is the idea that we could turn this into a much richer
    # injection point that would free up some of the structural redundancy
    # with the main consumer of the below symbolic taxonomy .. whew!

    # -

      def initialize str, node_type
        @scn = Home_.lib_.string_scanner.new str
        @node_type = node_type
      end

      DO_ = 'do'
      OCTOTHORP_ = '#'
      OPEN_CURLY_BRACKET_ = '{'
      OPEN_PARENTHESIS_ = '('
      OPEN_SQUARE_BRACKET_ = '['
      PERCENT_ = '%'
      PIPE_ = '|'

      -> do
        same_singleton = {
          singleton: true,
        };

        same_percent = {
          method: :__percent,
        };
        same_double_quot = same_singleton

        THESE___ = {

          # -- blocks and similar

          block: {

            regexp_for_scanning: ::Regexp.new( <<-O, ::Regexp::EXTENDED ),
              [#{
              }\\#{ OPEN_CURLY_BRACKET_ }#{
              }]
              |
              #{ DO_ }
            O

            mode_via_token: {
              DO_ => {
                simply: :BLOCK_DO_END,
              },
              OPEN_CURLY_BRACKET_ => {
                simply: :block_open_curly_bracket,
              }
            },
          },

          begin: {

            regexp_for_scanning: ::Regexp.new( <<-O, ::Regexp::EXTENDED ),
              [#{
              }#{ OPEN_PARENTHESIS_ }#{  # #coverpoint6.4
              }#{ OCTOTHORP_ }#{
              }]
            O

            mode_via_token: {
              OCTOTHORP_ => {  # (escaping within strings and regexps)
                method: :__octothorp,
              },
              OPEN_PARENTHESIS_ => {
                simply: :BEGIN_CHA_CHA,
              },
            },
          },

          # -- near calls: args

          args: {
            regexp_for_scanning: ::Regexp.new( <<-O, ::Regexp::EXTENDED ),
              [#{
              }#{ OPEN_PARENTHESIS_ }#{  # #coverpoint3.7
              }#{ PIPE_ }#{  # #coverpoint3.9
              }]
            O

            mode_via_token: {

              OPEN_PARENTHESIS_ => {
                simply: :ARGUMENT_LIST,
              },

              PIPE_ => {
                singleton: true,
              },
            },
          },

          mlhs: {

            regexp_for_scanning: ::Regexp.new( <<-O, ::Regexp::EXTENDED ),
              [#{
              }#{ OPEN_PARENTHESIS_ }#{  # #coverpoint3.7 (also)
              }]
            O

            mode_via_token: {

              OPEN_PARENTHESIS_ => {
                simply: :MLHS_GROUP,
              },
            },
          },

          # -- literals: hash then array

          hash: {

            regexp_for_scanning: ::Regexp.new( <<-O, ::Regexp::EXTENDED ),
              [#{
              }\\#{ OPEN_CURLY_BRACKET_ }#{
              }]
            O

            mode_via_token: {
              OPEN_CURLY_BRACKET_ => {
                simply: :hash_open_curly_bracket,
              }
            }
          },

          array: {

            regexp_for_scanning: ::Regexp.new( <<-O, ::Regexp::EXTENDED ),
              [#{
              }\\#{ OPEN_SQUARE_BRACKET_ }#{
              }#{ PERCENT_ }#{
              }]
            O

            mode_via_token: {

              OPEN_SQUARE_BRACKET_ => {
                simply: :ARRAY_OPEN_SQUARE_BRACKET,  # not seen anywhere else
              },

              PERCENT_ => same_percent,
            },

            huggers: {
              'i' => :__hugged_symbols,
              'w' => :__hugged_words,
            },
          },

          # -- literals: string-ish terminals

          regexp: {

            regexp_for_scanning: ::Regexp.new( <<-O, ::Regexp::EXTENDED ),
              [#{
              }#{ FORWARD_SLASH_ }#{
              }#{ PERCENT_ }#{
              }]
            O

            mode_via_token: {
              FORWARD_SLASH_ => same_singleton,
              PERCENT_ => same_percent,
            },

            huggers: {
              'r' => :__hugged_regexp,  # regex
            },
          },

          xstr: {
            regexp_for_scanning: /#{ BACKTICK_ }/,

            mode_via_token: {
              BACKTICK_ => same_double_quot,
            },
            huggers_NOT_YET_COVERED: {
              'x' => nil,  # shell comm
            }
          },

          dstr: {

            regexp_for_scanning: ::Regexp.new( <<-O, ::Regexp::EXTENDED ),
              [#{
              }#{ DOUBLE_QUOTE_ }#{
              }]
            O

            mode_via_token: {
              DOUBLE_QUOTE_ => same_double_quot,
            },
          },

          str: {

            regexp_for_scanning: ::Regexp.new( <<-O, ::Regexp::EXTENDED ),
              [#{
              }#{ DOUBLE_QUOTE_ }#{
              }#{ PERCENT_ }#{
              }#{ SINGLE_QUOTE_ }#{
              }]
            O

            mode_via_token: {

              PERCENT_ => same_percent,

              DOUBLE_QUOTE_ => same_double_quot,

              SINGLE_QUOTE_ => same_singleton,
            },

            huggers_NOT_YET_COVERED: {
              'q' => nil,  # single quoted string
            },
          },

          sym: {  # #coverpoint3.5 #coverpoint6.3

            regexp_for_scanning: ::Regexp.new( <<-O, ::Regexp::EXTENDED ),
              [#{
              }#{ COLON_ }#{
              }]
            O

            mode_via_token: {

              COLON_ => {
                method: :__symbol_craziness,
              },
            },

            huggers_NOT_YET_COVERED: {
              's' => nil,  # symbol
            },
          },
        }
      end.call

      def execute

        __init_mode_and_cetera

        m = @_behavior[ :method ]
        if m
          send m
        else
          __execute_normally
        end
      end

      def __init_mode_and_cetera

        @_node_type = THESE___[ @node_type ]
        if ! @_node_type
          investigate ; exit 0
        end

        key_s = @scn.scan @_node_type.fetch :regexp_for_scanning

        if ! key_s
          investigate
          raise COVER_ME, "do this: \"#{ @scn.peek 10 } [..]\""
        end
        @_delimiter_head = key_s.freeze
        @_behavior = @_node_type.fetch( :mode_via_token ).fetch key_s

        if @_behavior[ :stop_here ]
          investigate ; exit 0
        end
      end

      def __percent

        char = @scn.scan %r([a-z]+)i
        if char
          normal_s = char.downcase
          m = @_node_type.fetch( :huggers ).fetch normal_s
          if ! m
            self._COVER_ME__readme__
            # it's important that you do the escaping right with close
            # supervision. for whatever the kind of thing it is, you have
            # to give it a category name and follow it all the way through.
          end
          send m
        else
          :str == @node_type || sanity  # for *NOW* allow an earmark
          _finish_as_percenty_hugger :string_fellow
        end
      end

      def __symbol_craziness
        # :foo, :'foo bar', :"foo bar"  REMAINING: %s(foo bar)
        if @scn.eos?
          _finish_simply :ideal_literal_symbol
        else
          char = @scn.getch
          @scn.eos? || sanity
          _ = case char
          when SINGLE_QUOTE_ ; :symbol_looks_like_single_quoted_string
          when DOUBLE_QUOTE_ ; :symbol_looks_like_double_quoted_string
          else ; no end
          _finish_simply _
        end
      end

      def __hugged_words
        _finish_as_percenty_hugger :word_list
      end

      def __hugged_symbols
        _finish_as_percenty_hugger :symbol_list
      end

      def __hugged_regexp
        _finish_as_percenty_hugger :specially_delimited_regexp
      end

      def _finish_as_percenty_hugger sym
        _resolve_closing_delimiter_character_and_cetera
        _finish_with_two_categories sym, THIS_IMPORTANT_THING__
      end

      def _resolve_closing_delimiter_character_and_cetera
        char = @scn.getch
        char || sanity
        complement = PAIRS___[ char ]
        if complement
          @IS_HUGGER = true
          @closing_delimiter_character = complement
        else
          @closing_delimiter_character = char.freeze
        end
      end

      PAIRS___ = {
        '(' => ')',
        OPEN_CURLY_BRACKET_ => '}',
        '[' => ']',
        '<' => '>',
      }

      def __octothorp

        char = @scn.peek 1
        OPEN_CURLY_BRACKET_ == char || sanity
        @scn.pos += 1
        _finish_simply :STRING_INTERPOLATION_BEGINNING  # never seen ..
      end

      def __execute_normally
        sym = @_behavior[ :simply ]
        if sym
          _finish_simply sym
        elsif @_behavior[ :singleton ]
          @delimiter_category_symbol = :singleton_delimiter
          @delimiter_subcategory_value = :_delimiter_head
          _finish
        end
      end

      def _finish_with_two_categories sub_cat_sym, cat_sym
        @__subcategory_symbol = sub_cat_sym
        @delimiter_subcategory_value = :__subcategory_symbol
        @delimiter_category_symbol = cat_sym
        _finish
      end

      def _finish_simply sym
        @delimiter_category_symbol = sym
        @delimiter_subcategory_value = :__nothing
        _finish
      end

      def _finish
        if ! @scn.eos?
          investigate ; exit 0
        end
        remove_instance_variable :@_behavior
        remove_instance_variable :@scn
        freeze
      end

      def delimiter_subcategory_value
        send @delimiter_subcategory_value
      end

      attr_reader(
        :closing_delimiter_character,
        :delimiter_category_symbol,
        :_delimiter_head,
        :node_type,
        :__subcategory_symbol,
      )

      def __nothing
        NOTHING_
      end
    # -

    # ==

    Default_delimiter_for_hash = Lazy_.call do  # :#coverpoint6.3:

      # symbols that exist in `{ hashes: like, this: nil }` are (1) string-
      # ish terminals as all symbols are. but imagine when the hash is
      # `frob like: this` (like named arguments of a method call). still
      # in these cases we need an escaping policy to be (5) inherited down,
      # even though there are no actual delimiters present. yes this reveals
      # a hole in our model. hackishly we handle this like so:

      CrazyTownUnparseMagnetics_::Delimiter_via_String[ '{', :hash ]
    end

    # ==

    module ONE_FOR_HEREDOC ; class << self

      def delimiter_category_symbol
        :pretend_delimiter_for_heredoc
      end

      def delimiter_subcategory_value
        NOTHING_
      end
    end ; end

    # ==

    THIS_IMPORTANT_THING__ = :percenty_hugger
      # currently this is used for cha cha

    # ==
    # ==
  end
end
# #history-A.2: refactor to "federate" into node-type specifics
# #born.
