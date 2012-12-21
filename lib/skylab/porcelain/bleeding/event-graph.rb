module Skylab::Porcelain::Bleeding
  EVENT_GRAPH = {         # didactic, not prescriptive
    help:                 :all,
    error:                :all,
    ambiguous:            :error,
    not_found:            :error,
    not_provided:         :error,
    syntax_error:         :error
  }
end
