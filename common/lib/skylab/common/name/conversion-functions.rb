module Skylab::Common

  module Name::Conversion_Functions

    sanitize_file = nil
    Constantize = -> do

      black_rx = %r{ #{ ::Regexp.escape Autoloader::EXTNAME }\z |
        (?<=/)/+ | (?<=[-_ ])[-_ ]+ | [^-_ /a-z0-9]+ }ix

      -> path_x do
        path_x.to_s.gsub( black_rx, EMPTY_S_ ).
          split( ::File::SEPARATOR, -1 ).
            map( & sanitize_file ) * CONST_SEP_
      end
    end.call

    Empty_name_for = -> do  # not a conversion function
      cache = {}
      -> x do
        if ! x
          cache.fetch x do
            en = Empty_Name___.new x
            _const = :"#{ x.inspect.upcase }_AS_EMPTY_NAME"
            const_set _const, en
            cache[ x ] = en
            en
          end
        end
      end
    end.call

    class Empty_Name___ < ::Module
      def initialize x
        @as_variegated_symbol = x
        freeze
      end
      attr_reader :as_variegated_symbol
    end

    sanitize_file = -> do

      letter_after_digit_rx = /(?<=[0-9]|\A)([a-z])/
      part_rx = / (?<const>[^-_ ]+) (?<sep>[-_ ]+ (?<is_last>\z) ?)? /x

      resolve_any_term_separator = -> const, sep, is_last do
        if is_last
          UNDERSCORE_ * sep.length  # foo-- => Foo__
        elsif 2 > const.length
          UNDERSCORE_  # c-style => C_Style, foo-bar => FooBar, x- => X_
        end
      end

      -> part_s do
        part_s.gsub( part_rx ).each do
          # for each parts (still being attached to any separator)
          const, sep, is_last = $~.captures
          const.gsub!( letter_after_digit_rx ) { $1.upcase }  # "99x"->"99X"
          sep and _sep = resolve_any_term_separator[ const, sep, is_last ]
          "#{ const }#{ _sep }"
        end
      end
    end.call

    Methodize = -> do

      black_rx = /[^a-z0-9]+/i
      part_rx = /(?<=[a-z])([A-Z])|(?<=[A-Z])([A-Z][a-z])/

      -> s do

        s_ = s.to_s.gsub part_rx do
          "#{ UNDERSCORE_ }#{ $1 || $2 }"
        end
        s_.gsub! black_rx, UNDERSCORE_
        s_.downcase!
        s_.intern
      end
    end.call

    Pathify = -> do

      part_rx = /(?<=[a-z])([A-Z])|(?<=[A-Z])([A-Z][a-rt-z])/

      -> const_x do
        const_x.to_s.gsub( part_rx ) { "-#{ $1 || $2 }" }.
          gsub( UNDERSCORE_, DASH_ ).downcase
      end
    end.call
  end
end

# #tombstone(s) : "guess dir" (one of the first "centers of the universe")
# #tombstone(s) : "pathify name"
