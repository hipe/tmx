module Skylab::TreetopTools
  class Parser::InputAdapters::String
    include Parser::InputAdapter::InstanceMethods
    def default_entity_noun_stem ; 'input string' end
    def resolve_whole_string
      upstream.kind_of?(::String) ? upstream :
        error("expecting String, had: #{upstream.inspect}")
    end
    def type ; Parser::InputAdapter::Types::STRING end
  end
end
