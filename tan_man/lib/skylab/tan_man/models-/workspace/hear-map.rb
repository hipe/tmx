module Skylab::TanMan

  class Models_::Workspace

    module HearMap

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

          def execute_via_heard hrd, & p

            bx = hrd.qualified_knownness_box
            x = bx.remove :word

            s_a = x.value

            if 'a' == s_a.fetch( 1 )
              self._HELLO__readme__  # (this used to be a fix for [#019] #tombstone)
              s_a[ 1, 1 ] = EMPTY_A_
            end

            'new' == s_a.fetch( 1 ) or raise '(see #open [#019])'

            bx.add :args, s_a[ 2 .. -1 ]  # b.c above

            sess = Custom_Session___.new( bx, hrd.kernel, & p )
            ok = sess.touch_workspace do
              ::Dir.pwd
            end
            ok &&= sess.touch_graph
            Common_::BoundCall.via_value ok
          end

          class Custom_Session___

            def initialize bx, k, & p
              @bx = bx
              @kernel = k
              @listener = p
            end

            def touch_workspace & path_p

              _pair = Common_::QualifiedKnownKnown.via_value_and_symbol true, :just_looking
              @bx.add :just_looking, _pair

              @ws = @kernel.silo( :workspace ).workspace_via_qualified_knownness_box(
                @bx, & @listener )

              if ! @ws
                __create_ws_at_path path_p[]
              end

              @ws && ACHIEVED_
            end

            def __create_ws_at_path path

              @ws = @kernel.silo( :workspace ).call :init,
                :qualified_knownness_box, @bx,
                :with, :path, path, & @listener

              @ws and ACHIEVED_
            end

            def touch_graph

              bx = Common_::Box.new
              bx.add :workspace, @ws

              _f = __produce_some_graph_filehandle

              @kernel.silo( :graph ).call :use,
                :preconditions, bx,
                :with, :digraph_path, _f, # #open [#016] ..
                & @listener
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
                ext = Home_::Models_::DotFile::DEFAULT_EXTENSION
              else
                abspath_base = abspath_base[ 0 .. - ext.length - 1 ]
              end

              Home_.lib_.system.filesystem.flock_first_available_path(

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
