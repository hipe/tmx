module Skylab::TanMan::Models::DotFile::Sexp::InstanceMethods

  module AList
    include Common
    def _insert_assignment! k, v
      # because of the nature of the grammar, you are guaranteed to have at
      # least one item in the list. #algorithm:lexical
      ::Symbol === v and v = v.to_s # for now, being explicit about "type"
      after = last = nil
      k_str = k.to_s
      _items.each do |asst|
        case k_str <=> asst[:id].normalized_string
        when -1 ; last = asst          # nothing, keep looking
        when  1 ; after = asst ; break # asst is the first one that comes after
        else fail('sanity - you should checked for equality already')
        end
      end
      after || last or fail('sanity: this algo not built for zero length lists')
      created = (last || after).__dupe(except: [:id, [:equals, :id]])
      created[:id] = _parse_id k_str
      created[:equals][:id] = _parse_id v
      _insert_before! created, after
    end
    def _update_attributes! attrs
      h = { }
      as.each do |a|
        h[a.id.normalized_string.intern] = a
      end
      attrs.each do |k, v|
        if h.key? k
          h[k][:equals][:id] = _parse_id v
        else
          _insert_assignment! k, v
        end
      end
      true
    end
  end
end
