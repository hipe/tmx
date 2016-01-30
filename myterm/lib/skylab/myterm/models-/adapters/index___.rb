module Skylab::MyTerm

  class Models_::Adapters

    class Index___

      def initialize paths, single_mod

        # (see last line of file)

        cache_a = []
        cache_h = {}

        d = paths.length
        begin

          if d.zero?
            cache_a.each( & :close__ )
            @_lta = cache_a.freeze
            break
          end

          d -= 1
          path = paths.fetch d

          bn = ::File.basename path
          en = ::File.extname bn

          if en.length.zero?
            category = :dir
            stem = bn
          elsif Autoloader_::EXTNAME == en
            category = :file
            stem = bn[ 0 ... - en.length ]  # ..
          else
            redo
          end

          have_seen = true

          lt = cache_h.fetch stem do

            have_seen = false

            load_ticket = Home_::Models_::Adapter::Load_Ticket.new_via__(
              stem, path, category, single_mod )

            cache_a.push load_ticket
            cache_h[ stem ] = load_ticket

            load_ticket
          end

          if have_seen
            lt.receive_other_path__ path, category
          end
          redo
        end while nil
      end

      def to_load_ticket_stream__
        Callback_::Stream.via_nonsparse_array @_lta
      end
    end
  end
end
# #pending-rename: oops
# #tombstone: this is a non-streaming simplification of the predecessor
