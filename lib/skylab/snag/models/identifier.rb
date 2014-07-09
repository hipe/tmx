module Skylab::Snag

  class Models::Identifier < ::Struct.new :prefix, :body, :integer_string

    rx = /
      \A
      \[?\#?                                   # (we can ignore these for you)
      (?:  (?<prefix> [a-z]+ ) - )?            # maybe it starts with a prefix &
      (?<identifier_body>                      # then has the identifier_body
        (?<integer> \d+ )                      # which always has an integer
        (?: \. \d+ )*                          # and maybe dewey-decimal sub-
      )                                        # parts
      \]?                                      # (ignored for you)
      \z
    /x

    define_singleton_method :normalize do |x, error, info=nil|
      md = rx.match x.to_s
      res = nil
      if md
        o = Models::Identifier.new md[:prefix],
                                   md[:identifier_body], md[:integer]
        if o.prefix && info
          info[ Models::Identifier::Events::Prefix_Ignored.new o ]
        end
        res = o
      else
        r = error[ Models::Identifier::Events::Invalid.new x ]
        res = r ? false : r
      end
      res
    end

    def self.render prefix, body
      "[##{ "#{ prefix }-" if prefix }#{ body }]"
    end

    # --*--

    def render
      self.class.render prefix, body
    end

    alias_method :to_s, :render
  end

  Models::Identifier::Events = ::Module.new

  class Models::Identifier::Events::Invalid < Snag_::Model::Event.new :mixed
    build_message -> do
      "invalid identifier name #{ ick mixed } - rendered full identifer: #{
      }\"[#foo-001.2.3]\", equivalent to: \"001.2.3\" #{
      }(prefixes ignored), \"001\" matches the superset"
    end
  end

  class Models::Identifier::Events::Prefix_Ignored <
    Snag_::Model::Event.new :identifier

    build_message -> do
      "prefixes are ignored currently - #{ ick identifier.prefix }"
    end
  end
end
