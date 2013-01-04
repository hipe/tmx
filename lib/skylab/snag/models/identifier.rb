module Skylab::Snag
  class Models::Identifier < ::Struct.new :prefix, :identifier, :integer_string

    rx = /
      \A
      \[?\#?                                   # (we can ignore these for you)
      (?:  (?<prefix> [a-z]+ ) - )?            # maybe it starts with a prefix
      (?<identifier>                           # and then has the identifier
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
        o = Models::Identifier.new md[:prefix], md[:identifier], md[:integer]
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
