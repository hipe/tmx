module Skylab::Snag

  class Models_::Node_Collection

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

      def new_via_upstream_identifier x, & oes_p

        if x.respond_to? :to_simple_line_stream

          _new_via_upstream_identifier x, & oes_p
        else

          # (the current fallback assumption is that this is an FS path)
          new_via_path x, & oes_p
        end
      end

      def new_via_path path, & oes_p

        _id = Home_.lib_.
          system.filesystem.class::Byte_Upstream_Identifier.new path

        _new_via_upstream_identifier _id, & oes_p
      end

      def _new_via_upstream_identifier id, & oes_p

        expression_adapter_( id.modality_const ).

          node_collection_via_upstream_identifier_( id, & oes_p )
      end

      def expression_adapter_ modality_const

        NC_::Expression_Adapters.const_get modality_const, false
      end
    end  # >>

    def edit * x_a, & x_p

      ACS_[].edit x_a, self, & x_p
    end

    def __node__component_association
      yield :can, :add
      Models_::Node
    end

    module Expression_Adapters
      EN = nil
      Autoloader_[ self ]
    end

    class Silo_Daemon

      def initialize kr, mc
        @_kernel = kr
      end

      def FS_adapter_
        @___fsa ||= Filesystem_Adapter___.new Home_.lib_.system.filesystem
      end
    end

    class Filesystem_Adapter___

      def initialize fs
        @filesystem = fs
      end

      attr_reader :filesystem

      def tmpfile_sessioner
        @___tfs ||= __build_tmpfile_sessioner
      end

      def __build_tmpfile_sessioner

        o = Home_.lib_.system.filesystem.tmpfile_sessioner.new

        o.tmpdir_path ::File.join(
          Home_.lib_.system.defaults.dev_tmpdir_path,
          '[sg]',
        )

        o.create_at_most_N_directories 2  # etc

        o.using_filesystem @filesystem

        o
      end
    end

    module Actions

      Digraph = Make_action_loader_[]

      To_Universal_Node_Stream = Make_action_loader_[]

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

    NC_ = self

  end
end
