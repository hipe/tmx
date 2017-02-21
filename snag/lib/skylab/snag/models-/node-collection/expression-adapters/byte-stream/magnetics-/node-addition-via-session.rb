module Skylab::Snag

  class Models_::NodeCollection

    module ExpressionAdapters::ByteStream

      class Magnetics_::NodeAddition_via_Session < Common_::Monadic

        def initialize o, & p
          @on_event_selectively = p
          @session = o
        end

        def execute

          o = @session  # ->

            id = Find_first_available_identifier[ o.entity_upstream ]

            o.reset_the_entity_upstream

            Rewrite[ id, o, & @on_event_selectively ]

            # <-
        end

        # <- 2

    class Find_first_available_identifier

      class << self

        def [] ent_st

          _tree = __build_tree_of_all_identifiers ent_st

          __find_first_available_identifier_in_tree _tree
        end

        def __build_tree_of_all_identifiers node_st

          _Tree = Home_.lib_.basic::Tree

          _Big_Tree = _Tree.mutable_node
          _Frugal_Tree = _Tree.frugal_node

          # in hindsight using "frugal tree" here may have no gain: these
          # nodes are always branches, never leaves; nonetheless we leave
          # the frugal tree in here as :+#grease

          tree = _Big_Tree.new

          begin
            node = node_st.gets
            node or break

            id = node.ID

            _tree_ = tree.touch id.to_i do

              _Frugal_Tree.new id.to_i
            end

            sfx = id.suffix

            # (in both below cases, if there are effectively duplicate ID's,
            #  only the first one is counted; which is all that is necessary)

            if sfx
              _tree_.touch sfx do
                id
              end
            else
              _tree_.touch NIL_ do
                id
              end
            end

            redo
          end while nil

          tree
        end

        def __find_first_available_identifier_in_tree tree

          h = tree.h_
          int = 1

          begin
            if h.key? int
              int += 1
              redo
            end
            break
          end while nil

          Models_::NodeIdentifier.new_via_integer int
        end
      end # >>
    end

    Rewrite = -> id, o, & x_p do

      last_value = o.subject_entity.edit(

        :via, :object,
        :set, :identifier, id,
        & x_p )

      if last_value

        o.write_each_node_whose_identifier_is_greater_than_that_of_subject
        o.write_the_subject_node
        o.write_any_floating_node
        _ok = o.write_the_remaining_nodes
        _ok && last_value
      else
        last_value
      end
    end

    # -> 2
      end
    end
  end
end
