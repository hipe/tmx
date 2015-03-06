module Skylab::SubTree

  module Models_::File_Coverage

    class Actors_::Find_the_test_directory

      # our algorithm is particular enough that it can be served neither by
      # [hl]'s "walk" nor by `::File#glob` - neither of these has a built-in
      # way to match against an alternation of fixed strings ("foo" or "bar").
      #
      # since we are using `find` anyway, we go ahead and add the critera
      # of ftype=directory, and use regex as a broader solution.
      #
      # if ever this is needed elsewhere, push it up to [#hl-176]

      Callback_::Actor.call self, :properties,

        :filenames,
        :start_path,
        :be_verbose,
        :max_num_dirs_to_look

      def execute
        __init_find

        current_path = @start_path
        num_times_looked = 0
        max_times = @max_num_dirs_to_look

        ok = true
        begin

          if max_times == num_times_looked
            hit_max = true
            break
          end

          num_times_looked += 1

          ok = __hit_the_system current_path
          ok or break

          if @did_find
            break
          end

          current_path_ = ::File.dirname current_path
          if current_path_ == current_path
            hit_top = true
            break
          end

          current_path = current_path_
          redo
        end while nil

        if ! ok
          ok
        elsif hit_max || hit_top
          __when_not_found num_times_looked
        else
          @found_path
        end
      end

      def __when_not_found num_dirs_looked
        @on_event_selectively.call :error, :resource_not_found do
          SubTree_.lib_.system.filesystem.walk.build_resource_not_found_event(
            @start_path,
            @filenames,
            num_dirs_looked )
        end
      end

      def __init_find

        _fs = SubTree_.lib_.system.filesystem

        @find = _fs.find.new_with(
          :filenames, @filenames,  # "always safe"
          :freeform_query_infix_words, %w( -type dir -maxdepth 1 )
        ) do | * i_a, & ev_p |
          case i_a.last
          when :find_command_args
            if @be_verbose
              @on_event_selectively[ * i_a, & ev_p ]
            end
          else
            @on_event_selectively[ * i_a, & ev_p ]
          end
        end

        NIL_
      end

      def __hit_the_system current_path

        @did_find = false

        st = @find.new_with( :path, current_path ).to_path_stream

        if st
          one = st.gets
          if one
            two = st.gets
            if two
              self._COVER_ME_the_ambiguity_case
            else
              @did_find = true
              @found_path = one
              ACHIEVED_
            end
          else
            # assume @did_find is false
            ACHIEVED_
          end
        else
          st
        end
      end
    end
  end
end
