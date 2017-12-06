module Skylab::Cull

  module Models_::Upstream

    class Adapter_via_ActionArguments___ < Common_::MagneticBySimpleModel

      def initialize
        @_execute = :_execute_normally
        @table_number = nil
        @upstream_adapter_symbol = nil
        super
      end

      def these_name_value_pairs= nv_st
        @_execute = :__execute_experimentally
        @__primitive_name_value_pair_stream = nv_st
      end

      def execute
        send @_execute
      end

      def __execute_experimentally
        # just a rough sketch experiment. belongs somewhere else.

        ok = true
        nv_st = remove_instance_variable :@__primitive_name_value_pair_stream
        h = THESE___
        extra_ks = nil
        begin
          nv = nv_st.gets
          nv || break
          m = h[ nv.name_symbol ]
          if ! m
            ok = false
            ( extra_ks ||= [] ).push nv.name_symbol
            redo
          end
          ok_ = send m, nv
          if ! ok_
            ok = false
          end
          redo
        end while above
        if ok
          # #cov1.3
          _execute_normally
        elsif extra_ks
          @listener.call :error, :expression, :unrecognized_associations do |y|
            simple_inflection do
              buff = oxford_join Scanner_[ extra_ks ] do |sym|
                humanize( sym ).inspect
              end
              y << "\"upstream\" doesn't have #{
                }#{ this_or_these } #{ n "association" }: #{ buff }"
            end
          end
          UNABLE_
        end
      end

      THESE___ = {
        table_number: :__table_number,
        adapter: :__adapter,
        upstream: :__upstream,
      }

      def __table_number nv
        x = nv.value
        if x.respond_to? :bit_length
          @table_number = x ; true
        else
          @listener.call( :error, :expression, :primitive_type_error ) { |y| y << "table number is not integer" }
          UNABLE_
        end
      end

      def __adapter nv
        x = nv.value
        @upstream_adapter_symbol = x.to_s.intern  # yikes/meh
        ACHIEVED_
      end

      def __upstream nv
        @upstream_string = nv.value  # (we happen to know that this must be a string)
        ACHIEVED_
      end

      attr_writer(
        :derelativize_by,
        :filesystem,
        :listener,
        :table_number,
        :upstream_string,
        :upstream_adapter_symbol,
      )

      def _execute_normally

        @md = /\A(?<prefix>[a-z0-9-]+):(?<arg>.+)/.match @upstream_string

        if @md
          @prefix = @md[ :prefix ]
          @arg = @md[ :arg ]
          _via_prefix
        else
          __via_path
        end
      end

      def __via_path
        s = @upstream_string
        if Path_looks_absolute_[ s ]
          @prefix = :file
          @arg = x
          _via_prefix
        else
          _when_relpath s
        end
      end

      def _via_prefix

        m = :"__process_as__#{ @prefix }__identifier_string"  # also #here1

        if respond_to? m
          send m, @arg
        else
          __when_prefix
        end
      end

      def __when_prefix

        @listener.call :error, :invalid_prefix do

          _s_a = __get_available_prefixes

          Home_.lib_.fields::Events::Extra.with(
            :unrecognized_token, @prefix,
            :did_you_mean_tokens, _s_a,
            :noun_lemma, "prefix",
          )
        end

        UNABLE_
      end

      def __get_available_prefixes
        rx = /\A__process_as__([a-z_0-9]+)__identifier_string\z/  # also #here1
        self.class.instance_methods( false ).reduce [] do | m, x |
          md = rx.match x
          if md
            m.push md[ 1 ]
          end
          m
        end
      end

      def __process_as__file__identifier_string str
        @_unsanitized_path = str
        ok = __via_derelativizer_absolutize_path
        ok &&= __check_that_absolute_path_is_file
        ok && __via_absolute_path_that_exists
      end

      def __via_derelativizer_absolutize_path
        s = @_unsanitized_path
        if ! s
          UNABLE_  # hi.
        elsif s.length.zero?
          UNABLE_  # hi.
        elsif Path_looks_absolute_[ s ]
          @_absolute_path = remove_instance_variable :@_unsanitized_path ; true
        else
          p = @derelativize_by
          s = remove_instance_variable :@_unsanitized_path
          if p
            x = p[ s ]
          end
          if _store :@_absolute_path, x
            ACHIEVED_
          else
            _when_relpath s
          end
        end
      end

      def _when_relpath path

        @listener.call :error, :path_must_be_absolute do
          Build_not_OK_event_[ :path_must_be_absolute, :path, path ]
        end
        UNABLE_
      end

      def __check_that_absolute_path_is_file

        _yes = Home_.lib_.system_lib::Filesystem::Normalizations::Upstream_IO.via(
          :path, @_absolute_path,
          :must_be_ftype, :FILE_FTYPE,
          :filesystem, @filesystem,
          & @listener )

        _yes  # hi. #todo
      end

      def __via_absolute_path_that_exists

        if __resolve_adapter_class
          __adapter_via_adapter_class
        end
      end

      def __resolve_adapter_class
        if @upstream_adapter_symbol
          __resolve_adapter_class_via_upstream_adapter
        else
          __resolve_adapter_class_via_path_extension
        end
      end

      # -- (begin pairs)

      # ~ via absolute path and X (2x)

      def __resolve_adapter_class_via_path_extension
        @_extname = ::File.extname @_absolute_path
        if __resolve_adapter_class_via_extension
          ACHIEVED_
        else
          __when_bad_extension
        end
      end

      def __resolve_adapter_class_via_extension

        _ = Here_::Adapters__.constants.reduce nil do |m, const|

          cls = Here_::Adapters__.const_get const, false

          if cls::EXTENSIONS.include? @_extname
            break cls
          end
        end

        _store :@_adapter_class, _
      end

      def __resolve_adapter_class_via_upstream_adapter

        _c = Common_::Name.via_variegated_symbol( @upstream_adapter_symbol ).as_const

        cls = Autoloader_.const_reduce( _c, Here_::Adapters__ ) { NOTHING_ }

        if _store :@_adapter_class, cls
          ACHIEVED_
        else
          __when_bad_upstream_adapter
        end
      end

      # ~ when bad X (2x)

      def __when_bad_extension

        extname = remove_instance_variable :@_extname

        @listener.call :error, :invalid_extension do

          _s_a = _sorted_upstream_adapters_names.map do | nm |
            ".#{ nm.as_slug }"
          end

          Home_.lib_.fields::Events::Extra.with(
            :unrecognized_token, extname,
            :did_you_mean_tokens, _s_a,
            :noun_lemma, "extension",
          )
        end

        UNABLE_
      end

      def __when_bad_upstream_adapter

        ::Kernel._REVIEW

        sym = @upstream_adapter_symbol

        @listener.call :error, :invalid_adapter do

          _s_a = _sorted_upstream_adapters_names.map do | nm |
            nm.as_lowercase_with_underscores_symbol
          end

          self._REVEIW
          Home_.lib_.fields::Events.new [ sym ], _s_a, "upstream adapter"
        end

        UNABLE_
      end

      def _sorted_upstream_adapters_names
        These___[]
      end

      These___ = Lazy_.call do

        name_a = Here_::Adapters__.constants.map do |const|
          Common_::Name.via_const_symbol const
        end

        name_a.sort_by! do |name|
          name.as_const
        end

        name_a.freeze
      end

      # -- (end pairs)

      def __adapter_via_adapter_class
        d = @table_number
        path = remove_instance_variable :@_absolute_path
        if d
          d.bit_length || self._SANITY__this_should_have_been_normalized_by_not
          @_adapter_class.via_table_number_and_path x, path, & @listener
        else
          @_adapter_class.via_path path, & @listener
        end
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # ==

      Path_looks_absolute_ = -> path do
        _yes = Home_.lib_.system.filesystem.path_looks_absolute path
        _yes  # hi. #todo
      end

      # ==
      # ==
    end
  end
end
