require_relative 'test-support'

module Skylab::System::TestSupport

  describe "[sy] - services - find" do

    TS_[ self ]

    it "minimal working example - find one file" do

      _args = _parent_subject.find :path, TS_.dir_path,
        :filename, 'find_spec.*',
        :when_command, -> command do
          command.args
        end

      act = _args.dup
      # == BEGIN at #history-B.1 (GNU find not BSD find) changed in these ways:
      # - offset 2 not 3 YUCK
      # - no more "--"
      act[ 2 ] = 'XX'  # changed from 3 to 2 at #history-B.1 YUCK
      act == %w'find -H XX ( -name find_spec.* )' || fail
      # == END
    end

    it "emits an informational event upon request" do

      ev = nil

      _cmd_o = _parent_subject.find(
        :path, 'doozie',
        :filename, '&![]',
        :when_command, -> cmd_o do
          cmd_o
        end,
      ) do |sym, *_, & ev_p|
          if :info == sym
            ev = ev_p[]
          else
            raise ev.to_exception
          end
          :_no_see_
        end

      expect( ev.find_command_args ).to eql _cmd_o.args
    end

    it "(experiment with EN)" do

      _x = _dangerously_memoized

      _np_like = _x.express_under :EN

      _expag = expression_agent_of_API_classic_

      _s_a = _np_like.express_words_into_under [], _expag

      _s = Home_.lib_.human::PhraseAssembly::Sentence_string_head_via_words[ _s_a ]

      expect( _s ).to eql 'whose name matched "*.code" in «x» and «y»'
    end

    define_method :_dangerously_memoized, -> do
      x = nil
      -> do
        x ||= __build
      end
    end.call

    def __build

      _parent_subject.find(
        :paths, [ 'x', 'y' ],
        :filename, '*.code',
        :when_command, -> x { x },  # IDENTITY_
      )
    end

    def _subject_module
      Home_::Filesystem::Service
    end

    def _parent_subject
      services_
    end
  end
end
# #history-B.1: target Ubuntu not OS X
