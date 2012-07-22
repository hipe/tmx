module Skylab::FileMetrics
  class Models::Table < ::Array
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
      (@maxes ||= nil) or @maxes = build_maxes
      @rows.each do |row|
        out.puts(row.each_with_index.map do |cel, idx|
          if ::String === cel
            "%#{@maxes[idx]}s" % cel
          else
            cel[:styled].call
          end
        end.join(@sep))
      end
    end
  protected
    def build_maxes
      maxes = []
      @rows.each do |row|
        row.each_with_index do |cel, idx|
          len = ::String === cel ? cel.length : cel[:chars_length].call
          maxes[idx] = len if maxes[idx].nil? || maxes[idx] < len
        end
      end
      maxes
    end
  end
end
