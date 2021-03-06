module Skylab::TestSupport
  # -
    class Magnetics::TestDirectory_via_Path

      # our algorithm is particular enough that it can be served neither by
      # [hl]'s "walk" nor by `::File#glob` - neither of these has a built-in
      # way to match against an alternation of fixed strings ("foo" or "bar").
      #
      # since we are using `find` anyway, we go ahead and add the critera
      # of ftype=directory, and use regex as a broader solution.
      #
      # if ever this is needed elsewhere, push it up to [#sy-018]

      Attributes_actor_.call( self,
        :filenames,
        :start_path,
        :be_verbose,
        :max_num_dirs_to_look,
      )

      Filenames___ = Lazy_.call do
        [ Home_::Init.test_directory_entry_name ]
      end

      def initialize & p
        @be_verbose = false
        @listener = p
      end

      def execute

        @filenames ||= Filenames___[]

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

        @listener.call :error, :resource_not_found do

          Home_.lib_.system_lib::Filesystem::Walk.build_resource_not_found_event(
            @start_path,
            @filenames,
            num_dirs_looked,
          )
        end

        UNABLE_
      end

      def __init_find

        @find_was_OK = true

        _ = Home_.lib_.system.find

        @__find = _.with(
          :filenames, @filenames,  # "always safe"
          # == BEGIN GNU find has different syntax than BSD find YUCK
          # :freeform_query_infix_words, %w( -type dir -maxdepth 1 )
          :freeform_query_infix_words, %w( -maxdepth 1 -type d )
          # == END
        ) do | * i_a, & ev_p |

          yes = true
          if :error == i_a.first
            @find_was_OK = false
          elsif :find_command_args == i_a.last
            if ! @be_verbose
              yes = false
            end
          end
          if yes
            @listener[ * i_a, & ev_p ]
          end
          NIL
        end

        NIL_
      end

      def __hit_the_system current_path

        @did_find = false

        has_args = @__find.with(:path, current_path)
        st = has_args.to_path_stream_probably_ordered

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
            @find_was_OK
          end
        else
          st
        end
      end
    end
  # -
end
# #history-B.1: target Ubuntu not OS X
