module Skylab::FileMetrics
  class Models::Table
    def initialize rows
      @sep = '  '
      @rows = rows
    end
    def render out
      CLI::Lipstick.initscr
      (@maxes ||= nil) or @maxes = build_maxes
      _cels = []
      @rows.each do |row|
        _cels.clear
        row.each_with_index do |cel, idx|
          if ::String === cel
            _cels.push("%#{@maxes[idx]}s" % cel)
          else
            cel[:render].call(_cels, self)
          end
        end
        out.puts _cels.join(@sep)
      end
    end
    attr_accessor :sep
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
