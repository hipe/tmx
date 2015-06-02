module Skylab::Cull

  class Models_::Upstream

    class Actors__::Produce_adapter

      Callback_::Actor.methodic self, :simple, :properties, :properties,

        :derelativizer,
        :table_number,
        :upstream,
        :upstream_adapter

      define_singleton_method :[], VALUE_BOX_EXPLODER_CALL_METHOD_

      def execute

        @md = /\A(?<prefix>[a-z0-9-]+):(?<arg>.+)/.match @upstream

        if @md
          @prefix = @md[ :prefix ]
          @arg = @md[ :arg ]
          via_prefix
        else
          via_path
        end
      end

      def via_path
        if ::File::SEPARATOR == @upstream[ 0 ]
          @prefix = :file
          @arg = @upstream
          via_prefix
        else
          when_relpath @upstream
        end
      end

      def via_prefix

        m = :"process_as_#{ @prefix }_identifier_string"

        if respond_to? m
          send m, @arg
        else
          when_prefix
        end
      end

      def when_prefix
        maybe_send_event :error, :invalid_prefix do

          Brazen_::Property.build_extra_values_event(
            [ @prefix ],
            get_available_prefixes,
            'prefix' )
        end
      end

      include Simple_Selective_Sender_Methods_

      def get_available_prefixes
        rx = /\Aprocess_as_([a-z_0-9]+)_identifier_string\z/
        self.class.instance_methods( false ).reduce [] do | m, x |
          md = rx.match x
          if md
            m.push md[ 1 ]
          end
          m
        end
      end

      public def process_as_file_identifier_string str
        path = __via_derelativizer_absolutize_path str
        path and process_as_file_absolute_path path
      end

      def __via_derelativizer_absolutize_path str
        if str
          if str.length.zero?
            UNABLE_
          elsif ::File::SEPARATOR == str[ 0 ]
            str
          else
            if @derelativizer
              x = @derelativizer.derelativize str
            end
            x or when_relpath str
          end
        else
          str
        end
      end

      def when_relpath path
        maybe_send_event :error, :path_must_be_absolute do
          build_not_OK_event_with :path_must_be_absolute, :path, path
        end
        UNABLE_
      end

      def process_as_file_absolute_path path

        fs = Cull_.lib_.filesystem

        _ok = fs.normalization.upstream_IO(
          :path, path,
          :only_apply_expectation_that_path_is_ftype_of, fs.constants::FILE_FTYPE,
          & @on_event_selectively )

        _ok and when_path_resolved_as_valid_one_time path
      end

      def when_path_resolved_as_valid_one_time path

        if @upstream_adapter
          via_upstream_adapter_via_path path
        else
          via_path_extension path
        end
      end

      # ~ pairs

      def via_path_extension path
        extname = ::File.extname path
        cls = __class_via_extension extname
        if cls
          adapter_via_path_and_class path, cls
        else
          when_bad_extension extname
        end
      end

      def __class_via_extension ext

        Upstream_::Adapters__.constants.reduce nil do | m, const |

          cls = Upstream_::Adapters__.const_get const, false

          cls::EXTENSIONS.include?( ext ) and break cls

        end
      end

      def via_upstream_adapter_via_path path

        cls = __class_via_const_guess Callback_::Name.
          via_variegated_symbol( @upstream_adapter ).as_const

        if cls
          adapter_via_path_and_class path, cls
        else
          when_bad_adapter @upstream_adapter
        end
      end

      def __class_via_const_guess x
        Autoloader_.const_reduce( [ x ], Upstream_::Adapters__ ) do  end
      end

      def when_bad_extension extname
        maybe_send_event :error, :invalid_extension do

          _s_a = get_upstream_adapters_names.map do | nm |
            ".#{ nm.as_slug }"
          end

          Brazen_::Property.build_extra_values_event(
            [ extname ],
            _s_a,
            'extension' )

        end
        UNABLE_
      end

      def when_bad_adapter sym
        maybe_send_event :error, :invalid_adapter do

          _s_a = get_upstream_adapters_names.map do | nm |
            nm.as_lowercase_with_underscores_symbol
          end

          Brazen_::Property.build_extra_values_event(
            [ sym ],
            _s_a,
            'upstream adapter' )

        end
        UNABLE_
      end

      def get_upstream_adapters_names

        Upstream_::Adapters__.constants.reduce [] do | m, x |
          m.push Callback_::Name.via_const x
          m
        end
      end

      # ~ end pairs

      def adapter_via_path_and_class path, cls
        if @table_number
          cls.via_table_number_and_path @table_number, path, & @on_event_selectively
        else
          cls.via_path path, & @on_event_selectively
        end
      end
    end
  end
end
