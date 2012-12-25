module Skylab::TanMan
  module Models::DotFile::Sexp::InstanceMethods::A_List
    include Models::DotFile::Sexp::InstanceMethod::InstanceMethods

    def _insert_assignment! sym, val
      # because of the nature of the grammar, you are guaranteed to have at
      # least one item in the list. #algorithm:lexical

      new_before_this_asst = last_asst_seen = nil
      items = _items ; key_s = sym.to_s

      items.each do |asst|
        cmp = key_s <=> asst[:id].normalized_string
        case cmp
        when -1 # new should come before current one - this is special, keep 1st
          new_before_this_asst ||= asst
        when 0
          fail "sanity - key exists, this is an update not insert - #{ sym }"
        when 1 # new comes after current
          last_asst_seen = asst
        end
      end

      proto = new_before_this_asst || last_asst_seen
      proto or fail "sanity - this algo not build for zero-length lists"
      new = proto.__dupe except: [:id, [:equals, :id]]
      new[:id] = _parse_id key_s
      new[:equals][:id] = _parse_id val.to_s
      _insert_before! new, new_before_this_asst # `new_before_this_asst` nil ok
    end


    def _update_attributes! attrs, add=nil, change=nil
      attrs = attrs.map { |k, v| [k.intern, v] } # normalize to sym
      h = { }
      as.each do |a|
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
