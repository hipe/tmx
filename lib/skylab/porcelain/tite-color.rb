module Skylab ; end
module Skylab::Porcelain
  module TiteColor
    extend self
    _ = [nil, :strong, * Array.new(29), :red, :green, :yellow, :blue, :magenta, :cyan, :white]
    MAP = Hash[ * _.each_with_index.map { |sym, idx| [sym, idx] if sym }.compact.flatten ]
    def stylize str, *styles ; "\e[#{styles.map{ |s| MAP[s] }.compact.join(';')}m#{str}\e[0m" end
    def unstylize str             ; unstylize_if_stylized(str) or str      end
    def unstylize_if_stylized str ; str.to_s.dup.gsub!(/\e\[\d+(?:;\d+)*m/, '') end
    (_.compact - [:strong]).each do |c|
      define_method(c) { |s| stylize(s, c) }
      define_method(c.to_s.upcase) { |s| stylize(s, :strong, c) }
    end
  end
end

