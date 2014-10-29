module Skylab::Brazen

  class Data_Stores_::Git_Config

    module Mutable

      class Actors::Persist

        Actor_[ self, :properties,
          :is_dry,
          :pathname,
          :document,
          :event_receiver ]

        def did_see i
          instance_variable_defined? ivar_box.fetch i
        end

        def set_pathname pn
          @pathname = pn ; nil
        end

        def execute
          init_ivars
          work
        end

      private

        def init_ivars
          @verb_i = @pathname.exist? ? :update : :create
        end

        def work
          scn = @document.get_line_scanner ; d = 0
          with_IO_opened_for_writing do |io|
            while line = scn.gets
              d += io.write line
            end
          end
          send_wrote_file_event d
        end

        def send_wrote_file_event d
          send_OK_event_with( :datastore_resource_committed_changes,
            :bytes, d,
            :is_completion, true,
            :is_dry, @is_dry,
            :pn, @pathname,
            :verb_i, @verb_i
          ) do |y, o|
            dry_ = ( "dry " if o.is_dry )
            y << "#{ o.verb_i }d #{ pth o.pn } (#{ o.bytes } #{ dry_ }bytes)"
          end
        end

        def with_IO_opened_for_writing & p
          if @is_dry
            p[ Brazen_::Lib_::IO[].dry_stub_instance ]
          else
            ::File.open @pathname.to_path, 'w', & p  # WRITE_MODE_
          end
        end
      end
    end
  end
end
