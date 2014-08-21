module Skylab::Brazen

  module Data_Stores_::Git_Config

    module Mutable

      class Actors__::Write

        Brazen_::Model_::Actor[ self, :properties,
          :document, :is_dry, :listener, :prefix ]

        Brazen_::Entity::Event::Merciless_Prefixing_Sender[ self ]


        def initialize pn, doc, listener, x_a
          @document = doc ; @listener = listener ; @pn = pn
          process_iambic_fully x_a
        end

        def write
          if @pn.exist?
            update
          else
            create
          end
        end

      private

        def create
          scn = @document.get_line_scanner ; d = 0
          with_IO_opened_for_writing do |io|
            while (( line = scn.gets ))
              d += io.write line
            end
          end
          send_wrote_file_event d, :create
        end

        def send_wrote_file_event d, verb_i
          send_event( :wrote_file,
            :bytes, d,
            :is_completion, true,
            :is_dry, @is_dry,
            :pn, @pn,
            :is_positive, true,
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
