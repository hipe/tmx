module Skylab::TanMan

  module Models_::DotFile::Sexp::InstanceMethods::IdHtml

    # (0..128).each { |i| puts("#{ '%03d' % [i] }: #{ ('%c' % [i] ).inspect }") }

    deny_rx = /([^ !#$\%(-;=?-~])/ # ascii 32 (" ") - 126 ("~") minus the 5 belo

    html_entities = {
      '"' => 'quot', "'" => 'apos', '&' => 'amp', '<' => 'lt', '>' => 'gt',
    }

    define_method :_escape_string do | string, & oes_p |

      # currently we go with a narrow whitelist. in the future we could
      # expand this trivially but currently extenstive support for HTML
      # escaping is wayy outside the scope of all of this

      xtra_a = nil
      x = string.gsub deny_rx do

        s = $~[1]
        ent = html_entities[ s ]

        if ent
          "&#{ ent };"
        else
          ( xtra_a ||= [] ).push s
          nil
        end
      end

      if xtra_a
        oes_p.call :error, :invalid_characters do
          __build_invalid_characters_event xtra_a.uniq
        end
      else
        x
      end
    end

    def __build_invalid_characters_event xtra_a

      Models_::DotFile::Events_::Invalid_Characters.new_with :chars, xtra_a
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