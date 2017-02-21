module Skylab::Snag

  class Models_::NodeCollection

    COMMON_MANIFEST_FILENAME_ = 'doc/issues.md'.freeze

    class << self

      def nearest_path dir, filesystem, & x_p

        fn = COMMON_MANIFEST_FILENAME_

        sp = Walk_upwards_to_find_nearest_surrounding_path_[
          dir,
          fn,
          filesystem,
          :argument_path_might_be_target_path,
          & x_p ]

        if sp
          ::File.join sp, fn
        else
          sp
        end
      end

      def new_via_upstream_identifier x, fsa, & p

        if x.respond_to? :to_simple_line_stream

          _new_via_upstream_identifier x, fsa, & p
        else

          # (the current fallback assumption is that this is an FS path)
          new_via_path x, fsa, & p
        end
      end

      def new_via_path path, fsa, & p

        _id = Home_.lib_.
          system_lib::Filesystem::Byte_Upstream_Identifier.new path

        _new_via_upstream_identifier _id, fsa, & p
      end

      def _new_via_upstream_identifier id, fsa, & p

        _expad = expression_adapter_ id.modality_const

        _expad.node_collection_via_upstream_identifier__ id, fsa, & p
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

    Walk_upwards_to_find_nearest_surrounding_path_ = -> s, fn, fs, * x_a, & x_p do

      Home_.lib_.system.filesystem.walk.new_with(

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
