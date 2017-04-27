module Skylab::TanMan

  DocumentToolkit_ = nil
  # (for now this node exists only to hold anemics for:)

  module DocumentMagnetics_

    # ==

    ByteStreamReference_via_QualifiedKnownness_and_ThroughputDirection = -> do

      these = {
        input: :UpstreamReference,
        hereput: :UpstreamReference,  # meh this is :#microtheme1
        output: :DownstreamReference,
      }

      -> qkn, direction_sym do
        _const = these.fetch direction_sym
        _class = Home_.lib_.basic::ByteStream.const_get _const, false
        _class.via_qualified_knownness qkn
      end
    end.call

    # ==

    ByteStreamReference_via_Locked_IO = -> io, yes_w, yes_r do

      IO_[]::ByteStreamReference.define do |o|
        if yes_r
          o.will_be_readable
        end
        if yes_w
          o.will_be_writable
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

    IO_via_ExistingFilePath = -> path, yes_w, yes_r, filesystem do  # ..

      # (we can cover no ent when necessary)

      mode = if yes_w
        if yes_r
          ::File::RDWR
        else
          ::File::WRONLY
        end
      elsif yes_r
        ::File::RDONLY
      end

      if mode
        filesystem.open path, mode
      end
    end

    # ==

    IO_ = Lazy_.call do
      Home_.lib_.system_lib::IO
    end

    # ==
    # ==
  end
end
# #history-A: full rewrite, back to smalls
