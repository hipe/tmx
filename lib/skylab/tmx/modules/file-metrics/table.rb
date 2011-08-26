module Skylab
  module Tmx
    module Modules
    end
  end
end

module Skylab::Tmx::Modules::FileMetrics
  class Table < Array
    class << self
      def render matrix, out
        new(matrix).render(out)
      end
    end
    def initialize rows
      @sep = '  '
      @rows = rows
    end
    attr_accessor :sep
    def render out
      @maxes or @maxes = build_maxes
      @rows.each do |row|
        out.puts(row.each_with_index.map do |cel, idx|
          "%#{@maxes[idx]}s" % cel
        end.join(@sep))
      end
    end
  protected
    def build_maxes
      maxes = []
      @rows.each do |row|
        row.each_with_index do |cel, idx|
          maxes[idx] = cel.length if maxes[idx].nil? || maxes[idx] < cel.length
        end
      end
      maxes
    end
  end
end
