module Skylab::TanMan

  module Models_::DotFile::Sexp::InstanceMethods::A_List

    include Models_::DotFile::Sexp::InstanceMethod::InstanceMethods

    def _insert_assignment! sym, val
      # because of the nature of the grammar, you are guaranteed to have at
      # least one item in the list. #algorithm:lexical *however* hacks
      # may occur where we have zero!! at these times you need a
      # _prototype! all of this because we need a prototype for the item
      # (an AList1)

      first_a_list_1 = nil        # as a last resort prototype, use existing
      items = _items              # (easier to debug when memoized)
      key_s = sym.to_s            # id of new assignment as string for comp.
      new_before_this_asst = nil  # before which asst will we insert ourselves?

      items.each do |asst|        # always iterate over the whole list [#067]
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

      proto = if _prototype and _prototype.content
        _prototype.content
      else
        first_a_list_1 || new_before_this_asst # any one from above
      end
      fail "sanity - this algo not built for zero-length lists" if ! proto

      new = proto.__dupe except: [:id, [:equals, :id]]
      new[:id] = _parse_id key_s
      new[:equals][:id] = _parse_id val.to_s
      _insert_item_before_item new, new_before_this_asst # nil ok for 2nd param
    end

    def _update_attributes! attrs, add=nil, change=nil
      attrs = attrs.map { |k, v| [k.intern, v] } # normalize to arr of [sym, x]
      h = { }
      as.each do |a|              # per recursive-rule, an a_list has many a's
        h[ a.id.normalized_string.intern ] = a
      end
      attrs.each do |k, v|
        if h.key? k
          change[ k, h[k][:equals][:id].normalized_string, v ] if change
          h[k][:equals][:id] = _parse_id v
        else
          add[ k, v ] if add
          _insert_assignment! k, v
        end
      end
      true
    end
  end
end
