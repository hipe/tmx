module Skylab::Snag

  module Models_::Node_Collection

    module Expression_Adapters::Filesystem

      class Extended_Content_Adapter

        # this adapter decides that a node has "extended content" if there
        # is a filesystem entry whose name corresponds to the node's
        # identifier based on a simple isomorphicism: if within a particular
        # directory there is an entry who has integers in the head of its
        # name, that entry will be seen as corresponding to any node whose
        # identifier has that integer. this isomorphicism should be
        # insensitive to any leading zeros in the integer-strings on either
        # side of the comparison.

        class << self

          def new_via_manifest_path_and_filesystem path, fs

            new(
              path[ 0 .. - ( ::File.extname( path ).length + 1 ) ],  # better way?
              fs )
          end
          private :new
        end  # >>

        def initialize dir, fs

          @index = -> do

            bx = Callback_::Box.new
            st = fs.entry_stream dir

            begin

              dir_ = st.gets
              dir_ or break

              md = RX___.match dir_
              md or redo

              bx.add md[ :integer ].to_i, true  # etc

              redo
            end while nil

            @index = -> do
              bx
            end

            bx
          end
        end

        RX___ = /\A (?<integer> [0-9]+ ) /x

        def node_has_extended_content_via_node_id__ id

          @index[].h_.key? id.to_i
        end
      end
    end
  end
end
