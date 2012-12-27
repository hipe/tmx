module Skylab::TanMan

  module Models::DotFile::Sexp::InstanceMethod # tell me if you get it
                                               # pending a rename maybe
  end

  module Models::DotFile::Sexp::InstanceMethod::InstanceMethods
    def _label2id_stem label_str
      md = /\A(?<stem>\w+)/.match label_str
      md ? md[:stem].downcase : 'node'
    end

    # this is a *big* experiment -- expect this to change a lot
    def _parse_id str, member=nil
      fail "sanity - expecting String had #{ str.class }" if !(::String === str)
      p = self.class.grammar.parser_for_rule :id # danger is here? [#054]
      node = p.parse str
      node ||= p.parse "\"#{str.gsub('"', '\"')}\""
      fail "sanity - what such string is invalid? #{p.failure_reason}" if ! node
      self.class.element2tree node, member # note member might be nil
    end
  end


  module Models::DotFile::Sexp::InstanceMethods
    extend Autoloader # we want the plain jane variety

    # This const_defined? hack is an #experimental alternative to preloading
    # every extension module file for every Sexp class "manually".
    # We must do either one or the other because Sexp::Auto is unaware
    # of the idea of autoloading (as it probably should be!) and hence
    # uses const_defined? to determine if extension modules exist
    # for a given Sexp class.

    def self.const_defined? const, bool
      if autoloader_original_const_defined? const, bool
        true
      elsif const_probably_loadable? const
        self.const_get const, false
      else
        false
      end
    end
  end

  module Models::DotFile::Sexp::InstanceMethods::Comment
    MATCH_RX = %r{\A[[:space:]]*(?:#|/\*)} # #hack
  end

  # --*--
  # (modules that require more than 20 lines should be moved to their own file.)

  module Models::DotFile::Sexp::InstanceMethods::DoubleQuotedString
    def normalized_string
      content_text_value.gsub('\"', '"')
    end
    def normalized_string! string
      fail 'implement me' # at [#052]
    end
  end

  module Models::DotFile::Sexp::InstanceMethods::EqualsStmt
    include Models::DotFile::Sexp::InstanceMethod::InstanceMethods
    def rhs= mixed
      self[:rhs] = _parse_id(mixed, :rhs)
    end
  end
end
