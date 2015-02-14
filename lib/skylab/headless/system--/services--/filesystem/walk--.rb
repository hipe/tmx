module Skylab::Headless

  module System__

    class Services__::Filesystem

      class Walk__  # :[#176] (was [#ts-019], then [#st-007]. was once tagged [#cu-003])

        class << self
          def new_with * x_a, & oes_p  # :+[#cb-063]
            new do
              process_iambic_fully x_a
              @on_event_selectively ||= oes_p
            end
          end
        end

        Callback_::Actor.call self,
          :properties,
            :start_path,
            :filename,
            :ftype,
            :max_num_dirs_to_look,
            :prop,
            :property_symbol,
            :on_event_selectively

        Callback_::Event.selective_builder_sender_receiver self

        def initialize & edit_p
          @ftype = @prop = @property_symbol = nil
          super( & edit_p )
        end

        FILE__ = 'file'.freeze

        def find_any_nearest_file_pathname  # :+#public-API
          execute
        end

        def execute
          normalize_ivars
          work
        end

      private

        def normalize_ivars
          if SLASH_ != @start_path.getbyte( 0 )
            @start_path = ::File.expand_path @start_path
          end
          @start_pathname = ::Pathname.new @start_path
        end

        SLASH_ = '/'.getbyte 0

        def work
          st, e = stat_and_stat_error
          if st
            if DIRECTORY_FTYPE == st.ftype
              fnd_any_nearest_file_pathname_when_start_pathname_exist
            else
              whn_start_directory_is_not_directory st
            end
          else
            whn_start_directory_does_not_exist e
          end
        end

        def stat_and_stat_error
          ::File::Stat.new @start_path
        rescue ::Errno::ENOENT => e
          [ nil, e ]
        end

        def whn_start_directory_is_not_directory st
          maybe_send_event :error, :start_directory_is_not_directory do
            build_not_OK_event_with :start_directory_is_not_directory,
              :start_pathname, @start_pathname, :ftype, st.ftype,
                :prop, prp
          end
        end

        def whn_start_directory_does_not_exist e
          maybe_send_event :error, :start_directory_is_not_directory do
            build_not_OK_event_with :start_directory_does_not_exist,
              :start_pathname, @start_pathname, :exception, e,
                :prop, prp
          end
        end

        def fnd_any_nearest_file_pathname_when_start_pathname_exist
          count = 0

          continue_searching = if -1 == @max_num_dirs_to_look
            NILADIC_TRUTH_
          else
            -> { count < @max_num_dirs_to_look }
          end
          pn = @start_pathname
          while continue_searching[]
            count += 1
            try = pn.join @filename
            if try.exist?
              found_path = try.to_path
              surrounding_path = pn.to_path
              break
            end
            try.exist? and break( found_path = try )
            pn_ = pn.dirname
            pn_ == pn and break  # we've reached the top - the root path
            pn = pn_
          end
          if found_path
            whn_found found_path, surrounding_path
          else
            whn_resource_not_found count
          end
        end

        def whn_found found_path, surrounding_path

          _ok = Headless_.system.filesystem.normalization.upstream_IO(
              :only_apply_expectation_that_path_is_ftype_of, ( @ftype || FILE_FTYPE___ ),
              :path, found_path ) do | * i_a, & ev_p |

            ev = ev_p[]
            maybe_send_event normal_top_channel_via_OK_value ev.ok do
              ev
            end
            UNABLE_
          end

          _ok && surrounding_path
        end

        FILE_FTYPE___ = 'file'.freeze

        def whn_resource_not_found count
          maybe_send_event :error, :resource_not_found do
            bld_resource_not_found_event count
          end
        end

        def bld_resource_not_found_event count
          build_not_OK_event_with :resource_not_found, :filename, @filename,
              :num_dirs_looked, count, :start_pathname, @start_pathname do |y, o|
            if o.num_dirs_looked.zero?
              y << "no directories were searched."
            else
              if 1 < o.num_dirs_looked
                d = o.num_dirs_looked - 1
                x = " or #{ d } dir#{ s d } up"
              end
              y << "#{ ick o.filename } not found in #{ pth o.start_pathname}#{x}"
            end
          end
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
      end
    end
  end
end
