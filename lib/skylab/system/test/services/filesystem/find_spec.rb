require_relative '../../test-support'

module Skylab::System::TestSupport

  describe "[sy] - services - filesystem - find" do

    extend TS_

    it "minimal working example - find one file" do

      args = _parent_subject.find :path, TS_.dir_pathname.to_path,
        :filename, 'find_spec.*',
        :as_normal_value, -> command do
          command.args
        end

      [ * args[ 0, 2 ], 'XX', * args[ 3..-1 ] ].should eql(
        %w'find -f XX -- ( -name find_spec.* )' )
    end

    it "emits an informational event upon request" do

      ev = nil

      _cmd_o = _parent_subject.find(
        :path, 'doozie',
        :filename, '&![]',
        :as_normal_value, -> cmd_o do
          cmd_o
        end ) do | i, *_, & ev_p |
          if :info == i
            ev = ev_p[]
          else
            raise ev.to_exception
          end
          :_no_see_
        end

      ev.find_command_args.should eql _cmd_o.args
    end

    it "(experiment with EN)" do

      _x = _dangerously_memoized

      _np_like = _x.express_under :EN

      _expag = System_.lib_.brazen::API.expression_agent_instance

      _s_a = _np_like.express_words_into_under [], _expag

      _s = System_.lib_.human::NLP::EN.sentence_string_head_via_words _s_a

      _s.should eql 'whose name matched "*.code" in «x» and «y»'
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
        :as_normal_value, _subject_module::IDENTITY_ )
    end

    def _subject_module
      System_::Services___::Filesystem
    end

    def _parent_subject
      services_.filesystem
    end
  end
end
