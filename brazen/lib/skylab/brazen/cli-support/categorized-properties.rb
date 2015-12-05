module Skylab::Brazen

  module CLI_Support

    class Categorized_Properties  # [#002]note-600

      class << self

        def begin
          Categorize_properties___.new
        end

        alias_method :via_args_opts_envs, :new
        private :new
      end  # >>

      class Categorize_properties___

        attr_writer(
          :property_stream,
          :settable_by_environment_h,
        )

        def execute

          @arg_a = @env_a = @opt_a = @many_a = nil

          d = 0 ; @original_index = {}

          env_h = @settable_by_environment_h || MONADIC_EMPTINESS_

          st = @property_stream
          begin
            prp = st.gets
            prp or break

            @original_index[ prp.name_symbol ] = ( d += 1 )

            if env_h[ prp.name_symbol ]
              ( @env_a ||= [] ).push prp
              redo
            end

            # if is_hidden ; redo

            if prp.takes_many_arguments
              ( @many_a ||= [] ).push prp
              redo
            end

            if prp.is_effectively_optional_
              ( @opt_a ||= [] ).push prp
            else
              ( @arg_a ||= [] ).push prp
            end

            redo
          end while nil

          if @many_a
            __determine_placement_for_many
          end

          __maybe_make_experimental_aesthetic_readjustment

          Here_.via_args_opts_envs @arg_a.freeze, @env_a.freeze, @opt_a.freeze
        end

        def __maybe_make_experimental_aesthetic_readjustment  # #note-575

          if ! @many_a && @opt_a && ( ! @arg_a || @opt_a.last.takes_argument  ) # (a), (b) and (c)
            __make_experimental_aestethic_adjustment
          end
        end

        def __make_experimental_aestethic_adjustment  # #note-610

          skip = Home_::CLI_Support.standard_action_property_box_.h_

          d = @opt_a.length
          while d.nonzero?

            prp = @opt_a.fetch d -= 1
            if ! prp.takes_argument
              next
            end

            _yes = skip[ prp.name_symbol ]
            if _yes
              next
            end

            found = prp
            break
          end

          if found
            ( @arg_a ||= [] ).push found
            @opt_a[ d, 1 ] = EMPTY_A_
            @opt_a.length.zero? and @opt_a = nil
          end

          NIL_
        end

        def __determine_placement_for_many

          if @arg_a
            @arg_a.push @many_a.pop
            _re_order @arg_a
          else
            @arg_a = [ @many_a.pop ]
          end
          if @many_a.length.nonzero?
            @opt_a.concat @many_a
            _re_order @opt_a
          end
          @many_a = true
        end

        def _re_order a
          a.sort_by! do | prp |
            @original_index.fetch prp.name_symbol
          end
          NIL_
        end
      end

      def initialize frozen, frozen_, frozen__

        @arg_a = frozen
        @env_a = frozen_
        @opt_a = frozen__
      end

      def __category_for prp  # etc..

        compare_symbol = prp.name.as_variegated_symbol.method :==

        compare = -> prp_ do
          compare_symbol[ prp_.name.as_variegated_symbol ]
        end

        _sym = CATEGORIES.reduce nil do | _, category |
          a = instance_variable_get category.ivar
          a or next
          x = a.detect( & compare )
          x or next
          break category.symbol
        end

        if ! _sym
          self._K
        end

        _sym
      end

      def for cat
        instance_variable_get cat.ivar
      end

      Category__ = ::Struct.new :ivar, :symbol
      a = []
      a.push Category__[ :@arg_a, :argument ]
      a.push Category__[ :@opt_a, :option ]
      a.push Category__[ :@env_a, :environment_variable ]
      CATEGORIES = a

      attr_reader(
        :arg_a,
        :env_a,
        :opt_a,
      )

      Here_ = self
    end
  end
end

