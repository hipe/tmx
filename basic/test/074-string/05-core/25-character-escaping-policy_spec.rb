require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe '[ba] string - core - character escaping policy' do

    # #born (through abstraction) to help out [bs]

    TS_[ self ]
    use :memoizer_methods

    it 'loads' do
      _subject_library || fail
    end

    context '(this one)' do

      it '`define` involves 2 vars not one EXPERIMENTALLY' do
        _subject || fail
      end

      it 'escapes programmatically' do
        _act = _call '"'
        _act == '\\"' || fail
      end

      it 'escapes using a static string' do

        act1 = _call NEWLINE_
        act2 = _call NEWLINE_

        act1 == '\\n' || fail
        act1 == act2 || fail
        act1.object_id == act2.object_id || fail
      end

      it %q(whines if you pass it something we don't normally escape) do
        begin
          _call 'q'
        rescue Home_::Exception => e
        end
        e.message == 'not (yet) policy-able: "q"' || fail
      end

      it 'whines for no policy' do
        begin
          _call "\b"
        rescue Home_::Exception => e
        end
        e.message == %q(no escaping policy is defined for "\b") || fail
      end

      def _subject
        _common_subject
      end
    end

    context '(redefinition)' do

      it 'redefines' do
        _subject || fail
      end

      it %q(does a new thing that was't set before) do
        _act = _call "\b"
        _act == '\b' || fail
      end

      it 'overwrites an existing thing that was set before' do
        _act = _call NEWLINE_
        _act == "\\\n" || fail
      end

      it 'still sees those old things' do
        _act = _call '"'
        _act == '\"' || fail
      end

      shared_subject :_subject do
        _common_subject.redefine do |o, so|
          o.newline = so.escape_it_with_a_backslash
          o.alert_bell = so.use_this_string_instead '\b'
        end
      end
    end

    shared_subject :_common_subject do
      # (originally based on targe use case, in [br])
      _subject_library.define do |o, so|
        o.double_quote = so.escape_it_with_a_backslash
        o.single_quote = so.escape_it_with_a_backslash
        o.newline = so.use_this_string_instead '\n'
        o.tab = so.use_this_string_instead '\t'
        o.alert_bell = nil  # just to avoid warning
      end
    end

    def _call escape_me_s
      _subject.call escape_me_s
    end

    def _subject_library
      Home_::String::CharacterEscapingPolicy
    end
  end
end
# #born.
