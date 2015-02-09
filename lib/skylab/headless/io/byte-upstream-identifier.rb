module Skylab::TreetopTools

  class Parser::InputAdapters::Stream

    include Parser::InputAdapter::InstanceMethods

    def default_entity_noun_stem
      'input stream'
    end

    def whole_string
      if upstream.closed?
        error("(broken pipe?) input stream was closed.")
      else
        whole_string = upstream.read
        upstream.close
        whole_string
      end
    end

    def type
      Parser::InputAdapter::Types::STREAM
    end
  end
end
