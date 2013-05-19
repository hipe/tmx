module Skylab::TestSupport::Regret::API

  class Actions::DocTest::Templos_::Quickie < API::Support::Templo_

    def initialize base_mod, c_a, b_a
      ctxt = tstt =
        rtma = rbma = rlma = nil  # memoize articulators just for the snarks

      render_lines = -> snp do
        y = ( rlma ||= begin
          mgn = tstt.first_margin_for :code
          mgn =~ /\A[ ]+\z/ or fail "sanity - clean margin? #{ mgn.inspect }"
          Basic::List::Marginated::Articulation.new do
            any_subsequent_items -> s do
              if s.length.zero? then "\n" else
                "\n#{ mgn }#{ s }"  # don't add trailing spaces
              end
            end
          end
        end )
        snp.a.each do |line|
          Actions::DocTest::Templos_::Predicates.lines y, line do
            y << line
          end
        end
        y.flush
      end

      render_tests = -> blk, cnum do
        y = ( rtma ||= Basic::List::Marginated::Articulation.new "\n" )
        blk.a.each do |snp|
          y << tstt[
            context_num: cnum,
            dsc: ( snp.last_other || "test #{ y.count + 1 }" ).inspect,
            code: render_lines[ snp ]
          ].chomp
        end
        y.flush
      end

      render_body = -> do
        y = ( rbma ||= Basic::List::Marginated::Articulation.new "\n" )
        b_a.each do |blk|
          num = y.count + 1
          y << ctxt[
            num: num,
            dsc: "context #{ num }".inspect,
            body: render_tests[ blk, num ]
          ].chomp
        end
        y.flush
      end

      @render_to = -> io do
        baset, ctxt, tstt = get_templates :_base, :_ctx, :_tst
        c_a.length < 2 and fail "sanity - hard-coded for deep paths, #{
          }we need at least 2 elements in this path for the hacking #{
          }to work - #{ c_a * '::' }"
        acon = c_a.fetch 0
        amod  = [ base_mod.to_s, acon ].join( '::' )
        bmod = if 2 == c_a.length then '' else
                 "::#{ c_a[ 1 .. -2 ] * '::' }"
               end
        cmod = "#{ c_a.fetch( -1 ) }"
        body = render_body[]
        io.write baset.call( amod: amod, bmod: bmod, cmod: cmod, body: body,
                             acon: acon )
        nil
      end
      nil
    end
  end
end
