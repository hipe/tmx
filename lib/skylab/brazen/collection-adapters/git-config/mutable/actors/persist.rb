module Skylab::Brazen

  class Collection_Adapters::Git_Config

    module Mutable

      class Actors::Persist

        Callback_::Actor.methodic self

        # ~ :+[081] experimental extensions to methodic actor

        class << self

          def build_mutable_with * x_a
            new_via_iambic x_a
          end
        end

        def edit_via_iambic x_a
          if x_a.length.nonzero?
            process_polymorphic_stream_fully polymorphic_stream_via_iambic x_a
          else
            true
          end and self
        end

        # ~ end experimental extensions

        def initialize & edit_p

          @do_write_to_tmpfile_first = false

          instance_exec( & edit_p )
        end

      private

        def is_dry=
          @is_dry = gets_one_polymorphic_value
          KEEP_PARSING_
        end

        def document=
          @document = gets_one_polymorphic_value
          KEEP_PARSING_
        end

        def on_event_selectively=
          @on_event_selectively = gets_one_polymorphic_value
          KEEP_PARSING_
        end

        def path=
          @path = gets_one_polymorphic_value
          KEEP_PARSING_
        end

        def write_to_tempfile_first=
          @do_write_to_tmpfile_first = true
          KEEP_PARSING_
        end

        def accept_selective_listener_proc p  # #covered-by [tm]
          @on_event_selectively = p ; nil
        end

      public

        def execute

          @verb_symbol = ::File.exist?( @path ) ? :update : :create

          st = @document.to_line_stream
          d = 0

          with_IO_opened_for_writing do |io|
            line = st.gets
            while line
              d += io.write line
              line = st.gets
            end
          end

          @on_event_selectively.call :info, :success do
            build_wrote_file_event d
          end

          # let's no longer let `info` events dictate our result

          ACHIEVED_
        end

        def build_wrote_file_event d

          build_OK_event_with( :collection_resource_committed_changes,
              :bytes, d,
              :is_completion, true,
              :is_dry, @is_dry,
              :path, @path,
              :verb_symbol, @verb_symbol ) do | y, o |

            _dry = ( "dry " if o.is_dry )

            y << "#{ o.verb_symbol }d #{ pth o.path } (#{ o.bytes } #{ _dry }bytes)"

          end
        end

        module Simple_Event_Builder_Methods_
        private
          def build_OK_event_with * x_a, & p
            Callback_::Event.inline_OK_via_mutable_iambic_and_message_proc x_a, p
          end
        end

        include Simple_Event_Builder_Methods_

        def with_IO_opened_for_writing & p

          io = if @is_dry

            Home_.lib_.IO_lib.dry_stub_instance

          elsif @do_write_to_tmpfile_first

            @__tmpfile__ = ::File.join(
              LIB_.system.filesystem.tmpdir_path,
              'br-VOLATILE' )  # :+[#hl-100]

            ::File.open @__tmpfile__, WRITE_MODE_
          else

            ::File.open @path, WRITE_MODE_
          end

          x = p[ io ]

          io.close

          if @do_write_to_tmpfile_first
            ::FileUtils.mv @__tmpfile__, @path, noop: @is_dry
          end

          x
        end

        WRITE_MODE_ = 'w'.freeze
      end
    end
  end
end
