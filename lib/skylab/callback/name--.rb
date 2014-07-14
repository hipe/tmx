module Skylab::Callback

  module Name__  # legacy algorithms

    def self.at * i_a
      i_a.map( & method( :send ) )
    end

    def self.guess_dir
      GUESS_DIR_P__
    end
    GUESS_DIR_P__ = -> do

      tok_rx = %r{\A(?:(?<rest>(?:(?!=::).)+)::)?(?:::)?(?<curr>[^:]+)\z}

      tokenizer = -> s do  # "A::B::C" => "c", "b", "a", nil
        -> { m = tok_rx.match( s ) and ( s, x = m.captures ) and PATHIFY_[ x ] }
      end

      path_rx =
        %r{\A(?:(?:(?<rest>|.*[^/])/+)?(?<peek>[^/]*)/+)?(?<curr>[^/]*)/*\z}

      -> const, path, error do
        head, *look = path_rx.match( path ).values_at 1..3
        look.compact!
        t = found = nil ; tail = [] ; f = tokenizer[ const ]
        tail.push t while t = f.call and ! found = look.index( t )
        if found
          [ * [head].compact, * look[0..found], * tail.reverse ].join PATH_SEP_
        else
          error[ "failed to infer path for #{ const.inspect } from #{ path }" ]
        end
      end
    end.call
    def self.callframe_path_rx
      CALLFRAME_PATH_RX__
    end
    CALLFRAME_PATH_RX__ = /^(?<path>.+)(?=:\d+:in[ ]`)/x


    def self.constantize *a
      if a.length.zero?
        CONSTANTIZE__
      else
        CONSTANTIZE__[ *a ]
      end
    end
    CONSTANTIZE__ = module Constantize__
      p = -> path_x do
        path_x.to_s.gsub( BLACK_RX__, EMPTY_S_ ).
          split( FILE_SEP__, -1 ).
            map( & SANITIZE_FILE_P_ ) * CONST_SEP_
      end
      BLACK_RX__ = %r{ #{ ::Regexp.escape Autoloader::EXTNAME }\z |
        (?<=/)/+ | (?<=[-_ ])[-_ ]+ | [^-_ /a-z0-9]+ }ix
      FILE_SEP__ = '/'.freeze
      p
    end


    def self.constantize_sanitize_file
      SANITIZE_FILE_P_
    end
    SANITIZE_FILE_P_ = module Sanitize_File__
      p = -> part_s do
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
      p
    end


    def self.methodize *a
      if a.length.zero?
        METHODIZE__
      else
        METHODIZE__[ *a ]
      end
    end
    METHODIZE__ = module Methodize__
      p = -> str do
        str.to_s.gsub( PART_RX__ ) { "#{ SEP__ }#{ $1 || $2 }" }.
          gsub( BLACK_RX__, SEP__ ).downcase.intern
      end
      PART_RX__ = /(?<=[a-z])([A-Z])|(?<=[A-Z])([A-Z][a-z])/
      SEP__ = '_'.freeze
      BLACK_RX__ = /[^a-z0-9]+/i
      p
    end


    def self.pathify *a
      if a.length.zero?
        PATHIFY_
      else
        PATHIFY_[ *a ]
      end
    end
    PATHIFY_ = module Pathify__
      p = -> const_x do
        const_x.to_s.gsub( PART_RX__ ) { "-#{ $1 || $2 }" }.
          gsub( CONST_PART_SEP_, PART_SEP__ ).downcase
      end
      PART_RX__ = /(?<=[a-z])([A-Z])|(?<=[A-Z])([A-Z][a-rt-z])/
      PART_SEP__ = '-'.freeze
      p
    end


    def self.pathify_name
      PATHIFY_NAME__
    end
    PATHIFY_NAME__ = -> const_name_s do
      PATHIFY_[ const_name_s.gsub CONST_SEP_, PATH_SEP_ ]
    end


    CONST_PART_SEP_ = '_'.freeze
  end
end
