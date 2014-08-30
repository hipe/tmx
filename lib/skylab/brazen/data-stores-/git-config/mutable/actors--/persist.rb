module Skylab::Brazen

  class Data_Stores_::Git_Config

    module Mutable

      Actors__ = ::Module.new

      class Actors__::Persist

        Actor_[ self, :properties,
          :pn, :document, :listener, :x_a, :is_dry, :channel ]

        Entity_[]::Event::Merciless_Prefixing_Sender[ self ]

        def initialize x_a
          @pn, @document, @listener, @x_a, @is_dry, @channel = x_a
          process_iambic_fully @x_a
          @x_a = nil
        end

        def execute
          verb_i = @pn.exist? ? :update : :create
          scn = @document.get_line_scanner ; d = 0
          with_IO_opened_for_writing do |io|
            while (( line = scn.gets ))
              d += io.write line
            end
          end
          send_wrote_file_event d, verb_i
        end

        def send_wrote_file_event d, verb_i
          send_event( :wrote_file,
            :bytes, d,
            :is_completion, true,
            :is_dry, @is_dry,
            :ok, true,
            :pn, @pn,
            :verb_i, verb_i
          ) do |y, o|
            dry_ = ( "dry " if o.is_dry )
            y << "#{ o.verb_i }d #{ pth o.pn } (#{ o.bytes } #{ dry_ }bytes)"
          end
        end

        def with_IO_opened_for_writing & p
          if @is_dry
            p[ Brazen_::Lib_::IO[]::DRY_STUB ]
          else
            ::File.open @pn.to_path, 'w', & p  # WRITEMODE_
          end
        end
      end
    end
  end
end
