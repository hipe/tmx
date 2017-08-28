module Skylab::Brazen

  module CLI_Support

    class Categorized_Properties  # the asset node of [#002]E

      class << self

        def begin
          Categorize_properties___.new
        end

        alias_method :via_args_opts_envs, :new
        private :new
      end  # >>

      class Categorize_properties___

        def initialize
          @when_many = nil

          @arg_a = nil
          @env_a = nil
          @many_a = nil
          @opt_a = nil
        end

        attr_writer(

          # -- in order

          :on_environment_property,
          :on_takes_many_arguments_property,
          :when_many,
          :on_effectively_optional_property,
          :on_effectively_required_property,
          :make_aesthetic_readjustments,

          # -- alpha.

          :property_stream,
          :settable_by_environment_h,
        )

        def execute

          Require_fields_lib_[]

          @on_environment_property ||= method :categorize_as_environment_property

          @on_takes_many_arguments_property ||=
            method :categorize_as_takes_many_arguments_property

          @on_effectively_optional_property ||=
            method :categorize_as_option

          @on_effectively_required_property ||=
            method :categorize_as_argument

          @make_aesthetic_readjustments ||=
            method :__make_aesthetic_readjustments

          d = 0 ; @original_index = {}

          env_h = @settable_by_environment_h || MONADIC_EMPTINESS_

          st = @property_stream
          begin
            prp = st.gets
            prp or break

            @original_index[ prp.name_symbol ] = ( d += 1 )

            if env_h[ prp.name_symbol ]
              _did = @on_environment_property[ prp ]
              if _did
                redo
              end
            end

            # if is_hidden ; redo

            if Field_::Takes_many_arguments[ prp ]

              _did = @on_takes_many_arguments_property[ prp ]
              if _did
                redo
              end
              redo
            end

            if Field_::Is_effectively_optional[ prp ]

              _did = @on_effectively_optional_property[ prp ]
              if _did
                redo
              end
            end

            @on_effectively_required_property[ prp ]

            redo
          end while nil

          if @many_a

            ( @when_many || method( :determine_placement_for_many ) ).call
          end

          @make_aesthetic_readjustments.call

          Here_.via_args_opts_envs @arg_a.freeze, @env_a.freeze, @opt_a.freeze
        end

        def categorize_as_environment_property prp
          ( @env_a ||= [] ).push prp
          ACHIEVED_
        end

        def categorize_as_takes_many_arguments_property prp
          ( @many_a ||= [] ).push prp
          ACHIEVED_
        end

        def release_any_many
          x = @many_a
          if x
            @many_a = nil
            x
          end
        end

        def pop_many
          x = @many_a.pop
          if @many_a.length.zero?
            @many_a = nil  # etc
          end
          x
        end

        def categorize_as_option prp
          ( @opt_a ||= [] ).push prp
          ACHIEVED_
        end

        def categorize_as_argument prp
          ( @arg_a ||= [] ).push prp
          ACHIEVED_
        end

        def __make_aesthetic_readjustments  # [#002.C]

          # if (a), (b) and (c)

          if ! @many_a && @opt_a
            # (hi.)
            if ! @arg_a || Field_::Takes_argument[ @opt_a.last ]
              ___make_experimental_aestethic_adjustment
            end
          end
        end

        def ___make_experimental_aestethic_adjustment  # [#002.F]

          skip = Home_::CLI_Support.standard_action_property_box_.h_

          d = @opt_a.length
          while d.nonzero?

            prp = @opt_a.fetch d -= 1
            if ! Field_::Takes_argument[ prp ]
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

        def determine_placement_for_any_many
          if ! @many_a.nil?
            determine_placement_for_many
          end
        end

        def determine_placement_for_many

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

          NIL_
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

        sym = CATEGORIES.reduce nil do | _, category |
          a = instance_variable_get category.ivar
          a or next
          x = a.detect( & compare )
          x or next
          break category.symbol
        end

        if sym
          sym
        else
          # #not-covered
          NOTHING_
        end
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

