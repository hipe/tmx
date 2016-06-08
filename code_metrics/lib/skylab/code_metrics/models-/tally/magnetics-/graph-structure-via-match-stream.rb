module Skylab::CodeMetrics

  class Models_::Tally

    class Magnetics_::Graph_Structure_via_Match_Stream

      attr_writer(
        :match_stream,
        :pattern_strings,
      )

      def execute

        # build a box of "features" (strings) and a tree of
        # "occurrence buckets" (in the tree they are they leaves,
        # in the real world they are the haystack files).
        #
        # each feature has an internal integer identifier that is meaningful
        # only with in the context of the structure. maybe a symbol instead.
        # (like f0, f1, etc)
        #
        # likewise each "leaf-bucket" will too. (lb0, lb1..)
        #
        # an "occurrence" is one instance of the feature in the bucket.
        # for now we will preserve *all* the data of the occurrence (
        # line number, column range) even though the rendering agent is
        # not expected to use most of this data for the default graph design.
        #
        # group each occurrence by a [ feature, bucket ] tuple. that is,
        # per feature within bucket, there will be an array of one or more
        # occurrences.

        # as a hint, the final graph viz document (the prototype design)
        # will consist of three main sections (and perhaps other sibling
        # pieces). the first and last sections are easy:
        #
        # the first section is a listing of the features. this will
        # associate the internal identifier with the human-meaningful label.
        #
        # the last section is a listing of the occurrence-groups. each
        # group is the association of one feature with one leaf-bucket.
        # those groups that have more than one occurrence per bucket will
        # perhaps annotate the graph with this info ("(2x)", "(3x)", etc).
        #
        # the middle section is the tree. have fun with that..

        # --

        og_box = Common_::Box.new

        touch_occurrence_group_via_tuple = -> feat_sym, bucket_sym do

          # compound keys!

          og_box.touch [ feat_sym, bucket_sym ] do

            Occurrence_Group___.new feat_sym, bucket_sym, []
          end
        end

        # --

        leaf_bucket_box = Common_::Box.new
        leaf_bucket_keys = leaf_bucket_box.a_

        t = Home_.lib_.basic::Tree.mutable_node.new

        touch_leaf_bucket_for_path = -> path do

          leaf_bucket_box.touch path do

            _tree_leaf = t.touch_node path, :leaf_node_payload_proc, -> do

              _ = ::File.basename path  # not sure about this

              Leaf_Bucket___.new :"bucket#{ leaf_bucket_keys.length }", _
            end

            _tree_leaf.node_payload
          end
        end

        # --

        # • so that the pattern strings with no matches are still
        #   represented in the visualiation, build the feature list from
        #   the original input argument, not the stream of matches.
        #
        # • if you're wondering why the feature count start at 0 but the
        #   other one starts at 1, the answer it here. but it's an arbitrary
        #   internal identifier, so meh

        feature_box = Common_::Box.new  # keyed to pattern string
        feature_keys = feature_box.a_
        feature_hash = feature_box.h_

        @pattern_strings.each do | s |
          # or touch ..
          _ = :"feature#{ feature_keys.length }"
          feature_box.add s, Feature___.new( _, s )
        end

        # --

        st = remove_instance_variable :@match_stream
        begin

          ma = st.gets
          ma or break

          feature = feature_hash.fetch ma.pattern_string

          leaf_bucket = touch_leaf_bucket_for_path[ ma.path ]

          _og = touch_occurrence_group_via_tuple[
            feature.feature_symbol, leaf_bucket.leaf_bucket_symbol ]

          _og.occurrences.push ma  # the value might not actually be used ..

          redo
        end while nil

        _occurrence_groups = og_box.enum_for( :each_value ).to_a

        _features = feature_box.enum_for( :each_value ).to_a

        Graph_Structure___.new _occurrence_groups, _features, t
      end

      Graph_Structure___ = ::Struct.new(
        :occurrence_groups,
        :features,
        :bucket_tree,
      )

      Feature___ = ::Struct.new(
        :feature_symbol,
        :surface_string,
      )

      Occurrence_Group___ = ::Struct.new(
        :feature_symbol,
        :bucket_symbol,
        :occurrences,
      )

      Leaf_Bucket___ = ::Struct.new(
        :leaf_bucket_symbol,
        :surface_string,
      )
    end
  end
end
