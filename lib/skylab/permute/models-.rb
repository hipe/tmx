module Skylab::Permute

  Models_ = ::Module.new

  module Models_::Permutation

    Actions = ::Module.new

    same = Pe_.lib_.brazen::Model.common_action_class

    class Actions::Ping < same

      @is_promoted = true

      def produce_result

        maybe_send_event :info, :expression, :ping do | y |

          y << "hello from #{ app_name }."
        end

        :hello_from_permute
      end
    end

    class Actions::Generate < same

      @is_promoted = true

      Pe_.lib_.brazen::Model.common_entity_module[ self ]

      edit_entity_class(

        :desc, -> y do
          y << "minimal permutations generator."
        end,

        :argument_arity, :custom,
        :required,
        :property, :pair )

      def pair=   # must be public here, distinct from actor

        name_x = gets_one_polymorphic_value

        _pair = Callback_::Pair.new gets_one_polymorphic_value, name_x

        @argument_box.touch :pair do
          []
        end.push _pair

        KEEP_PARSING_
      end

      def produce_result

        cat_box = Callback_::Box.new

        @argument_box.fetch( :pair ).each do | pair |

          cat_box.touch pair.name_x do
            Callback_::Pair.new [], pair.name_x
          end.value_x.push pair.value_x
        end

        @_cat_box = cat_box
        @_num_cats = cat_box.length

        _a = @_cat_box.a_.map do | x |
          x.to_s.gsub( DASH_, UNDERSCORE_ ).intern
        end

        @_row_struct = ::Struct.new( * _a )

        __build_stream
      end

      def __build_stream

        cat_a = @_cat_box.enum_for( :each_value ).to_a

        _number_of_permutations = cat_a.map do | pr |
          pr.value_x.length
        end.reduce( & :* )

        Callback_::Stream.via_times _number_of_permutations do | d |

          x = @_row_struct.new
          @_num_cats.times do | col_d |

            cat = cat_a.fetch col_d

            prev_d = d
            len = cat.value_x.length
            d /= len

            x[ col_d ] = cat.value_x.fetch( prev_d % len )
          end
          x
        end
      end

      DASH_ = '-'
    end
  end
end
