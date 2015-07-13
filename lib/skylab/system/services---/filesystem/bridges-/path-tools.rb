module Skylab::System

  class Services___::Filesystem

    class Bridges_::Path_Tools  # #open [#031] new will move here, clobber this  read [#031] the path tools narrative

      class << self

        def absolute_path_hack_rx
          ABSOLUTE_PATH_HACK_RX__
        end

        def escape_path path
          Escape_path__[ path ]
        end

        define_method :expand_tilde, -> do

          rx = /\A~(?=\/|\z)/  # (a tilde at the beginning of the string
            # followed by either a forward slash or the end of the line)

          -> path_string do
            path_string.sub rx do
              Home_.services.environment.any_home_directory_path || $~[ 0 ]
            end
          end
        end.call

        def contract_tilde path_s

          home_s = Home_.services.environment.any_home_directory_path

          if home_s && path_s.index( home_s ).zero? and
              home_s.length == path_s.length || '/' == path_s[ home_s.length ]
            "~#{ path_s[ home_s.length .. - 1 ] }"
          else
            path_s
          end
        end

        def instance_methods_module
          IM__
        end

        def pretty_path_safe x
          clear
          pretty_path x
        end

        def clear
          Clear__[]
        end

        def pretty_path * a
          if a.length.zero?
            Pretty_path__
          else
            Pretty_path__[ * a ]
          end
        end
      end

      ABSOLUTE_PATH_HACK_RX__ =
        %r{ (?<= \A | [[:space:]'",] )  (?: / [^[:space:]'",]+ )+ }x
        # used hackishly by some subproducs. see spec


    home__ = -> do
      Home_.services.environment.any_home_directory_path
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

    memo = -> p do
      Callback_.memoize( & p )
    end

    Pretty_path____ = -> home_, home_rx_, pwd_, pwd_rx_ do
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
      pretty_path = Pretty_path____[ h, home_rx__, p, pwd_rx__ ]
    end

    clear[]

    # -- * --

      Clear__ = -> * a do
        clear[ * a ]
      end

      Pretty_path__ = -> x do
        pretty_path[ x ]
      end

      Escape_path__ = -> path do
        path = "#{ path }"
        if / |\$|'/ =~ path
          Home_.lib_.shellwords.shellescape path
        else
          path
        end
      end

      module IM__
        define_method :escape_path, Escape_path__
        define_method :pretty_path, Pretty_path__
      end
    end
  end
end
