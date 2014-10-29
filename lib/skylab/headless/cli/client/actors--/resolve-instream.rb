module Skylab::Headless

  module CLI::Client

    class Actors__::Resolve_instream

      # this amounts to an adapter that bridges the legacy client
      # to upstream normalization

      Callback_::Actor.call self, :properties,

        :argv, :IO_adapter, :stx, :evr

      Headless_::Lib_::Event_lib[].sender self

      def execute
        if 1 < @argv.length
          when_too_much_arg
         else
          work
        end
      end

    private

      def when_too_much_arg

        _extra_argv = @argv[ 1 .. -1 ]

        _ev = build_not_OK_event_with :extra_properties,
            :extra_argv, _extra_argv do |y, o|

          _s_a = o.extra_argv.map( & method( :ick ) )
          y << "unexpected argument#{ s _s_a }: #{
           }#{ _s_a * TERM_SEPARATOR_STRING_ }."

        end
        @evr.receive_event _ev
      end

      def work
        _path_arg = build_path_arg
        io = Headless_.system.filesystem.normalization.upstream_IO(
          :instream, @IO_adapter.instream,
          :path_arg, _path_arg,
          :on_event, -> ev do
            @evr.receive_event ev
            UNABLE_
          end )
        io and begin
          @IO_adapter.instream = io  # may be the same one -- stdin
          ACHIEVED_
        end
      end

      def build_path_arg
        _prp = resolve_property
        actuals_has_name = true
        x = @argv.fetch 0 do
          actuals_has_name = false ; nil
        end
        Headless_::Lib_::Bsc_[].trio.new x, actuals_has_name, _prp
      end

      def resolve_property  # (was: `infile_moniker`)

        _CLI_argument = @stx.fetch_argument_at_index 0 do end
        if _CLI_argument
          _CLI_argument
        else
          Headless_::Lib_::Bsc_[].property_via_name Callback_::Name.via_slug 'input-file'  # #todo
        end
      end
    end
  end
end
# #tombstone was :+[#bs-012] case study
