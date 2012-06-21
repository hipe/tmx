module Skylab::Treemap
  class CLI::DynamicOptionParser < ::OptionParser
    def documentor?
      false
    end
    def more *a
      []
    end
  end
end

