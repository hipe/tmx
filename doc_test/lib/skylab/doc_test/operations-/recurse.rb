module Skylab::DocTest

  class Operations_::Recurse

    def self.describe_into_under y, expag
      expag.calculate do
        y << "#{ code 'sync' } for an entire directory (EXPERIMENTAL)."
        y << "(currently overloaded with sane defaults, configurable later.)"
      end
    end

    def initialize fs
      @filesystem = fs
      @list = nil
    end

    def __list__component_association

      yield :description, -> y do
        y << "only output the paths of the participating asset files"
      end

      yield :flag
    end

    def __path__component_association

      yield :description, -> y do
        y << "the directory or file yadda (EDIT)"
      end

      -> st do
        Common_::Known_Known[ st.gets_one ]
      end
    end

    def execute & oes_p
      @_on_event_selectively = oes_p
      extend ImplementationAssistance___
      execute
    end

    module ImplementationAssistance___  # laziness

      def execute
        __prepare
        _ok = __resolve_unit_of_work_stream
        _ok && __via_unit_of_work_stream
      end

      def __prepare
        @_lib = Home_::RecursionMagnetics_
        @name_conventions = Hardcoded_name_conventions_for_now___[]
        NIL
      end

      def __via_unit_of_work_stream
        if @list
          remove_instance_variable :@_unit_of_work_stream
        else
          ::Kernel._K
        end
      end

      # -- automatable

      def __resolve_unit_of_work_stream

        # if you're thinking that a lot of this looks like boilerplate
        # that could be generated, you're right - [#ta-005]

        ok = true
        ok &&= __check_that_path_exists
        ok &&= __resolve_test_directory
        ok &&= __resolve_counterpart_directory
        ok &&= __resolve_counterpart_index
        ok &&= __resolve_probably_participating_file_stream
        ok &&= __resolve_unit_of_work_stream_
        ok
      end

      def __check_that_path_exists  # because #note-2 in [#029]

        if @filesystem.exist? @path  # file or directory OK
          ACHIEVED_
        else
          _nn = @filesystem.normalization :Upstream_IO
          _no = _nn.against_path @path, & @_on_event_selectively
          false == _no || self._SANITY
          UNABLE_
        end
      end

      def __resolve_test_directory

        _if @_lib::TestDirectory_via_ArgumentPath.of( self ), :@test_directory
      end

      def __resolve_counterpart_directory

        _ = @_lib::CounterpartDirectory_via_ArgumentPath_and_TestDirectory.of self
        _if _, :@counterpart_directory
      end

      def __resolve_counterpart_index

        _ = @_lib::CounterpartTestIndex_via_TestDirectory_and_CounterpartDirectory.of self
        _if _, :@counterpart_test_index
      end

      def __resolve_probably_participating_file_stream

        _ = @_lib::ProbablyParticipatingFileStream_via_ArgumentPath.of self
        _if _, :@probably_participating_file_stream
      end

      def __resolve_unit_of_work_stream_

        _ = @_lib::UnitOfWorkStream_via_CounterpartTestIndex_and_ProbablyParticipatingFileStream.of self
        _if _, :@_unit_of_work_stream
      end

      # -- destructive readers (we assert read only once, just because)

      def counterpart_directory
        remove_instance_variable :@counterpart_directory
      end

      def counterpart_test_index
        remove_instance_variable :@counterpart_test_index
      end

      def probably_participating_file_stream
        remove_instance_variable :@probably_participating_file_stream
      end

      # -- reusable readers

      # ~ (name changes)

      def argument_path
        @path
      end

      def listener_
        @_on_event_selectively
      end

      # ~

      attr_reader(
        :filesystem,
        :name_conventions,
        :test_directory,
      )

      # --

      def _if x, ivar
        if x
          instance_variable_set ivar, x ; ACHIEVED_
        else
          x
        end
      end
    end

    # ==

    Hardcoded_name_conventions_for_now___ = Lazy_.call do
      o = Home_::RecursionModels_::NameConventions.begin
      o.asset_extname = Autoloader_::EXTNAME
      o.finish
    end
  end
end
# #tombstone: full rewrite from pre-zerk to zerk
