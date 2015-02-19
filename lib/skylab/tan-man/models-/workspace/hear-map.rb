module Skylab::TanMan

  class Models_::Workspace

    module Hear_Map

      module Definitions

        class Init

          def after
            [ :meaning, :set_meaning ]
          end

          def definition
            [ :sequence, :functions,
                :keyword, 'start',
                :zero_or_one, :keyword, 'a',
                :keyword, 'new',
                :one_or_more, :any_token ]
          end

          def bound_call_via_heard hrd, & oes_p

            bx = hrd.trio_box
            x = bx.remove :word

            s_a = x.value_x

            if 'a' == s_a.fetch( 1 )
              $stderr.puts "(FIX [#019])"
              s_a[ 1, 1 ] = EMPTY_A_
            end

            'new' == s_a.fetch( 1 ) or raise '(see #open [#019])'

            bx.add :args, s_a[ 2 .. -1 ]  # b.c above

            sess = Custom_Session___.new( bx, hrd.kernel, & oes_p )
            ok = sess.touch_workspace do
              ::Dir.pwd
            end
            ok &&= sess.touch_graph
            Brazen_.bound_call.via_value ok
          end

          class Custom_Session___

            def initialize bx, k, & oes_p
              @bx = bx
              @kernel = k
              @on_event_selectively = oes_p
            end

            def touch_workspace & path_p

              @bx.add :just_looking, Callback_::Pair[ true, :just_looking ]

              @ws = @kernel.silo( :workspace ).workspace_via_trio_box(
                @bx, & @on_event_selectively )

              if ! @ws
                __create_ws_at_path path_p[]
              end

              @ws && ACHIEVED_
            end

            def __create_ws_at_path path

              @ws = @kernel.silo( :workspace ).call :init,
                :trio_box, @bx,
                :with, :path, path, & @on_event_selectively

              @ws and ACHIEVED_
            end

            def touch_graph

              bx = Callback_::Box.new
              bx.add :workspace, @ws

              _f = __produce_some_graph_filehandle

              @kernel.silo( :graph ).call :use,
                :preconditions, bx,
                :with, :digraph_path, _f, # #open [#016] ..
                & @on_event_selectively
            end

            def __produce_some_graph_filehandle

              s_a = @bx[ :args ].reduce [] do | m, s |
                s_ = s.gsub( RX__, EMPTY_S_ )
                if s_.length.nonzero?
                  m.push s_
                end
                m
              end

              filename = if s_a.length.zero?
                'my-graph'
              else
                s_a.join DASH_
              end

              _candidate = if ::File::SEPARATOR == filename[ 0 ]
                filename
              else
                ::File.join @ws.existent_surrounding_path, filename
              end

              __produce_first_available_filehandle _candidate
            end

            def __produce_first_available_filehandle abspath_base

              # 'foo.ext', 'foo-02.ext' .. 'foo-010.ext', 'foo-011.ext'

              ext = ::File.extname abspath_base
              if ext.length.zero?
                ext = TanMan_::Models_::DotFile::DEFAULT_EXTENSION
              else
                abspath_base = abspath_base[ 0 .. - ext.length - 1 ]
              end

              TanMan_.lib_.system.filesystem.flock_first_available_path(

                :first_item_does_not_use_number,
                :beginning_width, 2,

                :template, '{{ head }}{{ separator if ID }}{{ ID }}{{ tail }}',
                :head, abspath_base,
                :tail, ext,
                :separator, DASH_ )
            end

            RX__ = /[^[:alnum:]]+/
          end
        end
      end
    end
  end
end
