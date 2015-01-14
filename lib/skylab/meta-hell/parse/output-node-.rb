module Skylab::MetaHell

  module Parse

    class Output_Node_

      def initialize x
        @value_x = x
      end

      def members
        [ :value_x ]
      end

      attr_reader :value_x
    end

    if false
    class Field::Values < ::Struct

      class << self
        alias_method :orig_new, :new
      end

      def self.new field_a

        # each field must indicate a list of zero to many symbol names
        # representing the particular member fields ("predicates") that it
        # wants to use in the output result structure. it is ok for different
        # fields to store things under the same predicates, but we want
        # to guard against creating multiple fields for multiple predicates
        # of the same name (::Struct *will* let you do this!)

        seen_h = { }
        a = field_a.reduce [] do |m, fld|
          fld.predicates.each do |i|
            seen_h.fetch i do
              m << i
              seen_h[ i ] = nil
            end
          end
          m
        end
        a.length.zero? and fail "sanity - structs need at least 1 member"
        orig_new( *a )
      end

      def [] key, *rest
        if rest.length.zero? then super else
          ( rest.unshift key ).map { |k| super( k ) }
        end
      end

      def []= first_name, *other_names, val_x
        if other_names.length.zero? then super else
          if ( other_names.unshift first_name ).length < val_x.length
            raise ::ArgumentError, "too many arguments (#{ val_x.length })#{
              } for #{ other_names.length })"
          end
          other_names.each_with_index do |i, idx|
            super i, val_x.fetch( idx )
          end
          val_x
        end
      end

      def get_exponent

        # in e.g an alternation parse, with all of the parsers using the
        # default normal parse, when one parser matched, it switches to 'true'
        # the corresponding member field in the struct of the parser's *first*
        # predicate (e.g the predicate `is_verbose` for the `verbose` flag).
        # (flag parsers only have one predicate). for normalized parsing with
        # swappable alrorithms, we must use a struct-ish as the memo/value
        # structure; although when the parse is truly an altenation parse,
        # the outcome is always only zero or one particular exponent, of the
        # set of all exponents (predicates) for the members of that
        # alternation (hence the number of permutations of possible values
        # structs for N number of constituent flag parsers will be N+1.
        # (the term `exponent` is borrowed from Grammatical_Categories)

        members.reduce nil do |_, i|
          self[ i ] and break i
        end
      end
    end
    end
  end
end
