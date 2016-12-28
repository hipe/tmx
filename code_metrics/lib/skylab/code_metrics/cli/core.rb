module Skylab::CodeMetrics

#== this is about to be ridiculous

  if ridiculous_
    @ridiculous_ = false

      PRIMARY_DESCRIPTIONS_ = {

        path: -> y do
          y << "typically one path"
          y << "one day many"
          y << "if you use globs, put them in single quotes"
        end,

        head_const: -> y do
          y << "necessary for some reason.."
        end,

        head_path: -> y do
          y << "hm.."
        end,

        require_path: -> y do
          y << "any path that you would require from a script"
          y << "can be expressed multiple times"
        end,

        verbose: -> y do
          y << "verbose output"
        end,

        ping: -> y do
          y << "to see if it's working"
        end,
      }

  else
#==
  Require_brazen_[]  # 2 of 2

  class CLI < Brazen_::CLI

    Add_lipstick_field_ = -> defn, column_for_count do

      ::Skylab::Zerk::CLI::HorizontalMeter.
          add_max_share_meter_field_to_table_design( defn ) do |o|

        o.for_input_at_offset column_for_count
        o.foreground_glyph PLUS___
        o.background_glyph SPACE_
      end
    end

    Flush_stream_into_ = -> out, out_st do
      begin
        line = out_st.gets
        line || break
        out.puts line
        redo
      end while above
    end

    HARD_CODED_WIDTH_ = 150
    PLUS___ = '+'
  end
  end  # ridiculous
end
# #tombstone: we used to have to do a lot of setup for lipsticker
