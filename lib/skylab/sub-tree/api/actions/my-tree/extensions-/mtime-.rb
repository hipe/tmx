module Skylab::MyTree
  module API::Actions::Tree::Metadatas

    abbrv = ::Hash.new { |h, k| "#{ k }s" }
    abbrv[:second] = 'sec'
    abbrv[:minute] = 'min'
    abbrv[:hour] = 'hrs'
    abbrv[:day] = 'day'
    abbrv[:week] = 'wk'
    abbrv[:month] = 'mon'
    abbrv[:year] = 'yr'

    MTIME = -> memo_a, node, request_client do
      if node.file?
        x = node.seconds_old
        unit, amt = InformationTactics::Summarize::Time[ x ]
        memo_a.push "#{ amt.round } #{ abbrv[unit] }"
      end
      memo_a
    end
  end
end
