module Skylab::Callback

  module Models_::Event

    class Actions::Viz < Brazen_::Action

      include Common_Action_Methods_

      @is_promoted = true

      Brazen_::Model::Entity[ self ]

      edit_entity_class(

        :desc, -> y do
          y << "visualize an event graph for a particular module"
        end,

        :description, -> y do
          y << "write output to file"
        end,
        :property, :output_file,

        :property, :stdout,

        :description, -> y do
          y << "necessary to overwrite the file."
        end,
        :flag, :property, :force,

        :description, -> y do
          y << "use the `open` command on your OS to open the file"
        end,
        :flag, :property, :do_open,

        :description, -> y do
          y << "file to #{ code 'require' }"
        end,
        :required, :property, :file,

        :description, -> y do
          y << "xx"
        end,
        :required, :property, :const,
      )

      def produce_result

        ok = resolve_module_
        ok &&= __resolve_downstream_IO
        ok &&= __via_module
        ok && __maybe_open
      end

      def __resolve_downstream_IO

        io = __produce_downstream_IO
        if io
          @__downstream_IO = io
          ACHIEVED_
        else
          io
        end
      end

      def __produce_downstream_IO

        h = @argument_box.h_
        @_do_open = h[ :do_open ]

        pa = trio :output_file

        if pa.is_known && pa.value_x

          fa = trio :force

          kn = Home_.lib_.system.filesystem( :Downstream_IO ).with(
            :path_arg, pa,
            :force_arg, fa,
            & handle_event_selectively )

          if kn
            @_path_to_open = pa.value_x
            @_do_close = true
            kn.value_x
          else
            kn
          end
        elsif @_do_open
          self._COVER_ME
        else
          @_do_close = false
          h.fetch :stdout
        end
      end

      def __via_module

        cls = @module_
        _esg = cls.event_stream_graph

        io = @__downstream_IO

        y = ::Enumerator::Yielder.new do | line |
          io.puts line
        end

        __express_header y

        _IO_pxy = Home_.lib_.basic::String::Receiver::As_IO.new do | o |

          o[ :receive_string ] = -> str do

            s_a = str.split NEWLINE_, -1

            s_a.each do | s |
              if s.length.nonzero?
                io.puts "#{ SPACE_ }#{ SPACE_ }#{ s }"
              end
            end
          end
        end

        _esg.describe_digraph(
          :IO, _IO_pxy,
          :with_spaces, )

        __express_footer y

        if @_do_close
          io.close
        end

        ACHIEVED_
      end

      def __express_header y
        y << "digraph {"
        y << "  node [shape=\"Mrecord\"]"
        y << "  label=\"event stream graph for ::#{ @module_ }\""
      end

      def __express_footer y
        y << "}"
      end

      def __maybe_open

        if @_do_open

          ::Kernel.exec 'open', @_path_to_open
          self._NEVER_SEE
        else
          ACHIEVED_
        end
      end

      NEWLINE_ = "\n"
    end
  end
end
# :+#tombstone: UI for edge cases
