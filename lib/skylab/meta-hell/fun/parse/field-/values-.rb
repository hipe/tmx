module Skylab::MetaHell

  module FUN::Parse

    class Field_::Values_ < ::Struct

      class << self
        alias_method :orig_new, :new
      end

      def self.new box
        a = box.reduce [] do |m, fld|
          m.concat fld.predicates
        end
        a.length.zero? and fail "sanity - structs need at least 1 member"
        orig_new( *a )
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

      def [] key, *rest
        if rest.length.zero? then super else
          ( rest.unshift key ).map { |k| super( k ) }
        end
      end
    end
  end
end
