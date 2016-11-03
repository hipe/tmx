require_relative '../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI support - when - help - screen for branch" do

    # (we hate this placement (the node should be in e.g [ze] eventually)
    # but it is placed here for now to mirror its subject; it's out
    # of scope to rename for now so a #pending-rename.)

    TS_[ self ]
    use :memoizer_methods

    context "(please be a representative case.)" do

      it "the N expected sections occur in their expected order" do
        _sections
      end

      it "the subtracted item is not in the usage line" do
        s = _the_usage_line
        s.include? '-remote-primary-one' and fail
        s.include? '-remote-primary-two' or fail
      end

      it "the added item is in the usage line" do
        _the_usage_line.include? '-added-primary' or fail
      end

      it "both lines of the description are there" do
        em_a = _sections[ :description ].emissions
        em_a[0].string.include? "description: hello line 1" || fail
        em_a[1].string.include? "  hello line 2" || fail
      end

      it "the subtracted item has no entry in the items section" do
        h = _items_index
        h[ '-remote-primary-one' ] && fail
        h[ '-remote-primary-two' ] || fail
      end

      it "the added item does have an entry in the items section" do
        _items_index[ '-added-primary' ] || fail
      end

      shared_subject :_items_index do

        h = {}
        meh_rx = /\A[ ]{2,}(?<lemma>[^ ]+)[ ]{2}/

        em_a = _sections.fetch( :primaries ).emissions
        ( 1 ... em_a.length ).each do |d|
          s = em_a.fetch( d ).string
          s || next
          md = meh_rx.match s
          md || next
          h[ md[ :lemma ] ] = true
        end
        h
      end

      shared_subject :_the_usage_line do
        em_a = _sections.fetch( :usage ).emissions
        2 == em_a.length || fail
        em_a.first.string
      end

      shared_subject :_sections do

        sects_h = {}
        spy = __build_this_one_spy_around sects_h
        as = __build_this_one_argument_scanner
        __express_branch_help_screen spy.spying_IO, as
        spy.finish
        sects_h
      end

      def __build_this_one_spy_around sects_h

        o = TS_::CLI_Support::Expect_Section::FailEarly.define

        o.expect_section "usage" do |sect|
          sects_h[ :usage ] = sect
        end

        o.expect_section "description" do |sect|
          sects_h[ :description ] = sect
        end

        o.expect_section "primaries" do |sect|
          sects_h[ :primaries ] = sect
        end

        o.finish.to_spy_under self
      end

      # -
    end

    def __express_branch_help_screen io, as

      Home_::CLI_Support::When::Help::ScreenForEndpoint.express_into io do |o|

        _st = Stream_[ [ :remote_primary_one, :remote_primary_two ] ]
        _st = as.altered_primary_normal_symbol_stream_via _st
        o.primary_normal_symbol_stream _st

        o.express_usage_section "kansas witchita"

        o.express_description_section_by do |y|
          y << "hello line 1"
          y << "hello line 2"
        end

        _p = {  # fake backend primary description proc reader
          remote_primary_one: -> y do
            y << "remote primary one line 1"
            y << "remote primary one line 2"
          end,
          remote_primary_two: -> y do
            y << "remote primary two line 1"
            y << "remote primary two line 2"
          end,
        }

        _p = as.altered_description_proc_reader_via _p
        o.express_items_section _p
        NIL
      end
    end

    def __build_this_one_argument_scanner

      never_call = -> { fail }

      Home_.lib_.zerk::NonInteractiveCLI::MultiModeArgumentScanner.define do |o|

        o.subtract_primary :remote_primary_one

        o.add_primary :added_primary, never_call do |y|
          y << "hello i am the added primary"
        end

        o.user_scanner X_cs_w_STUB_NOT_EMPTY_SCANNER
      end
    end

    module X_cs_w_STUB_NOT_EMPTY_SCANNER ; class << self
      def no_unparsed_exists
        false
      end
    end ; end

    Stream_ = -> a, & p do  # until etc
      Common_::Stream.via_nonsparse_array a, & p
    end

    # ==
  end
end
