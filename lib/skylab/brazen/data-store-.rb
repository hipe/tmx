module Skylab::Brazen

  module Data_Store_

    class Model_ < Brazen_::Model_

      class << self
        def main_model_class
          superclass.superclass
        end
      end

      NAME_STOP_INDEX = 1  # sl brzn datastore actions couch add

    end

    class Action < Brazen_::Model_::Action

      NAME_STOP_INDEX = 1

    end

    class Actor
    private

      def via_entity_resolve_model_class
        @model_class = @entity.class ; nil
      end

      def via_entity_resolve_entity_identifier
        @entity_identifier = @entity.class.node_identifier.
          with_local_entity_identifier_string @entity.natural_key_string  # #todo - is this covered
        PROCEDE_
      end
    end

    module Byte_Upstream_Identifier  # :[#018].

      class << self

        def via_stream io
          Brazen_.lib_.IO::Byte_Upstream_Identifier.new io
        end

        def via_string s
          Brazen_.lib_.basic::String::Byte_Upstream_Identifier.new s
        end

        def via_path s
          Brazen_.lib_.system.filesystem.class::Byte_Upstream_Identifier.new s
        end
      end  # >>
    end

    module Byte_Downstream_Identifier

      class << self

        def via_stream io
          Brazen_.lib_.IO::Byte_Downstream_Identifier.new io
        end

        def via_string s
          Brazen_.lib_.basic::String::Byte_Downstream_Identifier.new s
        end

        def via_path s
          Brazen_.lib_.system.filesystem.class::Byte_Downstream_Identifier.new s
        end
      end  # >>
    end
  end
end
