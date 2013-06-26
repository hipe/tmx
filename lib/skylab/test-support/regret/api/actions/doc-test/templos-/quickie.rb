module Skylab::TestSupport::Regret::API

  class Actions::DocTest::Templos_::Quickie < API::Support::Templo_

    def initialize base_mod, c_a, b_a
      ctxt = tstt = beft =
        rtma = rbma = rlma = nil  # memoize articulators just for the snarks

      rlma = MetaHell::FUN.memoize[ -> do
        mgn = tstt.first_margin_for :code
        mgn =~ /\A[ ]+\z/ or fail "sanity - clean margin? #{ mgn.inspect }"
        Basic::List::Marginated::Articulation.new do
          any_subsequent_items -> s do
            if s.length.zero? then "\n" else
              "\n#{ mgn }#{ s }"  # don't add trailing spaces
            end
          end
        end
      end ]

      render_before = -> befor, cnum do
        beft[
          context_num: cnum,
          code: befor.indented_code_string
        ].chomp
      end

      render_example = -> example, cnum do
        tstt[
          context_num: cnum,
          dsc: example.quoted_description_string,
          code: example.indented_code_string
        ].chomp
      end

      template_h = {
        before: render_before,
        example: render_example
      }

      render_tests = -> blk, cnum do
        y = ( rtma ||= Basic::List::Marginated::Articulation.new "\n" )
        part_a = self.class::Context_::Part_.resolve_parts blk, rlma
        part_a.each do |part|
          y << template_h.fetch( part.template_i )[ part, cnum ]
        end
        y.flush
      end

      context_descify = -> blk, num do
        if blk.first_other
          API::Support::Templo_::FUN.descify[ blk.first_other ]
        else
          "context #{ num }".inspect
        end
      end

      render_body = -> do
        y = ( rbma ||= Basic::List::Marginated::Articulation.new "\n" )
        b_a.each do |blk|
          num = y.count + 1
          y << ctxt[
            num: num,
            dsc: context_descify[ blk, num ],
            body: render_tests[ blk, num ]
          ].chomp
        end
        y.flush
      end

      @render_to = -> io do
        baset, ctxt, tstt, beft = get_templates :_base, :_ctx, :_tst, :_bef
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
