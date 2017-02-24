module Skylab::Snag

  class Models_::NodeCollection

    COMMON_MANIFEST_FILENAME_ = 'doc/issues.md'.freeze

    class << self

      def via_upstream_reference x, invo_rsx, & p

        if x.respond_to? :to_simple_line_stream

          _via_upstream_reference x, invo_rsx, & p
        else

          # (the current fallback assumption is that this is an FS path)
          via_path x, invo_rsx, & p
        end
      end

      def via_path path, invo_rsx, & p

        _id = Home_.lib_.
          system_lib::Filesystem::ByteUpstreamReference.new path

        _via_upstream_reference _id, invo_rsx, & p
      end

      def _via_upstream_reference id, invo_rsx, & p

        invo_rsx.HELLO_INVO_RSX

        _expad = expression_adapter_ id.modality_const

        _expad.node_collection_via_upstream_reference__ id, invo_rsx, & p
      end

      def expression_adapter_ modality_const

        Here_::ExpressionAdapters.const_get modality_const, false
      end
    end  # >>

    def edit * x_a, & oes_p

      ACS_[].edit( x_a, self ) { |_| oes_p }
    end

    def __node__component_association
      yield :can, :add
      Models_::Node
    end

    module ExpressionAdapters
      EN = nil
      Autoloader_[ self ]
    end

    class FilesystemAdapter  # 1x

      # (hard-coded collaborator with "full stack resources")

      def initialize fs
        @filesystem = fs
      end

      attr_reader :filesystem

      def tmpfile_sessioner
        @___tfs ||= __build_tmpfile_sessioner
      end

      def __build_tmpfile_sessioner

        Home_.lib_.system_lib::Filesystem::TmpfileSessioner.define do |o|
          __define_tmpfile_sessioner o
        end
      end

      def __define_tmpfile_sessioner o

        o.tmpdir_path ::File.join(
          Home_.lib_.system.defaults.dev_tmpdir_path,
          '[sg]',
        )

        o.create_at_most_N_directories 2  # etc

        o.using_filesystem @filesystem
      end
    end

    Nearest_path = -> dir, filesystem, & p do

      fn = COMMON_MANIFEST_FILENAME_

      sp = Walk_upwards_to_find_nearest_surrounding_path_.call(
        dir,
        fn,
        filesystem,
        :argument_path_might_be_target_path,
        & p )

      sp and ::File.join sp, fn
    end

    Walk_upwards_to_find_nearest_surrounding_path_ = -> s, fn, fs, * x_a, & x_p do

      Home_.lib_.system.filesystem.walk.with(

        :filename, fn,
        :max_num_dirs_to_look, 10,  # whatever
        :property_symbol, :dir,
        :start_path, s,
        :filesystem, fs,
        * x_a,
        & x_p
      ).find_any_nearest_surrounding_path
    end

    Here_ = self
  end
end
