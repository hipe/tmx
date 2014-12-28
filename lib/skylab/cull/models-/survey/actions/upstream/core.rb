module Skylab::Cull

  class Models_::Survey

    class Actions::Upstream < Model_

      def initialize srv
        @survey = srv
        super
      end

    private

      def first_edit_shell
        self
      end

      public def via_mutable_arg_box bx

        @___argument_string___ = bx[ :upstream_identifier ].value_x

        nil
      end

      def process_first_edit _

        md = /\A([^:]*):?(.+)?\z/.match @___argument_string___

        @___argument_string___ = nil

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
        path = via_survey_dir_absolutize_path str
        path and process_as_file_absolute_path path
      end

      include Simple_Selective_Sender_Methods_

      include Survey_Action_Methods_

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

    public

      def to_event
        @_adapter.to_descriptive_event
      end

      def marshal_dump
        @_adapter.marshal_dump_for_survey @survey
      end

      if false

  class Models::Data::Source::Collection

    CodeMolester::Config::File::Entity::Collection.enhance self do

      with Models::Data::Source

      add

      list_as_json

    end
  end

  class Models::Data::Source::Controller

    CodeMolester::Config::File::Entity::Controller.enhance self do

      with Models::Data::Source

      add

    end
  end
      end

      FILE_FTYPE_ = 'file'

      Upstream_ = self
    end
  end
end
