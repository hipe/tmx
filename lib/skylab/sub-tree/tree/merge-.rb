module Skylab::SubTree

  module Tree

    class Merge_  # ( part of the [#mh-014] diaspora )

      Entity_[ self, :fields, :client, :other, :key_proc, :attr_a ]

      class << self

        def merge_atomic x1, x2
          Merge_::Actors__::Merge[ :merge_atomic, x1, x2 ]
        end

        def merge_one_dimensional x1, x2
          Merge_::Actors__::Merge[ :merge_one_dimensional, x1, x2 ]
        end
      end

      def execute
        @attr_a ||= @client.merge_attr_a
        descend @client, @other
        nil
      end

      attr_reader :key_proc

      def descend client, other
        @attr_a.each do |attr_i|
          client.send METH_H_[ attr_i ], other, self
        end
        nil
      end

      METH_H_ = ::Hash.new do |h, k|
        h[k] = :"destructive_merge_#{ k }_notify"
      end

      # .. and then from the above, get called back by:

      def merge_union x1, x2
        Merge_::Actors__::Merge[ :merge_union, x1, x2 ]
      end


      # this algorithm consists of transferring destructively and recursively
      # all the nodes from a source node (which we will call "remote") into
      # a target node (which we will call "local"). the remote node will be
      # rendered useless and the local node will end up "having" all of
      # the nodes (logically), with perhaps some of the nodes having been
      # "merged", based on whether at those two locationally isomorphic nodes
      # for the two trees a "match" was found using `key_proc` which typically
      # determines which of the isomorphic keys for every given node to
      # use to look for a match, typically either the first or the last one.
      # this algorithm descends recursively down into matching nodes.
      #
      # the composition of all of the keys at both nodes being merged must
      # "make sense" - to describe what this means is hard to make sound
      # sensical, but here goes: for any node in the remote node seen as
      # "matching" a node in the local node given the `key_proc`, if any of
      # its isomorphic keys are equal to any of the isomorphic keys of any
      # of the children (at this level) of the local node, then the key's
      # referrant in the local node must be that same node that "matched"
      # per the key proc.
      #
      # that is, for a local and remote node seen as a "match", the set
      # intersect of the remote node's keys with all of the keys of the local
      # *parent* must be the same set intersect of the keys of the two
      # nodes themselves.
      #
      # conversely for any given node from the remote node that is *not*
      # found to match a node at this level in the local node given the
      # key proc, it must be that *none* of the keys from the particular
      # remote node match any of the keys in the local node. that is, the
      # set intersect of the keys of the local parent node and the keys of
      # the remote child must be the empty set.
      #

      Destructive_merge_children_ = -> local, remote, algo do
        keyp = algo.key_proc
        use_h = Make_hash__[ keyp, local ]
        p = remote.get_some_child_scanner_p
        bm = local._bm
        while (( remote_child = p[] ))
          key = keyp[ remote_child ]
          if (( local_id = use_h[ key ] ))
            local_child = bm.fetch_item_by_id local_id
            algo.descend local_child, remote_child
          else
            Into_parent_transplant_child_[ local, remote_child ]
          end
        end
        nil
      end

      Make_hash__ = -> keyp, node do
        use_h = { }
        p = node.get_some_child_scanner_p
        while (( child = p[] ))
          key = keyp[ child ] or fail "sanity - key?"
          did = false
          use_h.fetch( key ) do |k|
            did = true
            use_h[ key ] = child._node_id
          end
          did or fail "sanity - key collision? #{ key }"
        end
        use_h
      end

      Into_parent_transplant_child_ = -> local_parent, remote_child do
        bm = local_parent._bm
        lka = bm.keys
        rka = remote_child._isomorphic_key_a
        (( int = lka & rka )).length.nonzero? and raise "merge conflict - #{
          }remote child to be transplanted in has same keys as existing #{
          }child in local node - (#{ int * ', ' })"
        new_remote_id = bm.add remote_child
        ks = remote_child.
          transplant_notify_and_release_keyset( new_remote_id, local_parent )
        ks.key_a.object_id == rka.object_id or fail "sanity"
        bm.merge_keyset_to_item ks, new_remote_id
        nil
      end
    end
  end
end
