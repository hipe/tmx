module Skylab::TanMan

  module DocumentMagnetics_

    # ==

    ByteStreamReference_via_Locked_IO = -> io, is_read_write_not_read_only do

      IO_[]::ByteStreamReference.define do |o|
        o.write_is_readable
        if is_read_write_not_read_only
          o.write_is_writable
        end
        o.IO = io
      end
    end

    # ==

    Locked_IO_via_IO = -> io do  # ..

      # (annoying to cover. a bit of a stub for now)

      d = io.flock ::File::LOCK_EX | ::File::LOCK_NB
      if d
        if d.zero?
          io
        else
          self._COVER_ME__nonzero_status_when_tried_to_lock__
        end
      else
        self._COVER_ME__falseish_result_when_tried_to_lock__
      end
    end

    # ==

    IO_via_ExistingFilePath = -> path, is_read_write_not_read_only, filesystem do  # ..

      # (we can cover no ent when necessary)

      _mode = if is_read_write_not_read_only
        ::File::RDWR
      else
        ::File::RDONLY
      end

      filesystem.open path, _mode
    end

    # ==

    IO_ = Lazy_.call do
      Home_.lib_.system_lib::IO
    end

    # ==
    # ==
  end
end

# #pending-rename: to "document toolkit" maybe (up out of models) (see `DocumentToolkit___`)
Skylab::TanMan::Models_::DotFile::DocumentController_via_Request = NIL
# #history-A: full rewrite, back to smalls
