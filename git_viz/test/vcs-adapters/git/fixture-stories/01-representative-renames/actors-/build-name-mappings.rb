module Skylab::GitViz::TestSupport::VCS_Adapters::Git

  module Story_01

    class Actors_::Build_name_mappings

      Callback_::Actor.call self, :properties, :tmpdir

      def execute

        fh = ::File.open ::File.join( @tmpdir, 'out.log' ), ::File::RDONLY
        normal_moniker_via_SHA_head = {}
        order = []
        begin
          line = fh.gets
          line or break
          OPEN_SQUARE_BRACKET_BYTE___ == line.getbyte( 0 ) or redo
          _is_root, sha_head, commit_msg = RX___.match( line ).captures

          _normal = THIS_IS_ETC_RX___.match( commit_msg )[ 1 ]

          order.push sha_head
          normal_moniker_via_SHA_head[ sha_head ] = _normal

          redo
        end while nil

        Name_Mappings___.new order, normal_moniker_via_SHA_head
      end

      OPEN_SQUARE_BRACKET_BYTE___ = '['.getbyte 0

      RX___ = /\A\[master[ ]
        (?<root_commit> \(root-commit\)[ ])?
        (?<sha_head> [a-z0-9]+)\][ ]
        (?<commit_message>.+)/x

      THIS_IS_ETC_RX___ = /\Athis is the (.+) commit\z/

      # ~

      class Name_Mappings___

        def initialize a, h

          @commit_moniker_via_SHA_head_h = h
          h_ = h.invert
          h_.length < h.length and self._HASH_COLLISION  # improbable
          @SHA_head_via_commit_moniker_h = h_

          @SHA_head_order = a
        end

        attr_reader :commit_moniker_via_SHA_head_h,
          :SHA_head_order,
          :SHA_head_via_commit_moniker_h

        def long_mock_SHA_via_normal_ordinal moniker

          "#{ short_mock_SHA_via_normal_ordinal moniker }#{ ZEROS___ }"
        end

        ZEROS___ = '0' * 33  # 40 - SHORT_SHA_LENGTH_

        def short_mock_SHA_via_normal_ordinal moniker

          d = integer_via_normal_ordinal moniker

          "fafa#{ FMT___ % d }"
        end

        FMT___ = "%03d"

        def integer_via_normal_ordinal moniker
          ORD___.fetch moniker
        end

        ORD___ = {
          'first' => 1,
          'second' => 2,
          'third' => 3,
          'fourth' => 4,
          'fifth' => 5
        }
      end
    end
  end
end
