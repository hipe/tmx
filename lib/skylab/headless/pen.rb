module Skylab::Headless

  module Pen                      # `Pen` (at this level) is an experimental
    # pure namespace.             # attempt to generalize and unify a subset
  end                             # of interface-level string decorating
                                  # functions so that the same utterances can
                                  # be articulated across multiple modalities
                                  # to whatever extent possible.
  module Pen::InstanceMethods
    def em s
      s
    end

    white_rx = /[[:space:]]/

    define_method :human_escape do |s|         # like shell_escape but for
      white_rx =~ s ? s.inspect : s            # humans -- basically use quotes
    end                                        # iff necessary (né smart_quotes)

    def ick s                     # render an invalid value
      s
    end

    def kbd s
      em s
    end
  end

  Pen::MINIMAL = ::Object.new.extend Pen::InstanceMethods
end
