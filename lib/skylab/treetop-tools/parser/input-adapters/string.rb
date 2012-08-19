module Skylab::TreetopTools
  class Parser::InputAdapters::String
    include Parser::InputAdapter::InstanceMethods
    def resolve_whole_string
      upstream.kind_of?(::String) ? upstream :
        error("expecting String, had: #{upstream.inspect}")
    end
  end
end
