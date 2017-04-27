module Skylab::TanMan

  module Models_::DotFile::Sexp::InstanceMethods::A_List

    include Models_::DotFile::Sexp::InstanceMethod::InstanceMethods

    def _update_attributes attr_h, add_p=nil, change_p=nil
      h = {}
      as.each do |a|  # per recursive-rule, an a_list has many a's
        h[ a.id.normalized_string.intern ] = a
      end
      _pairs = attr_h.map { |k, v| [ k.intern, v ] }
      _pairs.each do |i, x|
        if h.key? i
          change_p and change_p[ i, h[ i ][ :equals ][ :id ].normalized_string, x ]
          h[ i ][ :equals ][ :id ] = _parse_id x
        else
          add_p and add_p[ i, x ]
          _insert_assignment i, x
        end
      end
      ACHIEVED_
    end

    def _insert_assignment sym, val
      # because of the nature of the grammar, you are guaranteed to have at
      # least one item in the list. #algorithm:lexical *however* hacks
      # may occur where we have zero!! at these times you need a
      # prototype_! all of this because we need a prototype for the item
      # (an AList1)

      first_a_list_1 = nil        # as a last resort prototype, use existing
      items = to_item_array_     # (easier to debug when memoized)
      key_s = sym.to_s            # id of new assignment as string for comp.
      new_before_this_asst = nil  # before which asst will we insert ourselves?

      items.each do |asst|        # :+[#br-011] always iterate over the whole list
        cmp = key_s <=> asst[:id].normalized_string
        case cmp
        when -1                   # new should come before current one..
          new_before_this_asst ||= asst # this is special, only keep 1st
        when 0
          fail "sanity - key exists, this is an update not insert - #{ sym }"
        when 1                    # new comes after current - we don't keep
          first_a_list_1 ||= asst # it for sorting but we do as a prototype
        end
      end

      proto = if prototype_ and prototype_.content
        prototype_.content
      else
        first_a_list_1 || new_before_this_asst # any one from above
      end
      fail "sanity - this algo not built for zero-length lists" if ! proto

      new = proto.duplicate_except_ :id, [ :equals, :id ]
      new[:id] = _parse_id key_s
      new[:equals][:id] = _parse_id val.to_s

      if new_before_this_asst
        insert_item_before_item_ new, new_before_this_asst
      else
        append_item_ new
      end
    end
  end
end
