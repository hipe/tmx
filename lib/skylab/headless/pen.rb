module Skylab::Headless

  module Pen                      # `Pen` (at this level) is an experimental
    # pure namespace.             # attempt to generalize and unify a subset
  end                             # of interface-level string decorating
                                  # functions so that the same utterances can
                                  # be articulated across multiple modalities
                                  # to whatever extent possible.
  module Pen::InstanceMethods
                                  # (trying to use these when appropriate:
                        # http://www.w3schools.com/tags/tag_phrase_elements.asp)

    def em s                      # style for emphasis
      s
    end

    def hdr s                     # style as a header
      em s
    end

    def h2 s                      # style as a smaller header
      hdr s
    end

    white_rx = /[[:space:]]/

    define_method :human_escape do |s|         # like shellescape but for
      white_rx =~ s ? s.inspect : s            # humans -- basically use quotes
    end                                        # iff necessary (né smart_quotes)

    def ick s                     # style an invalid valid
      s
    end

    def kbd s                     # style as e.g kbd input, code
      em s
    end

    def omg s                     # style an error (string or msg)
      ick s                       # with excessive emphasis and
    end                           # exuberance. not for use.
  end

  Pen::MINIMAL = ::Object.new.extend Pen::InstanceMethods
end
