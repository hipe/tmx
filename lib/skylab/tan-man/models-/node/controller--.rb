module Skylab::TanMan

  class Models_::Node

    module Controller__

      class Normalize_name

        Callback_::Actor.call self, :properties,
          :ent,
          :arg

        def execute
          @arg
        end
      end

    end

    if false

    def initialize dot_file_controller, node_stmt
      super dot_file_controller
      @node_stmt = node_stmt
    end

    # result is always true - no errors yet to emit. always emits event
    def update_attributes attrs, _, success # no errors to emit yet
      a_list = @node_stmt.attr_list.content
      a_list._prototype ||= a_list_prototype
      added = [] ; changed = []
      a_list._update_attributes attrs,
        -> name, val { added << [name, val] },
        -> name, old, new { changed << [name, old, new] }
      success[ Models::Node::Events::Attributes_Updated.new self,
        @node_stmt, added, changed ]
      true
    end

  private

    a_list_proto = nil

    define_method :a_list_prototype do  # [#054], [#071]
      a_list_proto ||= @node_stmt.class.parse :a_list, 'a=b, c=d'
    end

    alias_method :dot_file, :request_client
    end
  end
end
