module Skylab::TanMan

  class Models_::Starter

    module Actors__

      class Produce_line_scanner

        Actor_[ self, :properties,
          :value_fetcher,
          :workspace_path, :config_filename,
          :event_receiver ]

        def execute
          ok = TanMan_::API.call :starter, :get,
            :workspace_path, @workspace_path,
            :config_filename, @config_filename,
            :event_receiver, self
          ok and via_entity
        end

        def receive_event ev
          if :entity == ev.terminal_channel_i
            @entity = ev.entity
            ACHIEVED_
          else
            @event_receiver.receive_event ev
          end
        end

        def via_entity
          _path = @entity.to_path
          @template = TanMan_::Lib_::String_template[].from_path _path
          via_template
        end

        def via_template
          @output_s = @template.call @value_fetcher
          via_output_s
        rescue ::Errno::ENOENT => e
          @enoent = e
          via_enoent
        end

        def via_enoent
          _ev = Lib_::Entity[].event.wrap.exception.with(
            :path_hack,
            :terminal_channel_i, :resource_not_found,
            :exception, @enoent )
          @event_receiver.receive_event _ev
        end

        def via_output_s
          TanMan_::Lib_::String_IO[].new @output_s
        end
      end
    end


    # For all strings `stem`, normalize it to a joined path and result in
    # a template object representing the possible template file that is
    # there, without checking if the file exists. caches results.
    #
    define_singleton_method :fetch do |stem|
      pathname = dir_pathname.join stem # (it normalizes dotty paths)
      result = cache.fetch pathname.to_s do |path|
        cache[path] = TanMan::Services::Template.from_path path
      end
      result
    end

  end
end
