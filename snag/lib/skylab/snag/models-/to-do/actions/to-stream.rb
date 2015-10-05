module Skylab::Snag

  class Models_::To_Do

    class Actions::To_Stream  # < Brazen_::Model.common_action_class  # re-open because [#026]

      Brazen_::Model.common_entity self,

        :desc, -> y do
          y << "a report of the ##{}todo's (or TODO's etc) in a tree"
        end,


        :argument_arity, :one_or_more, :description, -> y do

          y << "narrow the search to only files that match at least one of these patterns"

        end,
        :property, :name,


        :flag, :description, -> y do

          y << "only show the system command that would be used."

        end, :property, :show_command_only,


        :argument_arity, :one_or_more, :description, -> y do

          y << "the todo paterns to search for."
          y << "more patterns broadens the search."
          y << "(default: etc)"

        end,
        :default_proc, -> do
          To_Do_.default_pattern_strings
        end,
        :property, :pattern,


        :argument_arity, :one_or_more, :description, -> y do
          y << "one or more files or directories."
          # (do custom default thing here)
        end,
        :parameter_arity, :one,
        :property, :path

      def produce_result

        o = To_Do_::Sessions_::Collection.new( & handle_event_selectively )

        h = @argument_box.h_
        o.filename_pattern_s_a = h[ :name ]
        o.path_s_a = h.fetch :path
        o.pattern_s_a = h.fetch :pattern
        o.system_conduit = Home_::Library_::Open3

        if h[ :show_command_only ]

          o.build_system_command
        else
          o.to_stream
        end
      end
    end
  end
end
# :+#tombstone: beginnings of [#sl-123] convention: Todo = Api::Todo