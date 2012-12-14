module Skylab::Headless

  module CLI::PathTools

    # **NOTE** pretty_path is designed to scale well to a large number
    # of filepaths scrolling by, possibly thousands.  It generates regexen
    # to match paths that contain `pwd` and `$HOME` at their heads.
    # To read the value of `pwd` and build a regex anew each time it needs
    # to prettify a path does not scale well to large numbers of paths
    # (and just feels wrong), hence these things are memoized.
    #
    # However, it is perfectly reasonable that some programs use `cd` during
    # the course of their execution, which will then out of the box render
    # `pretty_path` broken iff it is used while in more than one `present
    # working directory`'
    #
    # In such cases the program *must* call `PathTools.clear` in between times
    # that the current working directory changes and the time that they
    # use `pretty_path`; otherwise it will be using stale regexen.
    #
    # (if the above is a showstopper, the below can be pretty easily bent
    # to for example take a boolean "clear cache" flag parameter
    # to pretty_path) ..
    #

    # --*--                           enjoy                           --*--

    home__ = -> do
      ::ENV['HOME']
    end

    pwd__ = -> do
      Headless::Services::FileUtils.pwd
    end

    home_rx__ = -> home do
      %r[ \A  #{ ::Regexp.escape home[] }  (?=/|\z) ]x
    end

    pwd_rx__ = -> pwd do
      %r[ \A  #{ ::Regexp.escape pwd[] }  (?=/|\z) ]x
    end

    pretty_path__ = -> home, home_rx, pwd, pwd_rx do
      -> path do
        path = path.to_s
        h = { home: home[], pwd: pwd[] }
        if h[:home] && h[:pwd]
          k = if    0 == h[:home].index(h[:pwd]) then :home # the order
              elsif 0 == h[:pwd].index(h[:home]) then :pwd
              end
          if k and  0 == path.index(h[k])
            h[ :pwd == k ? :home : :pwd ] = false
          end
        end
        if h[:home] then path = path.sub home_rx[], '~' end
        if h[:pwd]  then path = path.sub pwd_rx[],  '.' end
        path
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

    o = { }

    absolute_path_hack_rx = o[:absolute_path_hack_rx] =    # see spec, hackishly
      %r{ (?<= \A | [[:space:]'",] )  (?: / [^[:space:]'",]+ )+ }x     # used in
                                                                   # subproducts

    o[:clear] = clear

    define_singleton_method :clear, &clear

    o[:escape_path] = -> path do
      path = path.to_s
      if / |\$|'/ =~ path
        Headless::Services::Shellwords.shellescape path
      else
        path
      end
    end

    o[:memo] = memo

    o[:pretty_path] = -> path do
      pretty_path[ path ]
    end

    o[:pretty_path_] = pretty_path_            # expose the algo for testing

    o[:stop_rx] = %r{ \A \. | / \z }x          # all pathnames have such a root
                                               # hackishly (?) used to determine
    # this for relative or absolute pn's until something better comes along..
    # maybe `pn == pn.dirname` instead?

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze

  end



  module CLI::PathTools::InstanceMethods

    fun = CLI::PathTools::FUN

    define_method :escape_path, & fun.escape_path

    define_method :pretty_path, & fun.pretty_path

  end
end
