#!/usr/bin/env ruby -w

require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Namespace::Desc

  ::Skylab::Face::TestSupport::CLI::Namespace[ This_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module Sandbox
  end

  CONSTANTS::Sandbox = Sandbox

  Face = Face

  module Wowzaa
    module CLI
      class Client < Face::CLI
        option_parser do |o|
          o.banner = "today\ntoday we're gonna"
        end
        def live_like
        end

        namespace :throw_it_in_a_fire,
            :desc, -> y { y << 'live' ; y << 'like' ; y << 'warrior' } do
          def in_the_fire
          end
        end
      end
    end
  end

  do_invoke = Do_invoke_[]

  describe "#{ Face::CLI }::Namespace desc" do

    extend This_TestSupport

    context "some context" do

      let :client_class do Wowzaa::CLI::Client end

      it "wahoo."
    end
  end

  if do_invoke  # try executing this file directly, passing '-x'
    Wowzaa::CLI::Client.new( nil, SO_, SE_ ).invoke( ::ARGV )
  end
end
