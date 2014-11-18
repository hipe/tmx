module Skylab::MetaHell

  module Boxxy

    module Peeker_

      # absurd - read the first few lines of a file (not load it, that might
      # break autoloading) to determine the correct casing of its constants.
      # dark hacks only.

      Tug = -> tug do
        any_expensive_correction = nil
        tug.respond_to? :autovivify_proc_notify or fail ::ArgumentError,
          "your module has an unsupported tug class (do you need MAARS?) - #{
            }had #{ tug.class } for #{ tug.mod }"
        tug.autovivify_proc_notify -> do
          cmd_s = Build_find_command__[ tug ]
          _, o, e, w = MetaHell_::Library_::Open3.popen3 cmd_s
          d = w.value.exitstatus
          0 == d or fail "sanity - exitstatus from cmd? #{ d.inspect }"
          err_s = e.read ; out_s = o.read
          err_s.length.zero? or fail "sanity - err from cmd? #{err_s.inspect}"
          if out_s.length.nonzero?
            any_expensive_correction =
              Any_correction_from_massive_hack__[ tug, out_s.chomp ]
          end
          # then do what parent does
          tug.mod.const_set tug.const, tug.build_autovivified_module
        end
        any_other_correction = Tug_and_get_any_correction_[ tug, nil ]
        if any_expensive_correction
          any_other_correction and fail "sanity - why did the other correct it?"
          any_expensive_correction
        else
          any_other_correction
        end
      end

      Build_find_command__ = -> tug do
        MetaHell_::Library_.kick :Shellwords
        "find #{ tug.branch_pathname.to_s.shellescape } -type f #{
          }-name #{ "*#{ Autoloader::EXTNAME }".shellescape } | head -n 1"
      end

      Any_correction_from_massive_hack__ = -> tug, path do
        c_a = MetaHell_::Library_::CodeMolester::Const_Pryer[ path ]
        # the file that was found with `find` is of arbitrary depth.
        shorter = tug.branch_pathname.to_s
        path[ 0, shorter.length ] == shorter or fail "sanity"
        depth = Number_of_occurences_in_haystack_of_needle__[
          path[ shorter.length .. -1 ], '/' ]
        depth.times { c_a.pop }
        c_a.length.zero? and fail "sanity"
        any_expensive_correction = nil
        if c_a.last != tug.const
          tug.correction_notification( any_expensive_correction =  c_a.last )
        end
        any_expensive_correction
      end

      Number_of_occurences_in_haystack_of_needle__ = -> str, char do
        # because `scan` wastes memory HA
        d = 0 ; cnt = 0 ; len = str.length ; ln = char.length
        while d < len
          idx = str.index( char, d ) or break
          cnt += 1 ; d = idx + ln
        end
        cnt
      end
    end
  end
end
