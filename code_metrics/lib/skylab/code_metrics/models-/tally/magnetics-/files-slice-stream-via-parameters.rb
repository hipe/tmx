module Skylab::CodeMetrics

  class Models_::Tally

    class Magnetics_::Files_Slice_Stream_via_Parameters

      attr_writer(
        :chunk_size,
        :ignore_paths,
        :name_patterns,
        :paths,
        :system_conduit,
      )

      def initialize( & oes_p )
        @ignore_paths = nil
        @name_patterns = nil
        @_on_event_selectively = oes_p
      end

      def execute
        @chunk_size ||= 10

        if _nonzero_length_array @paths
          ___execute
        end
      end

      def ___execute  # assume nonzero paths

        ___init_command

        i, o, e, w = @system_conduit.popen3( * @_command )
        i.close

        chunk_size = @chunk_size
        chunk = -> do

          cache = []
          begin

            s = o.gets
            if s
              s.chomp!
              cache.push s
              if chunk_size == cache.length
                break
              end
              redo
            end

            s = e.gets
            while s

              -> s_ do

                # (allow this event to be re-played. let the string preserve)

                @_on_event_selectively.call :info, :expression, :from_find do | y |
                  y << s_
                end
              end.call s

              s = e.gets
            end

            chunk = EMPTY_P_

          end while nil

          if cache.length.zero?
            NIL_
          else
            cache
          end
        end

        Common_::Stream.new w do
          chunk[]
        end
      end

      def ___init_command  # assume nonzero paths

        @_command = [ COMMAND_NAME___ ]

        ___add_paths

        @_command.push TYPE_SWITCH___, FILE_TYPE___

        if _nonzero_length_array @name_patterns
          __add_name_patterns
        end

        if _nonzero_length_array @ignore_paths
          __add_ignore_paths
        end
        NIL_
      end

      COMMAND_NAME___ = 'find'
      FILE_TYPE___ = 'f'
      TYPE_SWITCH___ = '-type'

      def ___add_paths  # assume nonzero paths

        dirty_paths, clean_paths = @paths.partition do | path |
          FUNNY_LOOKING_PATH_RX___ =~ path
        end

        dirty_paths.each do | path |
          @_command.push SPECIFY_FILE_HIERARCHY_SWITCH___, path
        end

        clean_paths.each do | path |
          @_command.push path
        end

        NIL_
      end

      FUNNY_LOOKING_PATH_RX___ = /\A-/
      SPECIFY_FILE_HIERARCHY_SWITCH___ = '-f'

      def __add_name_patterns  # assume nonzero

        _express_list NAME_SWITCH__, @name_patterns
      end

      NAME_SWITCH__ = '-name'

      def __add_ignore_paths

        @_command.push NOT___
        _express_list PATH___, @ignore_paths
      end

      NOT___ = '-not'
      PATH___ = '-path'

      def _express_list switch, a

        more_than_one = 1 < a.length

        if more_than_one
          @_command.push OPEN_PAREN___
        end

        st = Common_::Stream.via_nonsparse_array a

        _x = st.gets

        @_command.push switch, _x

        begin
          x = st.gets
          x or break
          @_command.push OR__, switch, x
          redo
        end while nil

        if more_than_one
          @_command.push CLOSE_PAREN___
        end

        NIL_
      end

      CLOSE_PAREN___ = ')'
      OPEN_PAREN___ = '('
      OR__ = '-or'

      def _nonzero_length_array x

        x && x.length.nonzero?
      end
    end
  end
end
