module Skylab::Snag

  class Models::Identifier

    def initialize any_prefix_s, integer_s, any_suffix_s
      @prefix_s = any_prefix_s
      @integer_s = integer_s  # leading 0's maybe meaningful dep'ing on client
      @suffix_s = any_suffix_s
      freeze
    end

    attr_reader :prefix_s

    _CONTENT_RX = /
      (?: (?<prefix> [a-z]+ ) - )?
      (?<identifier_body>
        (?<integer> \d+ )
        (?:  \.  (?<suffix>  \d+  (?: \. \d+ )* ) )?
      )
    /x

    FORMAL_RX = / \[ \# #{ _CONTENT_RX.source } \] /x
    CONTENT_START_INDEX = 2  # '[#'.length
    ENDCAP_WIDTH = 1  # ']'.length
    PREFIX_SEPARATOR_WIDTH = 1  # '-'.length

    class << self
      def normalize x, error, info=nil
        md = NORMALIZING_RX__.match x.to_s
        if md
          o = new md[ :prefix ], md[ :integer ], md[ :suffix ]
          if o.prefix_s && info
            info[ Events::Prefix_Ignored.new o ]
          end
          o
        else
          _x_ = error[ Events::Invalid.new x ]
          _x_ and false
        end
      end
    end

    NORMALIZING_RX__ = / \A (?:
      #{ FORMAL_RX.source } |
      \# ? #{ _CONTENT_RX.source }
    )\z/x

    def render
      "[##{ "#{ @prefix_s }-" if @prefix_s }#{ body_s }]"
    end

    def body_s
      "#{ @integer_s }#{ ".#{ @suffix_s }" if @suffix_s }"
    end

    module Events

      Invalid = Snag_::Model_::Event.new :mixed do
        message_proc do |y, o|
          y << "invalid identifier name #{ ick o.mixed } - #{
           }rendered full identifer: #{
            }\"[#foo-001.2.3]\", equivalent to: \"001.2.3\" #{
             }(prefixes ignored), \"001\" matches the superset"
        end
      end

      Prefix_Ignored = Snag_::Model_::Event.new :identifier do
        message_proc do |y, o|
          y << "prefixes are ignored currently - #{ ick o.identifier.prefix_s }"
        end
      end
    end
  end
end
