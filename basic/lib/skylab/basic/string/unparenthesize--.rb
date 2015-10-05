module Skylab::Snag

  module Text

    class << self

      def unparenthesize_message_string s
        Unparenthesize_message_string__[ s ]
      end
    end

    class Unparenthesize_message_string__

      Snag_::Model_::Actor[ self,
        :properties, :s ]

      def execute
        md = UNPARENTHESIZE_RX__.match @s
        md ? [ md[ :open ], md[ :body ], md[ :close ] ] : [ nil, @s, nil ]
      end

      _P = '.?!:'
      _P_ = "[#{ _P }]*"
      UNPARENTHESIZE_RX__ = /\A(?:
        (?<open> \( )  (?<body> .*[^#{ _P }] )?  (?<close> #{ _P_ }\) ) |
        (?<open> \[ )  (?<body> .*[^#{ _P }] )?  (?<close> #{ _P_ }\] ) |
        (?<open>  < )  (?<body> .*[^#{ _P }] )?  (?<close> #{ _P_ }>  ) |
                       (?<body> .+[^#{ _P }] )   (?<close> [#{ _P }]+ )
      )\z/x
    end
  end
end
