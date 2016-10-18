module Skylab::TMX

  module MagneticScratchSpace_for_UnparsedNodeStream____

    module Home_::Magnetics::UnparsedNodeStream_via

      file_stream_via = nil
      DevelopmentDirectory = -> dev_dir, fs_for_glob, fs do

        _file_stream = file_stream_via[ dev_dir, fs_for_glob ]

        _file_stream.map_by do |path|
          Home_::Models_::Node::Parsed::Unparsed.via_json_file_path path
        end
      end

      file_stream_via = -> dev_dir, fs_for_glob do

        glob = ::File.join dev_dir, '*', '.for-tmx-map.json'

        files = fs_for_glob.glob glob

        _ffg = FilesFromGlob___.new files, glob

        # eew / meh - write it ourselves because of the "upstream"

        d = -1 ; last = files.length - 1

        Common_::Stream.new _ffg do
          if d != last
            files.fetch( d += 1 )
          end
        end
      end
    end

    FilesFromGlob___ = ::Struct.new :files, :glob
  end
end
