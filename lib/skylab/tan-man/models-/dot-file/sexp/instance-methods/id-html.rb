module Skylab::TanMan

  module Models_::DotFile::Sexp::InstanceMethods::IdHtml

    # (0..128).each { |i| puts("#{ '%03d' % [i] }: #{ ('%c' % [i] ).inspect }") }

    deny_rx = /([^ !#$\%(-;=?-~])/ # ascii 32 (" ") - 126 ("~") minus the 5 belo

    html_entities = {
      '"' => 'quot', "'" => 'apos', '&' => 'amp', '<' => 'lt', '>' => 'gt',
    }

    define_method :_escape_string do | string, & oes_p |
      # for now we go with a narrow whitelist, in future we could expand
      # trivially, but for now extensive html escaping support is wayy outside
      # the scope of all this.
      #
      res = nil
      begin
        bad = nil

        out = string.gsub deny_rx do
          str = $~[1]
          ent = html_entities[ str ]
          if ent
            "&#{ ent };"
          else
            ( bad ||= [] ) << str
            nil
          end
        end

        if bad
          res = oes_p.call :error, :invalid_characters do
            Models_::DotFile::Events_::Invalid_Characters.new_with :chars, bad.uniq
          end
          break
        end
        res = out
      end while nil
      res
    end

    def normalized_string
      self[:content_text_value]
    end

    def set_normalized_string string
      string.include?('>>') and fail('haha not today my friend. not today.')
      self[:content_text_value] = string
    end
  end
end
