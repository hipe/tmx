module Skylab::Treemap

  module CLI::Option::InstanceMethods
    def options
      @options_f ||= -> do
        seen_definition_length = 0
        is_current = false
        box = CLI::Option::Box.new
        on_definition_added_h[:option_syntax_reflection] = -> do
          is_current = false      # for the future, we must note we have more
          box.clear!              # options to process when more are aded
          nil
        end
        add_help = -> do          # #tracked by [#015]
          # the `help` option gets special treament because sometimes it's magic
          box.fetch_by_normalized_name :help do |k|
            o = CLI::Option.build_from_args(
              ['-h', '--help'] ).validate
            box.add o
            nil
          end
        end
        -> do
          if ! is_current
            recorder =
              CLI::Option::Probe::OptionParser.new box
            while seen_definition_length < definitions.length
              defn = definitions[ seen_definition_length ]
              recorder.absorb defn
              seen_definition_length += 1
            end
            add_help[ ]           # (where? [#015])
            is_current = true
          end
          box
        end
      end.call
      @options_f.call
    end
  end
end
