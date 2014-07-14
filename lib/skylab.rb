module Skylab  # Welcome! :D

  # ~ facilities for bootstrapping subsystems

  require 'pathname'

  here = ::Pathname.new __FILE__

  $:.include?( _ = here.join('..').to_s ) or $:.unshift _

  dir_pathname = here.sub_ext ''

  define_singleton_method :dir_pathname do dir_pathname end

  module Autoloader

    EXTNAME = '.rb'.freeze

    module FUN

      module Constantize

        p = -> path_x do
          path_x.to_s.gsub( BLACK_RX__, EMPTY_STRING__ ).
            split( FILE_SEP_, -1 ).
              map( & Sanitized_file ) * CONST_SEP__
        end ; define_singleton_method :to_proc do p end
        define_singleton_method :[], p

        BLACK_RX__ = %r{ #{ ::Regexp.escape EXTNAME }\z |
          (?<=/)/+ | (?<=[-_ ])[-_ ]+ | [^-_ /a-z0-9]+ }ix

        EMPTY_STRING__ = ''.freeze
        CONST_SEP__ = '::'.freeze

        Sanitized_file = -> part_s do
          part_s.gsub( PART_RX__ ).each do
            # for each parts (still being attached to any separator)
            const, sep, is_last = $~.captures
            const.gsub!( LETTER_AFTER_DIGIT_RX__ ) { $1.upcase }  # "99x"->"99X"
            sep and _sep = Resolve_any_term_separator__[ const, sep, is_last ]
            "#{ const }#{ _sep }"
          end
        end
        PART_RX__ = / (?<const>[^-_ ]+) (?<sep>[-_ ]+ (?<is_last>\z) ?)? /x
        LETTER_AFTER_DIGIT_RX__ = /(?<=[0-9]|\A)([a-z])/

        Resolve_any_term_separator__ = -> const, sep, is_last do
          if is_last
            CONST_PART_SEP_ * sep.length  # foo-- => Foo__
          elsif 2 > const.length
            CONST_PART_SEP_  # c-style => C_Style, foo-bar => FooBar, x- => X_
          end
        end
      end

      CONST_PART_SEP_ = '_'.freeze
      FILE_SEP_ = '/'.freeze

      module Methodize
        p = -> str do
          str.to_s.gsub( PART_RX__ ) { "#{ SEP__ }#{ $1 || $2 }" }.
            gsub( BLACK_RX__, SEP__ ).downcase.intern
        end ; define_singleton_method :to_proc do p end
        define_singleton_method :[], p
        PART_RX__ = /(?<=[a-z])([A-Z])|(?<=[A-Z])([A-Z][a-z])/
        SEP__ = '_'.freeze
        BLACK_RX__ = /[^a-z0-9]+/i
      end

      module Pathify
        p = -> const_x do
          const_x.to_s.gsub( PART_RX__ ) { "-#{ $1 || $2 }" }.
            gsub( CONST_PART_SEP_, PART_SEP__ ).downcase
        end ; define_singleton_method :to_proc do p end
        define_singleton_method :[], p
        PART_RX__ = /(?<=[a-z])([A-Z])|(?<=[A-Z])([A-Z][a-rt-z])/
        PART_SEP__ = '-'.freeze
      end
    end

    CALLFRAME_PATH_RX = /^(?<path>.+)(?=:\d+:in[ ]`)/x  # everywhere this is used [#mh-044]

    Guess_dir_ = -> do

      tok_rx = %r{\A(?:(?<rest>(?:(?!=::).)+)::)?(?:::)?(?<curr>[^:]+)\z}

      pathify = FUN::Pathify

      tokenizer = -> s do  # "A::B::C" => "c", "b", "a", nil
        -> { m = tok_rx.match( s ) and ( s, x = m.captures ) and pathify[ x ] }
      end

      path_rx =
        %r{\A(?:(?:(?<rest>|.*[^/])/+)?(?<peek>[^/]*)/+)?(?<curr>[^/]*)/*\z}

      -> const, path, error do
        head, *look = path_rx.match( path ).values_at 1..3
        look.compact!
        t = found = nil ; tail = [] ; f = tokenizer[ const ]
        tail.push t while t = f.call and ! found = look.index( t )
        if found
          [ * [head].compact, * look[0..found], * tail.reverse ].join( '/' )
        else
          error[ "failed to infer path for #{ const.inspect } from #{ path }" ]
        end
      end
    end.call
  end
end
