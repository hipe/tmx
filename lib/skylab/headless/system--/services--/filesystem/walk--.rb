module Skylab::Headless

  module System__

    class Services__::Filesystem

      class Walk__  # :[#176] (was [#ts-019], then [#st-007]. was once tagged [#cu-003])

        class << self

          def build_resource_not_found_event start_path, file_pattern_x, num_dirs_looked

            Build_resource_not_found_event__[ start_path, file_pattern_x, num_dirs_looked ]
          end

          def new_with * x_a, & oes_p  # :+[#cb-063]
            new do
              oes_p and @on_event_selectively = oes_p
              process_iambic_fully x_a
            end
          end
        end  # >>

        Callback_::Actor.call self,
          :properties,
            :start_path,
            :filename,
            :filename_rx,
            :ftype,
            :max_num_dirs_to_look,
            :prop,
            :property_symbol

        Callback_::Event.selective_builder_sender_receiver self

        def initialize & edit_p
          @ftype = @prop = @property_symbol = nil
          super( & edit_p )
        end

        def find_any_nearest_surrounding_path  # :+#public-API
          execute
        end

        def execute
          __init_ivars
          __work
        end

      private

        def __init_ivars
          if FILE_SEPARATOR_BYTE != @start_path.getbyte( 0 )
            @start_path = ::File.expand_path @start_path
          end
          nil
        end

        def __work
          st, e = __stat_and_stat_error
          if st
            if DIRECTORY_FTYPE == st.ftype
              __find_any_nearest_file_when_start_path_exist
            else
              __when_start_directory_is_not_directory st
            end
          else
            __when_start_directory_does_not_exist e
          end
        end

        def __stat_and_stat_error
          ::File::Stat.new @start_path
        rescue ::Errno::ENOENT => e
          [ nil, e ]
        end

        def __when_start_directory_is_not_directory st
          maybe_send_event :error, :start_directory_is_not_directory do
            build_not_OK_event_with :start_directory_is_not_directory,
              :start_path, @start_path, :ftype, st.ftype,
                :prop, prp
          end
        end

        def __when_start_directory_does_not_exist e
          maybe_send_event :error, :start_directory_is_not_directory do
            build_not_OK_event_with :start_directory_does_not_exist,
              :start_path, @start_path, :exception, e,
                :prop, prp
          end
        end

        def __find_any_nearest_file_when_start_path_exist

          count = 0

          continue_searching = if -1 == @max_num_dirs_to_look
            NILADIC_TRUTH_
          else
            -> { count < @max_num_dirs_to_look }
          end

          path = @start_path

          while continue_searching[]
            count += 1
            try = ::File.join path, @filename
            if ::File.exist? try
              found_path = try
              surrounding_path = path
              break
            end
            path_ = ::File.dirname path
            path_ == path and break  # we've reached the top (root path)
            path = path_
          end

          if found_path
            __found found_path, surrounding_path
          else
            __when_resource_not_found count
          end
        end

        def __found found_path, surrounding_path

          _ok = Headless_.system.filesystem.normalization.upstream_IO(
              :only_apply_expectation_that_path_is_ftype_of, ( @ftype || FILE_FTYPE ),
              :path, found_path, & @on_event_selectively )

          _ok && surrounding_path
        end

        def __when_resource_not_found count
          maybe_send_event :error, :resource_not_found do
            __build_resource_not_found_event count
          end
        end

        def __build_resource_not_found_event count
          Build_resource_not_found_event__[ @start_path, @filename, count ]
        end

        def prp
          @prop or bld_property
        end

        def bld_property
          sym = @property_symbol || :path
          Callback_::Actor.methodic_lib.simple_property_class.new do
            @name = Callback_::Name.via_variegated_symbol sym
          end
        end

        Build_resource_not_found_event__ = -> start_path, file_pattern_x, num_dirs_looked do

          Callback_::Event.inline_not_OK_with( :resource_not_found,

              :start_path, start_path,
              :file_pattern_x, file_pattern_x,
              :num_dirs_looked, num_dirs_looked,

          ) do | y, o |

            if o.num_dirs_looked.zero?
              y << "no directories were searched."
            else
              if 1 < o.num_dirs_looked
                d = o.num_dirs_looked - 1
                _xtra = " or #{ d } dir#{ s d } up"
              end
              y << "#{ ick o.file_pattern_x } #{
                }not found in #{ pth o.start_path }#{ _xtra }"
            end
          end
        end

        Walk_ = self
      end
    end
  end
end
