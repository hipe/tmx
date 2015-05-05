require_relative '../test-support'

module Skylab::Headless::TestSupport::System::Services::Filesystem::Path_Tools::Pretty_Path

  ::Skylab::Headless::TestSupport::System::Services::Filesystem::Path_Tools[ self ]

  include Constants

  Headless_ = Headless_

  module ModuleMethods

    def frame & p
      context( & p )
    end

    [ :home, :pwd ].each do |i|

      define_method i do | * a |
        method_i = :"#{ i }_x"
        if a.length.zero?
          send method_i
        else
          x = a.first
          define_singleton_method method_i do
            x
          end
        end
      end
    end

    def exemplifying s, * a, & p

      setup_frame_p = -> do

        _home_p = -> { home_x }
        _pwd_p = -> { pwd_x }

        Headless_::System__::Services__::Filesystem::Path_Tools__::Clear__[ _home_p, _pwd_p ]

        setup_frame_p = Headless_::EMPTY_P_
      end

      define_method :setup_frame do
        setup_frame_p[]
      end

      context s, * a, & p

    end

    def o input, expected, * a

      _verb_phrase_s = if expected == input
        'does not change'
      else
        "prettifies to #{ expected.inspect }"
      end

      it "#{ input.inspect } #{ _verb_phrase_s }", * a do

        setup_frame
        result_x = subject.pretty_path input
        result_x.should eql expected
      end
    end

    def home_x
    end

    def pwd_x
    end
  end

  module InstanceMethods

    define_method :subject, -> do
      subj = nil
      -> do
        subj ||= super()
      end
    end.call

  end
end
