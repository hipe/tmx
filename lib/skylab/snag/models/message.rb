module Skylab::Snag

  module Models::Message

    blank_rx = /\A[[:space:]]*\z/
    nl_rx = /\n/
    xnl_rx = /\\n/

    _chars_limit = nil
    define_singleton_method :chars_limit do
      _chars_limit ||= begin
        Models::Manifest.line_width - Models::Manifest.header_width
      end
    end

    define_singleton_method :normalize do |x, error, info=nil|
      res = nil
      err = -> errmsg do
        r = error[ errmsg ]
        res = r ? UNABLE_ : r  # [#017]
      end
      msg = x.to_s
      if blank_rx =~ msg
        err[ "message was blank." ]
      elsif nl_rx =~ msg
        err[ "message cannot contain newlines." ]
      elsif xnl_rx =~ msg
        err[ "message cannot contain (escaped or unescaped) newlines." ]
      elsif false && msg.length > chars_limit # LOOK off for now!
        err[ "for now, node messages have a narrow-assed limit #{
        }of #{ chars_limit } - your message was #{ msg.length } chars" ]
      else
        res = msg
      end
    end
  end
end
