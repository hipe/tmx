module Skylab::DocTest

  class Operations_::Recurse

    def self.describe_into_under y, expag
      expag.calculate do
        y << "#{ code 'sync' } for an entire directory #experimental."
        y << "(currently overloaded with sane defaults, configurable later.)"
        y << "(it is not supposed to overwrite unversioned content ever.)"
      end
    end

    def initialize
      @asset_extname = nil
      @list = nil
      @test_filename_pattern = nil
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

      -> st, & pp do

        _n18n = Path_must_be_absolute___[]

        _n18n.normalize_value st.gets_one, & pp[ nil ]
      end
    end

    def __asset_extname__component_association
      Any_value__
    end

    def __test_filename_pattern__component_association
      Any_value__
    end

    def __filesystem__component_association
      Any_value__
    end

    def __system_conduit__component_association
      Any_value__
    end

    def execute & oes_p
      @_on_event_selectively = oes_p
      extend ImplementationAssistance___
      execute
    end

    module ImplementationAssistance___  # laziness

      def execute
        __prepare
        __unit_of_work_stream
      end

      def __prepare

        @_lib = Home_::RecursionMagnetics_

        nc = Home_::RecursionModels_::NameConventions.default_instance__

        otr = nil
        dup = Lazy_.call do
          otr = nc.dup
          otr
        end

        if @asset_extname
          dup[].asset_extname = @asset_extname
        end

        if @test_filename_pattern
          dup[].test_filename_patterns = [ @test_filename_pattern ]
        end

        if otr
          nc = otr.finish
        end

        @name_conventions = nc
        NIL
      end

      def __build_name_conventions_to_order
        nc = Home_::RecursionModels_::NameConventions.begin
        nc.asset_extname = @asset_extname  # nil ok
        s = @test_filename_pattern
        if s
          nc.test_filename_patterns = [ s ]  # because etc
        end
        nc.finish
      end

      # -- automatable

      def __unit_of_work_stream

        # if you're thinking that a lot of this looks like boilerplate
        # that could be generated, you're right - [#ta-005]

        ok = true
        ok &&= __check_that_path_exists
        ok &&= __resolve_test_directory
        ok &&= __resolve_counterpart_directory
        ok &&= __resolve_counterpart_index
        ok &&= __resolve_probably_participating_file_stream
        ok &&= __resolve_unit_of_work_stream_
        ok && remove_instance_variable( :@unit_of_work_stream )
      end

      def __check_that_path_exists  # because #note-2 in [#029]

        if @filesystem.exist? @path  # file or directory OK
          ACHIEVED_
        else
          _no = Home_.lib_.system_lib::Filesystem::Normalizations::Upstream_IO.via(
            :path, @path,
            :filesystem, @filesystem,
            & @_on_event_selectively
          )
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
        _if _, :@unit_of_work_stream
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
        :list,  # do list
        :name_conventions,
        :system_conduit,
        :test_directory,
      )

      def VCS_reader
        @___VCS_reader ||= __build_VCS_reader
      end

      def __build_VCS_reader
        _cls = Home_.lib_.git::Check::Session
        sess = _cls.begin
        sess.system_conduit = @system_conduit
        sess.finish
      end

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

    Path_must_be_absolute___ = Lazy_.call do

      Home_.lib_.basic::Pathname::Normalization.with(
        :absolute,
        :downward_only,
        :no_single_dots,
      )
    end

    # ==

    Any_value__ = -> st do
      Common_::Known_Known[ st.gets_one ]
    end
  end
end
# #tombstone: full rewrite from pre-zerk to zerk
