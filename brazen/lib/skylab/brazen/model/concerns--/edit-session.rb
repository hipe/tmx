module Skylab::Brazen

  class Model

    class Concerns__::Edit_Session

      # (ultimately we would like for this to go away in lieu of ACS)

      class << self

        def new_first_session_pair formals

          tree = First_Edit_Tree___.new
          [ new( tree, formals ), tree ]
        end

        def new_subsequent_session_pair formals

          tree = Subsequent_Edit_Tree___.new
          [ new( tree, formals ), tree ]
        end

        private :new
      end  # >>

      class Edit_Tree__

        def initialize
          @delta_box = nil
        end

        attr_reader :delta_box

        def _mutable_delta_box
          @delta_box ||= Callback_::Box.new
        end
      end

      class First_Edit_Tree___ < Edit_Tree__

        def initialize
          @_precons = nil
          super
        end

        def __set_preconditions x
          @_precons = x
          NIL_
        end

        def to_a
          [ @delta_box, @_precons ]
        end
      end

      class Subsequent_Edit_Tree___ < Edit_Tree__

      end

      # -> as class

        def initialize tree, formals

          @_formals = formals
          @_tree = tree
        end

        def preconditions x

          @_tree.__set_preconditions x
        end

        def edit_magnetically_from_box pairs  # e.g by a generated action

          bx = @_tree._mutable_delta_box
          fo = @_formals
          pairs.each_pair do | k, x |
            fo.has_name k or next
            bx.add k, x  # chanage to `set` when necessary
          end
          NIL_
        end

        def edit_with * x_a  # e.g by hand

          edit_via_iambic x_a
        end

        def edit_via_iambic x_a

          bx = @_tree._mutable_delta_box
          fo = @_formals
          st = Callback_::Polymorphic_Stream.via_array x_a
          while st.unparsed_exists
            prp = fo.fetch st.gets_one
            if prp.takes_argument
              bx.add prp.name_symbol, st.gets_one  # change to `set` when necessary
            else
              self._COVER_ME
            end
          end
          NIL_
        end

        def edit_pair x, k  # e.g by hand

          if @_formals.has_name k
            @_tree._mutable_delta_box.add k, x
          else
            @_tree.strange_i_a_.push k
          end
          NIL_
        end

        def edit_pairs pairs, * p_a, & p  # e.g unmarshal

          p and p_a.push p
          x_p, k_p = p_a
          x_p ||= IDENTITY_
          k_p ||= IDENTITY_

          bx = @_tree._mutable_delta_box
          fo = @_formals
          pairs.each_pair do | k, x |

            k = k_p[ k ]
            x = x_p[ x ]

            if fo.has_name k
              bx.add k, x
            else
              @_tree.strange_i_a_.push k  # [#037] one day..
            end
          end
          NIL_
        end
      # <- as class
    end
  end
end
