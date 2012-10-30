module Skylab::TanMan::Models::DotFile::Sexp::InstanceMethods
  extend ::Skylab::Autoloader

  module Common
    def _label2id_stem label_str
      md = /\A(?<stem>\w+)/.match label_str
      md ? md[:stem] : 'node'
    end

    # this is a *big* experiment -- expect this to change a lot
    def _parse_id str, member=nil
      ::String === str or fail("sanity -- expecting String had #{str.class}")
      p = self.class.grammar.build_parser_for_rule :id
      node = p.parse str
      node ||= p.parse "\"#{str.gsub('"', '\"')}\""
      node or fail "sanity - what such string is invalid? #{p.failure_reason}"
      self.class.element2tree(node, member) # note member might be nil
    end
  end

  # --*--

  module DoubleQuotedString
    def normalized_string
      content_text_value.gsub('\"', '"')
    end
  end

  module EqualsStmt
    include Common
    def rhs= mixed
      self[:rhs] = _parse_id(mixed, :rhs)
    end
  end

  self::Graph || nil # #sky-106

  self::NodeStmt || nil # #sky-106

end
