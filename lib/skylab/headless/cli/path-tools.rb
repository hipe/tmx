module Skylab::Headless

  module CLI::PathTools  # read [#031] the path tools narrative

    def self.clear
      FUN.clear[]
    end
  end

  module CLI::PathTools::FUN

    # read [#031]:#the-issue-with-pretty-path-and-caching

    home__ = -> do
      Headless::FUN.home_directory_path[]
    end

    pwd__ = -> do
      ::Dir.getwd
    end

    home_rx__ = -> home do
      %r[ \A  #{ ::Regexp.escape home[] }  (?=/|\z) ]x
    end

    pwd_rx__ = -> pwd do
      %r[ \A  #{ ::Regexp.escape pwd[] }  (?=/|\z) ]x
    end

    first_rx = %r{\A[^/]*}        # we need to see if there is a common head

    first = -> str { first_rx.match( str )[0] }

    pretty_path__ = -> home, home_rx, pwd, pwd_rx do
      -> path do
        path = path.to_s
        h = { home: home[], pwd: pwd[] }
        if h[:home] && h[:pwd]
          use_key = if    0 == h[:home].index(h[:pwd]) then :home # the order
                    elsif 0 == h[:pwd].index(h[:home]) then :pwd
                    end
          if use_key and 0 == path.index( h[use_key] )
            h[ :pwd == use_key ? :home : :pwd ] = false
          end
        end
        %r{\A[^/]*}.match(path)[0]
        use_path = path
        if h[:home] then use_path = use_path.sub home_rx[], '~' end
        if h[:pwd]  then use_path = use_path.sub pwd_rx[],  '.' end
        begin
          h[:home] && h[:pwd] or break         # (ick ..);
          first[ path ] == first[ h[:pwd] ] or break
          rel_path = ::Pathname.new( path ).relative_path_from(
            ::Pathname.new( h[:pwd] ) ).to_s
          if path[-1] == '/'                   # we've got to "correct" the pn
            rel_path = "#{ rel_path }/"        # version back to our cosmetic
          end                                  # preservation we do here.
          if rel_path.length < use_path.length
            use_path = rel_path
          end
        end while nil
        use_path
      end
    end

    memo = -> f do
      get = -> do
        x = f[]
        get = -> { x }
        x
      end
      -> do
        get[]
      end
    end

    pretty_path_ = -> home_, home_rx_, pwd_, pwd_rx_ do
      home =    memo[ home_ ]
      home_rx = memo[ -> { home_rx_[ home ] } ]
      pwd =     memo[ pwd_ ]
      pwd_rx =  memo[ -> { pwd_rx_[ pwd ] } ]
      pretty_path__[
        -> { home[] },
        -> { home_rx[] },
        -> { pwd[] },
        -> { pwd_rx[] }
      ]
    end

    pretty_path = nil

    clear = -> h=nil, p=nil do
      h ||= home__
      p ||= pwd__
      pretty_path = pretty_path_[ h, home_rx__, p, pwd_rx__ ]
    end

    clear[]

    # -- * --

    ABSOLUTE_PATH_HACK_RX =
      rx = %r{ (?<= \A | [[:space:]'",] )  (?: / [^[:space:]'",]+ )+ }x
      # used hackishly by some subproducs. see spec

    member_a = [ ]
    o = -> member_i, p do
      define_singleton_method member_i do p end
      member_a << member_i
      nil
    end

    class << o
      alias_method :[]=, :[]
    end

    o[:clear] = clear

    o[:escape_path] = -> path do
      path = path.to_s
      if / |\$|'/ =~ path
        Headless::Library_::Shellwords.shellescape path
      else
        path
      end
    end

    o[:memo] = memo

    o[:pretty_path] = Pretty_path = -> path do
      pretty_path[ path ]                     # because the function changes!
    end

    o[:pretty_path_safe] = -> path do
      clear[ ]
      pretty_path[ path ]
    end

    o[:pretty_path_] = pretty_path_            # expose the algo for testing

    o[:expand_tilde] = -> do                   # careful - is le hack

      rx = /\A~(?=\/|\z)/  # (a tilde at the beginning of the string
        # followed by either a forward slash or the end of the line)

      -> path_string do
        path_string.sub rx do
          Headless::FUN.home_directory_path[] || $~[0]
        end
      end
    end.call

    # `contract_tilde` - the opposite of `expand_tilde` - replace a substring
    # of the path with "~" where appropriate.
    # #todo - this is not, but might could be, used in ta

    o[:contract_tilde] = -> path_string do
      rs = path_string
      pth = Headless::FUN.home_directory_path[]
      if pth && path_string.index( pth ).zero? && (  # ick, meh
        pth.length == path_string.length || '/' == path_string[ pth.length ] )
        rs = "~#{ path_string[ pth.length .. - 1 ] }"
      end
      rs
    end

    member_a.freeze
    define_singleton_method :members do member_a end

  end

  module CLI::PathTools::InstanceMethods

    fun = CLI::PathTools::FUN

    define_method :escape_path, & fun.escape_path

    define_method :pretty_path, & fun.pretty_path

  end
end
