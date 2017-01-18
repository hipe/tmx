module Skylab::Git

  class Models_::Stow

    class Models_::Tree_Stat

      # of a filesystem "tree" (directory), conceptualize it as something
      # like a commit in a project, one that can be displayed in a manner
      # similar to the output of `git show --stat`

      def initialize s, rsc, & oes_p

        @resources = rsc
        @stow_path = s
        @on_event_selectively = oes_p
      end

      def to_styled_line_stream

        _line_a = __build_line_array :in_color
        Common_::Stream.via_nonsparse_array _line_a
      end

      def __build_line_array do_colorize

        combined_max = 0
        name_max = 0
        plusminus_width = 40
        total_deletes = 0
        total_inserts = 0

        stat_a = []
        _st = _to_stat_stream
        _st.each do | o |
          stat_a.push o

          total_deletes += o.deletions
          total_inserts += o.insertions

          if name_max < o.name.length
            name_max = o.name.length
          end

          if combined_max < o.combined
            combined_max = o.combined
          end
        end

        if plusminus_width > combined_max
          plusminus_width = combined_max  # do not scale down with small numbers
        end

        col2width = combined_max.to_s.length

        fmt = "%-#{ name_max }s | %#{ col2width }s %s"

        if combined_max.zero?
          combined_max = 1  # avoid divide by zero, won't matter at this point to change it
        end

        lines = []

        stat_a.each do | o |

          num_pluses = (o.insertions.to_f / combined_max * plusminus_width).ceil # have at least 1 plus if nonzero
          num_minuses = (o.deletions.to_f / combined_max * plusminus_width).ceil

          pluses =  '+' * num_pluses
          minuses = '-' * num_minuses

          if do_colorize
            pluses = Stylify__[ PLUSES_STYLE___, pluses ]
            minuses = Stylify__[ MINUSES_STYLE___, minuses ]
          end

          lines << ( fmt % [ o.name, o.combined, "#{ pluses }#{ minuses }" ] )
        end

        lines << (
          "%s files changed, %d insertions(+), %d deletions(-)" %
          [ stat_a.length, total_inserts, total_deletes ] )

        lines
      end

      Stylify__ = -> do

        p = -> sym_a, s do
          p = Home_.lib_.zerk::CLI::Styling::Stylify
          p[ sym_a, s ]
        end
        -> sym_a, s do
          p[ sym_a, s ]
        end
      end.call

      PLUSES_STYLE___ = [ :green ]
      MINUSES_STYLE___ = [ :red ]

      def to_non_styled_patch_line_stream

        _to_item_stream.expand_by do | item |

          item.to_any_non_styled_patch_line_stream
        end
      end

      def to_styled_patch_line_stream

        _to_item_stream.expand_by do | item |

          item.to_any_styled_patch_line_stream
        end
      end

      def _to_stat_stream

        _to_item_stream.map_reduce_by do | item |
          item.to_any_file_stat
        end
      end

      def to_item_stream
        _to_item_stream
      end

      def _to_item_stream

        item_p = Models_::Item.curry(
          @stow_path,
          @resources,
          & @on_event_selectively )

        _, o, e, w = @resources.system_conduit.popen3(
          * ITEMS_STREAM_COMMAND___,
          chdir: @stow_path )

        p = -> do

          s = e.gets
          if s
            self._COVER_ME
          else
            p = -> do
              s = o.gets
              if s
                s.chop!
                item_p[ s ]
              else
                d = w.value.exitstatus
                if d.zero?
                  p = EMPTY_P_
                  NIL_
                else
                  self._COVER_ME
                end
              end
            end
            p[]
          end
        end

        Common_.stream do
          p[]
        end
      end

      ITEMS_STREAM_COMMAND___ = [ 'find', '.', '-type', 'f' ]
    end
  end
end
