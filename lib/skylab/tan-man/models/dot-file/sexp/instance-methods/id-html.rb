module Skylab::TanMan::Models::DotFile::Sexp::InstanceMethods
  # (0..128).each { |i| puts("#{ '%03d' % [i] }: #{ ('%c' % [i] ).inspect }") }

  module IdHtml
    DENY_RX = /([^ !#$\%(-;=?-~])/ # ascii 32 (" ") - 126 ("~") minus the 5 belo
    HTML_ENTITIES = {
      '"' => 'quot', "'" => 'apos', '&' => 'amp', '<' => 'lt', '>' => 'gt',
    }

    def _escape_string string
      # for now we go with a narrow whitelist, in future we could expand
      # trivially, but for now extensive html escaping support is wayy outside
      # the scope of all this.
      #
      bad = nil
      out = string.gsub(DENY_RX) do
        if ent = HTML_ENTITIES[$1] then "&#{ent};"
        else
          (bad ||= []).push $1
          nil
        end
      end
      if bad
        s = ! (1 == bad.length)
        fail("html-escaping support is currently very limited. the following #{
          }character#{'s' if s} #{ s ? 'are' : 'is' } not yet supported: #{
          bad.uniq.map { |c| "#{c.inspect} (#{ '%03d' % [c.ord] })" }.join(', ')
          }")
      end
      out
    end
    def normalized_string
      self[:content_text_value]
    end
    def normalized_string! string
      string.include?('>>') and fail('haha not today my friend. not today.')
      self[:content_text_value] = string
    end
  end
end
