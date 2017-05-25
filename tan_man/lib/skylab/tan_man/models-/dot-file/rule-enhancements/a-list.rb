module Skylab::TanMan

  module Models_::DotFile::RuleEnhancements::A_List

    include Models_::DotFile::CommonRuleEnhancementsMethods_

    def update_attributes_ attr_h, add_p=nil, change_p=nil

      h = {}
      as.each do |a|  # per recursive-rule, an a_list has many a's
        h[ a.id.normal_content_string_.intern ] = a
      end

      attr_h.each_pair do |sym, mixed_value|

        value_s = if mixed_value.respond_to? :id2name
          mixed_value.id2name
        elsif mixed_value.respond_to? :ascii_only?
          mixed_value
        else
          self._COVER_ME__value_must_be_string_or_symbol__
        end

        sym.respond_to? :id2name or self._COVER_ME__key_must_be_symbol__

        el = h[ sym ]
        if el
          equals = el[ :equals ]
          if change_p
            _s = equals[ :id ].normal_content_string_
            change_p[ sym, _s, value_s ]
          end
          _id = _parse_id value_s
          equals[ :id ] = _id
        else
          if add_p
            add_p[ sym, value_s ]
          end
          _insert_assignment sym, value_s
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

      items.each do |asst|        # always iterate over the whole list per [#ba-045]
        cmp = key_s <=> asst[:id].normal_content_string_
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
