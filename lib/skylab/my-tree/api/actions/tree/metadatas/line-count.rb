module Skylab::MyTree
  module API::Actions::Tree::Metadatas

    rx = /\A[ ]*(?<num_lines>\d+)/

    LINE_COUNT = -> memo_a, line, request_client do
      if ::File.file? line
        ::Open3.popen3 "wc -l #{ line.shellescape }" do |sin, sout, serr|
          '' == (e = serr.read) or fail e # meh
          x = rx.match( sout.read )[:num_lines]
          memo_a.push "#{ x } lines"
        end
      end
      memo_a
    end
  end
end
