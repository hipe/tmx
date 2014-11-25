module Skylab::TestSupport

  module Regret::API

  class Actions::DocTest::Templos__::Quickie < API_::Support::Templo_

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
          y << "experimental."
        end,

      :help,
        :when_not_provided, EMPTY_P_,
       :when_provided, -> do
          show_option_help
          SUCCESS_EXITSTATUS__
        end, :summarize, -> y do
          y << "this screen."
        end ]

    def initialize snitch, base_mod, c_a, b_a
      @snitch = snitch

      ctxt = tstt = beft = nil

      rlma = Callback_.memoize do

        _MARGIN = tstt.first_margin_for :code

        Callback_::Scn.articulators.eventing(
          :any_subsequent_items, -> y, x do
            if x.length.zero?
              y << NEWLINE_
            else
              y << "#{ NEWLINE_ }#{ _MARGIN }#{ x }"  # don't add trailing spaces
            end
          end,
          :y, [],
          :flush, -> y do
            x = y * EMPTY_S_
            y.clear
            x
          end )
      end

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
        y = Inner_line_joiner__[].rewind
        part_a = self.class::Context__::Part_.resolve_parts blk, rlma
        part_a.each do |part|
          y.puts template_h.fetch( part.template_i )[ part, cnum ]
        end
        y.flush
      end

      context_descify = -> blk, num do
        if blk.first_other
          API_::Support::Templo_.descify blk.first_other
        else
          "context #{ num }".inspect
        end
      end

      render_body = -> do
        y = Outer_line_joiner__[].rewind
        b_a.each do |blk|
          num = y.count + 1
          y.puts ctxt[
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
        amod  = [ base_mod.to_s, acon ].join CONST_SEP_
        bmod = if 2 != c_a.length
          "#{ CONST_SEP_ }#{ c_a[ 1 .. -2 ] * CONST_SEP_ }"
        end
        cmod = "#{ c_a.fetch( -1 ) }"
        body = render_body[]
        desc = Generate_description__[ c_a ]
        io.write baset.call( amod: amod, bmod: bmod, cmod: cmod, body: body,
                             cover: render_cover( acon, bmod, cmod ),
                             desc: desc, acon: acon )
        ACHIEVED_
      end ; nil
    end

    def rslv_some_base_template
      _i = @do_include_regret_setup ? :_base : :_sibling
      get_template _i
    end

    def say_less_than_two c_a
      "sanity - hard-coded for deep paths, we need at least 2 elements in #{
        }this path for the hacking to work - #{ c_a * CONST_SEP_ }"
    end

    def render_cover a, any_b, c
      if @cover
        mod = "#{ a }#{ any_b }#{ CONST_SEP_ }#{ c }"
        get_template( :_cover )[ mod: mod ].chomp
      end
    end

    Autoloader_[ Context__ = ::Module.new ]  # #stowaway

    Generate_description__ = -> c_a do
      "[#{ Infer_Initials__[ c_a.first ] }] #{ c_a[ 1 .. -1 ] * CONST_SEP_ }"
    end

    Infer_Initials__ = -> do
      h = {}
      rx = %r{  \A  ([A-Z])  ([a-z])  [^A-Z]*  ([A-Z])?  }x
      infer = -> i do
        md = rx.match i.to_s
        if md
          "#{ md[1].downcase }#{ md[3] ? md[3].downcase : md[2] }"
        else
          i.to_s
        end
      end
      -> i do
        h.fetch i do
          h[ i ] = infer[ i ]
        end
      end
    end.call

    OPTION_PROCEDE__ = nil

    Inner_line_joiner__ = Callback_.memoize do
      Line_joiner__[].duplicate
    end

    Outer_line_joiner__ = Callback_.memoize do
      Line_joiner__[].duplicate
    end

    Line_joiner__ = Callback_.memoize do

      Callback_::Scn.articulators.eventing(
        :y, [],
        :any_subsequent_items,  -> y, x do
          y.push "#{ NEWLINE_ }#{ x }" ; nil
        end,
        :flush, -> y do
          x = y * EMPTY_S_
          y.clear
          x
        end )
    end

    SUCCESS_EXITSTATUS__ = 0

    Autoloader_[ self, ::Pathname.new( __FILE__ ).sub_ext( EMPTY_S_ ) ]
  end
  end
end
