module Skylab::MyTerm

  class Models_::Adapters

    class Index___

      # if you receive the entries from the filesystem in a non-deterministic
      # order, you can't stream the list of adapter "load tickets", period.
      # (because each load ticket needs to know which it has among directory
      # and file.) but how many adapters will there ever be anyway!? sheesh
      # (but we did try. see last line of file.)

      def initialize paths, single_mod

        cache_a = []
        cache_h = {}

        d = paths.length
        begin

          if d.zero?
            cache_a.each( & :close__ )
            @array = cache_a.freeze
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

      attr_reader(
        :array,
      )
    end
  end
end
# #tombstone: this is a non-streaming simplification of the predecessor
