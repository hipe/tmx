module Skylab::Snag

  class Models_::ToDo

    class Actions::ToStream

      def definition ; [

        :branch_description, -> y do
          y << "a report of the ##{}todo's (or TODO's etc) in a tree"
        end,

        :glob, :property, :name,
        :description, -> y do
          y << "narrow the search to only files that match at least one of these patterns"
        end,

        :flag, :property, :show_command_only,
        :description, -> y do
          y << "only show the system command that would be used."
        end,

        :glob, :property, :pattern,
        :description, -> y do
          y << "the todo paterns to search for."
          y << "more patterns broadens the search."
          y << "(default: etc)"
        end,
        :default_by, -> _act do
          Common_::KnownKnown[ Here_.default_pattern_strings ]
        end,

        :required, :glob, :property, :path,
        :description, -> y do
          y << "one or more files or directories."
          # (do custom default thing here)
        end,

      ] end

      def initialize
        extend ActionRelatedMethods_
        init_action_ yield
        @name = @show_command_only = nil  # #[#026]
      end

      def execute

        o = Here_::Magnetics_::Collection_via_Arguments.define do |sess|
          __transfer_properties sess
        end

        if @show_command_only
          o.build_system_command
        else
          o.to_stream
        end
      end

      def __transfer_properties o
        o.filename_patterns = @name
        o.paths = @path
        o.patterns = @pattern
        o.system_conduit = Home_::Library_::Open3
        o.listener = _listener_
      end

      # ==
      # ==
    end
  end
end
# :+#tombstone: beginnings of [#sl-123] convention: Todo = Api::Todo
