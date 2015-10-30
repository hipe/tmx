module Skylab::MyTerm

  class Models_::Appearance

    # "appearance" as in the iTerm appearance.

    class Silo_Daemon

      def initialize ke
        @_kernel = ke
      end

      def build_unordered_index_stream & x_p

        app = Here_.new @_kernel, & x_p
        _ok = app.init
        _ok && app.to_unordered_index_stream
      end
    end

    # ~ as model ->

      def initialize ke, & x_p
        @_kernel = ke
        @_oes_p = x_p
      end

      def init

        inst = @_kernel.silo :Installation
        fs = inst.filesystem
        path = inst.appearance_delta_path

        begin
          io = fs.open path, ::File::RDWR
        rescue ::Errno::ENOENT
        end

        if io
          self._RETRIEVE__init_retrieved_via_IO io
        else
          __init_created path, fs
        end
      end

      def __init_created path, fs

        @_CAS = [ :adapter ]  # LOOK to start, you only have this one component

        @_is_created = true
        @_is_modified = false

        @_produce_writable_IO = -> & x_p do

          # we don't create directories or lock until we need to

          dirname = ::File.dirname path
          if ! fs.exist? dirname
            fs.mkdir_p dirname, & x_p
          end
          fs.open path, ::File::CREAT | ::File::WRONLY
        end

        ACHIEVED_
      end

      def to_unordered_index_stream
        ACS_[]::Modalities::Reactive_Tree::Children_as_unbound_stream[ self ]
      end

      def component_association_symbols
        @_CAS
      end

      def __adapter__component_association
        Models_::Adapter
      end

      def component_operation_symbols
        NIL_  # LOOK don't bother indexing our methods for operations ever
      end

    # ~ <-

    Here_ = self
  end
end
