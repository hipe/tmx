module Skylab::FileMetrics

  class Models::Table

    def render out
      CLI::Lipstick.initscr
      @max_a = prerender if ! @max_a
      cel_a = []
      @row_a.each do |row|
        cel_a.clear
        row.each_with_index do |cel, idx|
          if cel.respond_to? :render
            cel.render cel_a, self
          else
            cel_a << ( "%#{ @max_a[ idx ] }s" % cel )
          end
        end
        out.puts cel_a.join( @sep )
      end
      nil
    end

    attr_accessor :sep

  protected

    def initialize row_a
      @max_a = nil
      @row_a = row_a
      @sep = '  '
    end

    def prerender  # result - `max_a`
      max_a = []
      @row_a.each do |row|
        row.each_with_index do |cel, idx|
          len = ( cel ? cel.length : 0 )  # cel should be a string or proxy
          max_a[idx] = len if max_a[idx].nil? || max_a[idx] < len
        end
      end
      max_a
    end
  end
end
