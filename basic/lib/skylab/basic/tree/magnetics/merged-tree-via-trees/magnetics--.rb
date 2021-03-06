module Skylab::Basic

  module Tree

    class Magnetics::MergedTree_via_Trees

      module Magnetics__  # 1x

        class Merge  # an experiment about merging two arbitrary objects
          # based on their "shape" - two ints get added together, two lists
          # get concatted, an int onto a list gets pushed, a list onto an
          # int is not supported, etc.

          Attributes_actor_.call( self,
            :x,
            :x_,
            :merge_category_symbol,
          )

          def execute
            @mo = produce_modus_for_mixed @x
            @mo_ = produce_modus_for_mixed @x_
            p = @mo.send @merge_category_symbol
            if p
              p[ @x, @mo_, @x_ ]
            else
              raise Home_::ArgumentError, say_does_not_merge
            end
          end

        private

          def say_does_not_merge
            "#{ PREFIX__ }'#{ @mo.shape_i }' doesn't `#{ @merge_category_symbol }`"
          end

          def produce_modus_for_mixed x
            mo = MODI_OPERANDI_A__.detect do |mo_|
              mo_.match[ x ]
            end
            if :no_match == mo.shape_i
              raise say_implement_me x
            else
              mo
            end
          end

          def say_implement_me x
            "implement me - there is no modus operandus yet for #{ x.class }"
          end

        MODI_OPERANDI_A__ = -> do

          an = -> x do
            "#{ Home_.lib_.NLP_EN.an x }#{ x }"
          end

          say_merge_conflict = -> xx, yx do
            "#{ PREFIX__ }won't merge #{ an[ xx ] } into #{ an[ yx ] }"
          end

          merge_numeric = -> int_flot do
            -> x, mo, y do
              case mo.shape_i
              when :nil   ; x
              when :int   ; x + y
              when :float ; y + x
              else        ; raise say_merge_conflict[ mo.shape_i, int_flot ]
              end
            end
          end

          result_a = []

          o = -> * x_a do
            result_a.push Modus_Operandus___.new x_a ; nil
          end

          class Modus_Operandus___

            Attributes_actor_.call( self,
              :shape_i,
              :match,
              :dupe,
              :merge_atomic,
              :merge_one_dimensional,
              :merge_union,
            )

            attr_reader :shape_i, :match, :dupe, :merge_atomic,
              :merge_one_dimensional, :merge_union

            def initialize x_a
              process_iambic_fully x_a
            end
          end

          o[ :shape_i, :nil,
             :match, -> x { x.nil? },
             :merge_atomic, -> _, mo, y do
               mo.dupe[ y ]
             end,
             :dupe, IDENTITY_ ]

          o[ :shape_i, :bool,
             :match, -> x do
               case x
               when ::FalseClass, ::TrueClass; true
               end
             end,
             :merge_atomic, -> x, mo, y do
               case mo.shape_i
               when :nil  ; x
               when :bool ; x == y or
                 raise Home_::ArgumentError, say_merge_conflict[ "boolean #{ y }", x ]
               else
                 raise Home_::ArgumentError, say_merge_conflict[ mo.shape_i, 'bool' ]
               end
             end,
             :dupe, IDENTITY_ ]

          o[ :shape_i, :int,
             :match, -> x do
               ::Integer === x
             end,
             :merge_atomic, merge_numeric[ :int ],
             :dupe, IDENTITY_ ]

          o[ :shape_i, :float,
             :match, -> x do
               ::Float === x
             end,
             :merge_atomic, merge_numeric[ :float ],
             :dupe, IDENTITY_ ]

          o[ :shape_i, :list,
             :match, -> x do
               x.respond_to? :each_index
             end,
             :merge_one_dimensional, -> x, mo, y do
               List_check__[ mo, y ]
               x + y
             end,
             :merge_union, -> x, mo, y do
               List_check__[ mo, y ]
               x | y
             end ]

          o[ :shape_i, :no_match,
             :match, -> _ do
               true
              end ]

          result_a

        end.call

        List_check__ =  -> mo, y do
          if :list != mo.shape_i
            raise "#{ PREFIX__ }no strategy yet created for merging a #{
              }#{ mo.shape_i }into this list."
          end
        end

        PREFIX__ = "merge conflict - ".freeze

        end
      end
    end
  end
end
