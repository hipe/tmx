module Skylab::TreetopTools
  class Parser::InputAdapters::Stream
    include Parser::InputAdapter::InstanceMethods
    def default_entity_noun_stem ; 'input stream' end
    def resolve_whole_string
      if upstream.closed?
        error("(broken pipe?) input stream was closed.")
      else
        whole_string = upstream.read
        upstream.close
        whole_string
      end
    end
  end
end
