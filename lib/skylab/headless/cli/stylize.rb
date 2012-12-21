module Skylab::Headless



  module CLI::Stylize

    o = { }

    a = [ nil, :strong, * ::Array.new( 29 ),
          :red, :green, :yellow, :blue, :magenta, :cyan, :white ]

    map = ::Hash[ * a.each_with_index.map{ |s,i| [s,i] if s }.compact.flatten ]

    o[:codes] = a

    o[:stylize] = -> str, *styles do
      "\e[#{ styles.map{ |s| map[s] }.compact.join ';' }m#{ str }\e[0m"
    end

    o[:unstylize_if_stylized] = -> str do # usu. for testing
      str.to_s.dup.gsub! %r{  \e  \[  \d+  (?: ; \d+ )*  m  }x, ''
    end

    o[:unstylize] = -> str do
      o[:unstylize_if_stylized][ str ] || str
    end

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze

  end



  module CLI::Stylize::Methods

    fun = CLI::Stylize::FUN

    define_method :unstylize_if_stylized, &fun.unstylize_if_stylized

    define_method :stylize, & fun.stylize

    define_method :unstylize, & fun.unstylize

    (fun.codes.compact - [:strong]).each do |c| # pending [#pl-013]
      define_method( c ) { |s| stylize(s, c) }
      define_method(c.to_s.upcase) { |s| stylize(s, :strong, c) }
    end
  end
end
