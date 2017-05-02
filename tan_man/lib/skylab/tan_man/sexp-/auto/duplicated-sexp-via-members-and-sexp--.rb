module Skylab::TanMan

  module Sexp_::Auto

    class DuplicatedSexp_via_Members_and_Sexp__

      # synopsis:
      #
      # implement `duplicate_except_`, a deep-dup exposure that accepts a list
      # of zero or more "paths" of nodes that are not to be duped, but rather
      # nodes for which `nil` will be expressed in their place. this saves the
      # resources that would otherwise be wasted on a naive deep dup for those
      # nodes (if any) that in the output structure will be "hand written" or
      # are otherwise not necessary to recurse into during the dup operation.
      #
      #
      # about "paths":
      #
      # all sexp structures in this library are either array-like or struct-
      # like. the corresponding members of these shapes of component are
      # accessed with integer- or symbol-keys respectively. each such "path"
      # referred to above is either a primitive such value (for paths
      # consisting of one element), or an array these keys (with such an
      # array of length 1 being equivalent to just the primitive alone, and
      # an array of length zero having undefined meaning).
      #
      #
      # conceptual example:
      #
      # imagine this imaginary grammar:
      #
      #   full name: [ first name, middle name, last name ]
      #   first name: [ first letter, the other letters ]
      #
      #
      # let `full_name` be a sexp production of the first rule. if we want
      # to make a deep dup of this sexp, but we don't want to dup the middle
      # name or the first letter of the last name:
      #
      #   new_full_name = full_name.duplicate_except_ :middle_name,
      #     [ :first_name, :first_letter ]
      #
      # note that the order we pass the paths in does not need to be in
      # grammar order. note that the first path is just a primitive
      # (`middle_name`) because it is a path that is one element long.
      # the second path is an array because it refers to a node that is
      # more deeply embedded in the structure.

      class << self

        def call new, except_a, k_a, sexp

          # in cases where there is no exception list, we don't bother
          # creating an actor, we just do it here

          if except_a && except_a.length.nonzero?
            self.new( new, sexp, k_a, except_a ).execute
          else
            k_a.each do | k |
              new[ k ] = _duplicate_member sexp[ k ]
            end
            new
          end
        end

        def _duplicate_member x
          if x
            if x.respond_to? :duplicate_except_
              x.duplicate_except_
            else
              x.dup  # assume string. per [#074] there should be nothing else
            end
          else
            x
          end
        end
      end  # >>

      def initialize new, sexp, k_a, except_a
        @k_a = k_a
        @new = new
        @sexp = sexp
        receive_exemption_list except_a
      end

      def receive_exemption_list except_a
        @op_h = {}
        except_a.each do | x |
          if ! x.respond_to? :to_ary
            x = [ x ]
          end
          @op_h[ x.first ] = if 1 == x.length
            :__ignore_all
          else
            [ :__ignore_these, [ x[ 1 .. -1 ] ] ]
          end
        end
        nil
      end

      def execute

        @k_a.each do | k |
          meth_sym, args = @op_h[ k ]
          if meth_sym
            @new[ k ] = send meth_sym, k, * args
          else
            @new[ k ] = self.class._duplicate_member @sexp[ k ]
          end
        end
        @new
      end

      def __ignore_all _
        nil
      end

      def __ignore_these k, path
        x = @sexp[ k ]
        if x
          x.duplicate_except_ path
        else
          x
        end
      end

      # ==
      # ==
    end
  end
end
