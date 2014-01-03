module Skylab::TestSupport::Regret::API

  class Actions::DocTest::Templos__::Quickie < API::Support::Templo_

    OPTION_X_A__ = [

      :cover,
        :when_not_provided, -> do
          @cover = nil
        end, :when_provided, -> do
          @cover = true
          OPTION_PROCEDE__
        end, :summarize, -> y do
          y << "adds coverage hack to the end"
          y << "of the `describe` block"
        end,

      :exclude_regret_setup,
        :when_not_provided, -> do
          @do_include_regret_setup = true
        end, :when_provided, -> do
          @do_include_regret_setup = false
          OPTION_PROCEDE__
        end, :summarize, -> y do
          y << "exerimental."
        end,

      :help,
        :when_not_provided, MetaHell::EMPTY_P_,
       :when_provided, -> do
          show_option_help
          SUCCESS_EXITSTATUS__
        end, :summarize, -> y do
          y << "this screen."
        end ]

    def initialize snitch, base_mod, c_a, b_a
      @snitch = snitch

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
        example: render_example }.freeze

      render_tests = -> blk, cnum do
        y = ( rtma ||= Basic::List::Marginated::Articulation.new "\n" )
        part_a = self.class::Context__::Part_.resolve_parts blk, rlma
        part_a.each do |part|
          y << template_h.fetch( part.template_i )[ part, cnum ]
        end
        y.flush
      end

      context_descify = -> blk, num do
        if blk.first_other
          API::Support::Templo_::FUN::Descify[ blk.first_other ]
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

      @render_to_p = -> io do
        baset = rslv_some_base_template
        ctxt, tstt, beft = get_templates :_ctx, :_tst, :_bef
        c_a.length < 2 and fail say_less_than_two c_a
        acon = c_a.fetch 0
        amod  = [ base_mod.to_s, acon ].join DCOLON__
        bmod = if 2 != c_a.length
          "#{ DCOLON__ }#{ c_a[ 1 .. -2 ] * DCOLON__ }"
        end
        cmod = "#{ c_a.fetch( -1 ) }"
        body = render_body[]
        io.write baset.call( amod: amod, bmod: bmod, cmod: cmod, body: body,
                             cover: render_cover( acon, bmod, cmod ),
                             acon: acon )
        SUCCEEDED__
      end ; nil
    end

    def rslv_some_base_template
      _i = @do_include_regret_setup ? :_base : :_sibling
      get_template _i
    end

    def say_less_than_two c_a
      "sanity - hard-coded for deep paths, we need at least 2 elements in #{
        }this path for the hacking to work - #{ c_a * DCOLON__ }"
    end

    def render_cover a, any_b, c
      if @cover
        mod = "#{ a }#{ any_b }#{ DCOLON__ }#{ c }"
        get_template( :_cover )[ mod: mod ].chomp
      end
    end

    DCOLON__ = '::'.freeze
    OPTION_PROCEDE__ = nil
    SUCCESS_EXITSTATUS__ = 0
    SUCCEEDED__ = true

  end
end
