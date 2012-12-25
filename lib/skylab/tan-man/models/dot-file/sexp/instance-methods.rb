module Skylab::TanMan::Models::DotFile::Sexp::InstanceMethods

  extend ::Skylab::Autoloader # we want the plain jane variety, and now later

  class << self

    # This const_defined? hack is an experimental alternative to preloading
    # every extension module file for every Sexp class "manually".
    # We must do either one or the other because Sexp::Auto is unaware
    # of the idea of autoloading (as it probably should be!) and hence
    # uses const_defined? to determine if extension modules exist
    # for a given Sexp class.

    def const_defined? const, bool
      if autoloader_original_const_defined? const, bool
        true
      elsif const_probably_loadable? const
        self.const_get const, false
      else
        false
      end
    end
  end

  module Comment
    MATCH_RX = %r{\A[[:space:]]*(?:#|/\*)} # #hack
  end

  module Common
    self::TanMan = ::Skylab::TanMan

    def _label2id_stem label_str
      md = /\A(?<stem>\w+)/.match label_str
      md ? md[:stem] : 'node'
    end

    # this is a *big* experiment -- expect this to change a lot
    def _parse_id str, member=nil
      ::String === str or fail("sanity -- expecting String had #{str.class}")
      p = self.class.grammar.parser_for_rule :id # danger is here? [#054]
      node = p.parse str
      node ||= p.parse "\"#{str.gsub('"', '\"')}\""
      node or fail "sanity - what such string is invalid? #{p.failure_reason}"
      self.class.element2tree(node, member) # note member might be nil
    end
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
    include Common
    def rhs= mixed
      self[:rhs] = _parse_id(mixed, :rhs)
    end
  end
end
