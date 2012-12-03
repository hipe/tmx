module Skylab::Headless
  module IO::Pen end
  module IO::Pen::InstanceMethods
    def em s ; s end
    white_rx = /[[:space:]]/
    define_method :human_escape do |s|         # like shell_escape but for
      white_rx =~ s ? s.inspect : s            # humans -- basically use quotes
    end                                        # iff necessary (né smart_quotes)
    def kbd s ; em s end
    def invalid_value s ; s end
    def parameter_label m, idx=nil
      idx and idx = "[#{idx}]"
      stem = ::Symbol === m ? m.inspect : m.name.inspect
      "#{stem}#{idx}"
    end
  end
  IO::Pen::MINIMAL = ::Object.new.extend(IO::Pen::InstanceMethods)
end
