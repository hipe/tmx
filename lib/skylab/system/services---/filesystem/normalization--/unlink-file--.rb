module Skylab::System


    class Services___::Filesystem

      class Normalization__

        class Unlink_File__ < self

          class << self
            def mixed_via_iambic x_a
              new do
                process_polymorphic_stream_fully polymorphic_stream_via_iambic x_a
                @x_a = @d = @x_a_length = nil  # #todo
              end.produce_mixed_result
            end
          end

          Callback_::Actor.methodic self, :simple, :properties,
            :path,
            :argument_arity, :zero, :if_exists,
            :on_event_selectively

          # #todo this is just a stub

          def produce_mixed_result
            if @if_exists
              when_if_exists
            else
              @x = ::File.unlink @path
              via_x
            end
          end

          def when_if_exists
            @x = ::File.unlink @path
            via_x
          rescue ::Errno::ENOENT => @e
            via_e
          end

          def via_e
            @on_event_selectively.call :error, :enoent do
              Callback_::Event.wrap.exception @e, :path_hack
            end
          end

          def via_x
            if 1 == @x  # the number of files in the arg, just a sanity check
              when_success
            else
              UNABLE_
            end
          end

          def when_success
            @on_event_selectively.call :info, :success do
              Callback_::Event.inline_neutral_with :deleted_file,
                :path, @path
            end
          end
        end
      end
    end
end
