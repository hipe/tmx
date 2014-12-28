module Skylab::Cull

  class Models_::Upstream < Model_

      class First_Edit

        def initialize
          @bx = Callback_::Box.new
        end

        def reference_path x
          @bx.set :_any_ref_path, x
        end

        def shell sh
          sh.bx.each_pair do | i, x |
            @bx.set i, x
          end
          nil
        end

        def via_mutable_arg_box bx
          @bx.set :_up_id, bx[ :upstream_identifier ].value_x
        end

        attr_reader :bx
      end

      def first_edit_shell
        First_Edit.new
      end

      def process_first_edit sh

        bx = sh.bx

        @reference_path = bx[ :_any_ref_path ]

        md = /\A([^:]*):?(.+)?\z/.match bx[ :_up_id ]

        @prefix, identifier_string = md.captures

        m = :"process_as_#{ @prefix }_identifier_string"

        if respond_to? m
          send( m, identifier_string ) and self
        else
          when_prefix
        end
      end

      def when_prefix
        maybe_send_event :error, :invalid_prefix do

          Brazen_::Entity.properties_stack.build_extra_properties_event(
            [ @prefix ],
            get_available_prefixes,
            'prefix' )
        end
      end

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
        path = _via_reference_path_absolutize_path str
        path and process_as_file_absolute_path path
      end

      include Simple_Selective_Sender_Methods_

      def process_as_file_absolute_path path

        _ok = Cull_._lib.filesystem.normalization.upstream_IO(
          :path, path,
          :only_apply_expectation_that_path_is_ftype_of, FILE_FTYPE_,
          & @on_event_selectively )

        _ok and when_path_resolved_as_valid_one_time path
      end

      def when_path_resolved_as_valid_one_time path

        extname = ::File.extname path
        md = /(?<=\A\.)(.+)\z/.match extname
        if md
          const_guess = Callback_::Name.via_slug( md[ 0 ] ).as_const

          cls = Autoloader_.const_reduce(
            [ const_guess ],
            Upstream_::Adapters__ ) do | * i_a, & ev_p |

              when_bad_extension extname
          end

          cls and process_as_file_path_with_class( path, cls )
        else
          when_bad_extension extname
        end
      end

      def when_bad_extension extname

        maybe_send_event :error, :invalid_extension do

          _s_a = Upstream_::Adapters__.constants.reduce [] do | m, x |
            m.push ".#{ Callback_::Name.via_const( x ).as_slug }"
            m
          end

          Brazen_::Entity.properties_stack.build_extra_properties_event(
            [ extname ],
            _s_a,
            'extension' )

        end
        UNABLE_
      end

      def process_as_file_path_with_class path, cls

        adapter = cls.via_path path, & @on_event_selectively

        adapter and begin

          @_adapter = adapter
          ACHIEVED_
        end
      end

      def _via_reference_path_absolutize_path str
        if str
          if str.length.zero?
            UNABLE_
          elsif ::File::SEPARATOR == str[ 0 ]
            str
          elsif @reference_path
            ::File.join @reference_path, str
          else
            when_relpath str
          end
        else
          str
        end
      end

      def when_relpath path
        maybe_send_event :error, :no_relative_paths do
          build_not_OK_event_with :no_relative_paths, path
        end
        UNABLE_
      end

    public

      def marshal_dump_for_survey sur
        @_adapter.marshal_dump_for_survey_ sur
      end

      def to_event
        @_adapter.to_descriptive_event
      end


      FILE_FTYPE_ = 'file'

      Upstream_ = self

  end
end
