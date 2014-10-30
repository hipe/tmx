module Skylab::TestSupport::Regret::API

  module API::Actions::Recursive__

    class Special_Path

      TestSupport_::Callback_::Selective_listener.call self,
        :emission_matrix, [ :error ], [ :string ]

      module Hashtag_Bundles__
        Branch_down_to_core = -> do
          set_output_pathname_proc(
            Output_Pathname_Functions__::Branch_down_to_core )
          SUCCEEDED__
        end
        Regret_setup = -> yes_or_no do
          yes = case yes_or_no
          when 'yes' ; true
          when 'no'  ; false
          else bork "must have 'yes' or 'no', not #{ yes_or_no.inspect }"
          end
          if @is_valid
            @do_regret_setup = yes
            SUCCEEDED__
          end
        end
      end

      module Output_Pathname_Functions__
        Branch_down_to_core = -> op do
          _middle = op.tail_pn.sub_ext EMPTY_S_
          op.test_dir_pn.join _middle, "core_spec#{ op.tail_pn.extname }"
        end
        Default = -> op do
          _sfx = API::Actions::Recursive::TEST_FILE_SUFFIX
          tailpn = op.tail_pn
          _ext = tailpn.extname
          _tail = "#{ tailpn.sub_ext( EMPTY_S_ ) }#{ _sfx }#{ _ext }"
          op.test_dir_pn.join _tail
        end
      end

      def initialize listener, pn, x_a
        @construct_output_pn_p = Output_Pathname_Functions__::Default
        @did_explicate = nil ; @do_regret_setup = true
        @is_valid = true ; @listener = listener ; @pn = pn
        absorb_iambic_fully x_a
      end

      attr_reader :do_regret_setup, :is_valid
    private
      def absorb_iambic_fully x_a
        @x_a = x_a
        begin
          send :"#{ x_a.shift }="
        end while x_a.length.nonzero?
        @x_a = nil
      end

      def rest_s=
        @rest_s = @x_a.shift
        _scn = RegretLib_::Hashtag_scanner[ @rest_s ]
        @scn = Callback_::Scanner::Puts_Wrapper.new _scn
        validate_ht_scn ; nil
      end

      def validate_ht_scn
        @seen_hashtag_count = 0
        while (( o = @scn.gets ))
          :string == o.symbol_i and next
          :hashtag == o.symbol_i or raise say_strange_symbol( o )
          absrb_hashtag( o ) or break
        end ; nil
      end

      def say_strange_symbol o
        "unexpected: #{ o.symbol_i }"
      end

      def absrb_hashtag ht
        @seen_hashtag_count += 1
        o = @scn.peek
        if o && :hashtag_name_value_separator == o.symbol_i
          @scn.advance_one
          o = @scn.peek
          if o && :hashtag_value == o.symbol_i
            @scn.advance_one
            has_value = true
            value_s = o.to_s
          end
        end
        if has_value
          absrb_hashtag_stem_and_value ht.get_stem_s, value_s
        else
          absrb_hashtag_stem ht.get_stem_s
        end
      end

      def absrb_hashtag_stem_and_value stem_s, value_s
        bndl = prcr_any_bundle stem_s
        bndl and attmpt_complex_bundle bndl, value_s
      end

      def absrb_hashtag_stem stem_s
        bndl = prcr_any_bundle stem_s
        bndl and attmpt_simple_bundle bndl
      end

      def prcr_any_bundle stem_s
        const_i = prcr_some_const_i_from_hashtag_stem stem_s
        if Hashtag_Bundles__.const_defined? const_i, false
          Pretty_Bundle__[ Hashtag_Bundles__.const_get( const_i ), stem_s ]
        else
          bork say_non_redundant_thing stem_s
        end
      end

      def prcr_some_const_i_from_hashtag_stem s
        RegretLib_::Name_slug_to_const[ s ]
      end

      def say_non_redundant_thing stem_s
        stem_hashtag_s = "##{ stem_s }"
        if @did_explicate
          "also there is no bundle for #{ stem_hashtag_s }"
        else
          @did_explicate = true
          say_insane_explication stem_hashtag_s
        end
      end

      def say_insane_explication stem_hashtag_s
        _or_s = say_lev stem_hashtag_s
        "unrecognized hashtag #{ stem_hashtag_s }. did you mean #{ _or_s }?"
      end

      def say_lev stem_hashtag_s

        _items = Hashtag_Bundles__.constants.map( & Const_2_hashtag_s_ )

        RegretLib_::Levenshtein[].with(
          :item, stem_hashtag_s,
          :items, _items,
          :closest_N_items, 3,
          :item_proc, ::Proc.new( & :inspect ),
          :aggregation_proc, -> a { a * ' or ' } )
      end

      Const_2_hashtag_s_ = -> const_i do
        "##{ RegretLib_::Name_normal_to_slug[ NF__::Normify[ const_i ] ] }"
      end

      def attmpt_simple_bundle bndl
        ok = arity_check 0, bndl
        ok and employ_simple_bundle bndl
      end

      def attmpt_complex_bundle bndl, value_s
        ok = arity_check 1, bndl, value_s
        ok and employ_complex_bundle bndl, value_s
      end

      def arity_check d, bndl, * args
        d_ = bndl.proc.arity
        if d == d_ then true else
          when_bad_arity d, d_, bndl, args
        end
      end

      def when_bad_arity d, d_, bndl, args
        _extra = case d <=> 1
        when -1 ;
        when  0 ; ": #{ args.first.inspect }"
        when  1 ; ": #{ args.first.inspect } [..]"
        end
        bork "#{ bndl.stem_hashtag_s } takes #{ d_ } #{
          }argument#{ 's' if 1 != d_ }, had #{ d }#{ _extra }."
      end

      def employ_simple_bundle bndl
        instance_exec( & bndl.proc )
      end

      def employ_complex_bundle bndl, value_s
        instance_exec value_s, & bndl.proc
      end

      Pretty_Bundle__ = ::Struct.new :proc, :stem
      class Pretty_Bundle__
        def stem_hashtag_s
          "##{ stem }"
        end
      end

    public

      def to_path
        @pn.to_path
      end

      def to_s
        "#{ @pn }#{ TWO_SPACES_FOR_AESTHETICS__ }#{ @rest_s }"
      end

      def construct_output_pathname op
        @construct_output_pn_p[ op ]
      end

    private

      def set_output_pathname_proc p
        @construct_output_pn_p = p ; nil
      end

      def bork msg
        emit_error_string msg
        @is_valid = false
      end

      SUCCEEDED__ = true
      TWO_SPACES_FOR_AESTHETICS__ = '  '.freeze
    end
  end
end
