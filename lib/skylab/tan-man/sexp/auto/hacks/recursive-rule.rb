module Skylab::TanMan
  module Sexp::Auto::Hacks::RecursiveRule
    # This hack matches a node that matches the first of a series of patterns:
    # 1) if a rule has an element that itself has the same name as the rule
    # 2) if the rule is named "foo_list" and has a "foo" as an element
    #     (a member called "tail" is then assumed that itself must have
    #      a member called "foo_list")

    extend Sexp::Auto::Hack::ModuleMethods
    include Sexp::Auto::Hack::Constants

    def self.match i
      if i.members_of_interest?
        md = LIST_RX.match(i.rule.to_s)
        if i.members_of_interest.include? i.rule # "foo" rule with "foo" element
          Sexp::Auto::Hack.new do
            enhance i, (md ? md[:stem] : i.rule), :content, i.rule
          end
        elsif md # "foo_list" rule with "foo" elem
          if i.members_of_interest.include? md[:stem].intern
            Sexp::Auto::Hack.new do
              enhance i, md[:stem], md[:stem], :tail, i.rule
            end
          end
        end
      end
    end

    def self.enhance i, stem, item_getter, tail_getter, list_getter=nil
      i.tree_class._hacks.push :RecursiveRule #debugging-feature-only
      i.tree_class.instance_methods.include?(:_items) and fail('sanity')
      i.tree_class.send(:define_method, :_items) do
        y = [ ]
        node = self
        begin
          _item = node.send(item_getter) or fail('sanity')
          y << _item
          if _tail_node = node.send(tail_getter)
            node = _tail_node
            if list_getter # ick but more logically readable
              node = node.send(list_getter)
            end
          else
            node = nil
          end
        end while node
        y
      end
      define_items_method i.tree_class, stem
      nil
    end
  end
end
