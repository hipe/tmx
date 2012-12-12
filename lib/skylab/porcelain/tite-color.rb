module Skylab
  module Porcelain
    # forward-declarations so this file can be standalone if need be
  end
end

module Skylab::Porcelain::TiteColor
  module Methods

    a = [nil, :strong, * Array.new(29),
          :red, :green, :yellow, :blue, :magenta, :cyan, :white]

    map = ::Hash[ * a.each_with_index.map{ |s,i| [s,i] if s }.compact.flatten ]

    define_method :stylize do |str, *styles|
      "\e[#{ styles.map{ |s| map[s] }.compact.join(';') }m#{ str }\e[0m"
    end

    define_method :unstylize_if_stylized do |str| # usu. for testing
      str.to_s.dup.gsub! %r{  \e  \[  \d+  (?: ; \d+ )*  m  }x, ''
    end

    define_method :unstylize do |str|
      unstylize_if_stylized str or str
    end

    (a.compact - [:strong]).each do |c| # pending [#013]
      define_method( c ) { |s| stylize(s, c) }
      define_method(c.to_s.upcase) { |s| stylize(s, :strong, c) }
    end
  end

  extend Methods
end
