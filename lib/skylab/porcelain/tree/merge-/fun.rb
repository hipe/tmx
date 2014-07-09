module Skylab::Porcelain

  module Tree

    class Merge_

      module FUN

        modi = -> *a do
          a.map do |x|
            mo = Get_MO_[ x ]
            :no_match == mo.type_ish_i and raise "implement me - there is #{
              }no MO yet for #{ x.class }"
            mo
          end
        end

        merge = -> merge_which_i, x1, x2 do
          mo1, mo2 = modi[ x1, x2 ]
          (( p = mo1.send merge_which_i )) or raise "#{ MC_ }#{
            }'#{ mo1.type_ish_i }' doesn't `#{ merge_which_i }`"
          p[ x1, mo2, x2 ]
        end

        MC_ = "merge conflict - ".freeze

        o = -> k, p do
          define_singleton_method k do p end
        end

        class << o
          alias_method :[]=, :[]
        end

        o[:merge_atomic] = -> x1, x2 do
          merge[ :merge_atomic, x1, x2 ]
        end

        o[:merge_one_dimensional] = -> x1, x2 do
          merge[ :merge_one_dimensional, x1, x2 ]
        end

        o[:merge_union] = -> x1, x2 do
          merge[ :merge_union, x1, x2 ]
        end

        class Modus_Operandus_

          Entity_[ self, :fields, :type_ish_i, :match, :dupe,
           :merge_atomic, :merge_one_dimensional,
           :merge_union ]

          class << self ; private :new end

          def self.[] * x_a
            x_a.unshift :type_ish_i
            new x_a
          end

          attr_reader :type_ish_i, :match, :dupe, :merge_atomic,
            :merge_one_dimensional, :merge_union

        end

        MODI_OPERANDI_A_ = -> do

          identity = IDENTITY_

          an = -> x do
            an = Headless::NLP::EN::Minitesimal::FUN.an
            an[ x ]
          end

          say_merge_conflict = -> xx, yx do
            "#{ MC_ }won't merge #{ an[ xx ] } into #{ an[ yx ] }"
          end

          merge_numeric = -> int_flot do
            -> x, mo, y do
              case mo.type_ish_i
              when :nil   ; x
              when :int   ; x + y
              when :float ; y + x
              else        ; raise say_merge_conflict[ mo.type_ish_i, int_flot ]
              end
            end
          end

          o = Modus_Operandus_

          [ o[ :nil,
               :match, -> x { x.nil? },
               :merge_atomic, -> _, mo, y do
                         mo.dupe[ y ]
                       end,
               :dupe, identity
            ],
            o[ :bool,
               :match, -> x do
                         case x
                         when ::FalseClass, ::TrueClass; true
                         end
                       end,
               :merge_atomic, -> x, mo, y do
                         case mo.type_ish_i
                         when :nil  ; x
                         when :bool ; x == y or
                           raise say_merge_conflict[ "boolean #{ y }", x ]
                         else
                           raise say_merge_conflict[ mo.type_ish_i, 'bool' ]
                         end
                       end,
              :dupe, identity
            ],
            o[ :int,
               :match, -> x do ::Integer === x end,
               :merge_atomic, merge_numeric[ :int ],
               :dupe, identity
            ],
            o[ :float,
               :match, -> x do ::Float === x end,
               :merge_atomic, merge_numeric[ :float ],
               :dupe, identity
            ],
            o[ :list,
               :match, -> x do x.respond_to? :each_index end,
               :merge_one_dimensional, -> x, mo, y do
                         List_check_[ mo, y ]
                         x + y
                       end,
               :merge_union, -> x, mo, y do
                         List_check_[ mo, y ]
                         x | y
                       end
            ],
            o[ :no_match,
               :match, -> _ do true end
            ]
          ]
        end.call

        List_check_ =  -> mo, y do
                         :list == mo.type_ish_i or raise "#{ MC_ }#{
                         }no strategy yet created for merging a #{
                         }#{ mo.type_ish_i }into this list."
                       end

        Get_MO_ = -> do
          f_a = MODI_OPERANDI_A_.map do |mo|
            -> x do
              mo.match[ x ] ? [ false, mo ] : [ true, x ]
            end
          end
          -> x do
            Porcelain_::Lib_::Function_chain[ f_a, [ x ] ]
          end
        end.call
      end
    end
  end
end
