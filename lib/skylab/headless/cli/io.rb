module Skylab::Headless

  module CLI  # read [#015]  #storypoint-5 introduction

    IO = (( class IO__ < ::Module

      def [] i
        case i
        when :some_errstream_IO, :some_outstream_IO, :some_instream_IO ; send i
        else ; raise ::NameError, "no member #{ i } in #{ self }" end
      end

      def some_instream_IO
        Headless_.system.IO.some_stdin_IO
      end

      def some_outstream_IO
        Headless_.system.IO.some_stdout_IO
      end

      def some_errstream_IO
        Headless_.system.IO.some_stderr_IO
      end

      def three_streams
        Headless_.system.IO.some_three_streams
      end

      self
    end )).new

    module IO

      module Adapter

        class Minimal

          def initialize i, o, e, pen=CLI.pen.minimal_instance  # storypoint-10
            @instream = i ; @outstream = o ; @errstream = e ; @pen = pen ; nil
          end

          attr_reader :instream, :outstream, :errstream, :pen

          attr_writer :instream  # #storypoint-500 it gets modified from ..

          def to_two
            [ @outstream, @errstream ]
          end

          def to_three
            [ @instream, @outstream, @errstream ]
          end

          def call_digraph_listeners type_i, msg
            instance_variable_get(
              :payload == type_i ? :@outstream : :@errstream ).puts msg ; nil
          end
        end
      end
    end
  end
end
