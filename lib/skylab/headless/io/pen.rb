module Skylab::Headless
  module IO::Pen end
  module IO::Pen::InstanceMethods
    def em s ; s end
    def invalid_value s ; s end
    def parameter_label m, idx=nil
      idx and idx = "[#{idx}]"
      stem = ::Symbol === m ? m.inspect : m.name.inspect
      "#{stem}#{idx}"
    end
  end
  IO::Pen::MINIMAL = ::Object.new.extend(IO::Pen::InstanceMethods)
end
