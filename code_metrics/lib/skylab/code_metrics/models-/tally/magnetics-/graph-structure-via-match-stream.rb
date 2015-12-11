module Skylab::CodeMetrics

  class Models_::Tally

    class Magnetics_::Graph_Structure_via_Match_Stream

      attr_writer(
        :match_stream,
      )

      def execute

        # build a box of "features" (strings) and a tree of
        # "occurrence buckets" (in the tree they are they leaves,
        # in the real world they are the haystack files).
        #
        # each feature have an internal integer identifier that is meaningful
        # only with in the context of the structure. maybe a symbol instead.
        # (like f0, f1, etc)
        #
        # likewise each "leaf-bucket" will too. (lb0, lb1..)
        #
        # an "occurrence" is one instance of the feature in the bucket.
        # for now we will preserve *all* the data of the occurence (
        # line number, column range) even though the rendering agent is
        # not expected to use it all for the default graph design.
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

        st = remove_instance_variable :match_stream

        begin

          self._USE st

        end while nil

        self._FLUSH
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
