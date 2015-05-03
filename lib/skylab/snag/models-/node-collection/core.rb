module Skylab::Snag

  class Models_::Node_Collection

    class << self

      def new_via_upstream_identifier x, & oes_p

        if x.respond_to? :to_simple_line_stream

          _new_via_upstream_identifier x, & oes_p
        else

          # (the current fallback assumption is that this is an FS path)
          new_via_path x, & oes_p
        end
      end

      def new_via_path path, & oes_p

        _id = Snag_.lib_.
          system.filesystem.class::Byte_Upstream_Identifier.new path

        _new_via_upstream_identifier _id, & oes_p
      end

      def _new_via_upstream_identifier id, & oes_p

        expression_adapter_( id.modality_const ).

          node_collection_via_upstream_identifier_( id, & oes_p )
      end

      def __node__association_for_mutation_session

        Models_::Node
      end

      def expression_adapter_ modality_const

        NC_::Expression_Adapters.const_get modality_const, false
      end
    end  # >>

    def edit * x_a, & x_p

      Snag_.lib_.brazen::Mutation_Session.edit x_a, self, & x_p
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
        @___fsa ||= Filesystem_Adapter___.new Snag_.lib_.system.filesystem
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

        o = Snag_.lib_.system.filesystem.tmpfile_sessioner.new

        o.tmpdir_path ::File.join(
          Snag_.lib_.system.defaults.dev_tmpdir_path,
          'sn0g' )

        o.create_at_most_N_directories 2  # etc

        o.using_filesystem @filesystem

        o
      end
    end


    Actions = THE_EMPTY_MODULE_
    NC_ = self

  end
end
