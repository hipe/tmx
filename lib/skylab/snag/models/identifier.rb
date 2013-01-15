module Skylab::Snag
  class Models::Identifier < ::Struct.new :prefix, :body, :integer_string

    def self.create_rendered_string int, node_number_digits
      "[##{ "%0#{ node_number_digits }d" % int }]"
    end

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
  end

  module Models::Identifier::Events
  end

  class Models::Identifier::Events::Invalid < Snag::Model::Event.new :mixed
    build_message -> do
      "invalid identifer name #{ ick mixed } - full valid tag: #{
      }\"[#foo-001.2.3]\", equivalent to: \"001.2.3\" #{
      }(prefixes ignored), \"001\" matches the superset"
    end
  end

  class Models::Identifier::Events::Prefix_Ignored <
    Snag::Model::Event.new :identifier

    build_message -> do
      "prefixes are ignored currently - #{ ick identifier.prefix }"
    end
  end
end
