module Skylab::Porcelain::Bleeding
  EVENT_GRAPH = {         # didactic, not prescriptive
    help:                 :all,
    error:                :all,
    ambiguous:            :error,
    not_found:            :error,
    not_provided:         :error,
    optparse_parse_error: :error,
    syntax_error:         :error
  }
end
