module Skylab::TanMan

  module Models_::DotFile

    module Sexp::InstanceMethod

      module InstanceMethods

    def _label2id_stem label_str
      md = /\A(?<stem>\w+)/.match label_str
      md ? md[:stem].downcase : 'node'
    end

    # this is a *big* experiment -- expect this to change a lot
    def _parse_id str, member=nil
      fail "sanity - expecting String had #{ str.class }" if !(::String === str)
      p = self.class.grammar.parser_for_rule :id  # danger is here? [#054]
      node = p.parse str
      node ||= p.parse "\"#{str.gsub('"', '\"')}\""
      fail "sanity - what such string is invalid? #{p.failure_reason}" if ! node
      self.class.element2tree node, member # note member might be nil
    end

      end
    end

  module Sexp::InstanceMethods

    # #was-boxxy

    # (this is the other end of [#078]) - This c-onst_defined? hack is an
    # #experimental alternative of loading every extention module file
    # for every Sexp class whole-hog, "manually".
    # We must do either one or the other because Sexp::Auto is unaware
    # (as it should be!) of the idea of autoloading. experimental!

    def self.const_defined? const_str, look_up=true
      ok = super
      if ! ok
        entry_tree.normpath_from_distilled Callback_.distill[ const_str ]
      end
    end

  module Comment

    match_rx = %r{\A[[:space:]]*(?:#|/\*)} # #hack

    define_singleton_method :match_rx do match_rx end

  end

  # --*--
  # (modules that require more than 20 lines should be moved to their own file.)

  module DoubleQuotedString

    def normalized_string
      content_text_value.gsub('\"', '"')
    end

    def normalized_string! string
      fail 'implement me' # at [#052]
    end
  end

  module EqualsStmt

    include Sexp::InstanceMethod::InstanceMethods

    def rhs= mixed
      self[:rhs] = _parse_id(mixed, :rhs)
    end
  end
  end
  end
end
