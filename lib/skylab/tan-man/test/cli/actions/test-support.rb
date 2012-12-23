require_relative '../test-support'

module Skylab::TanMan::TestSupport::CLI::Actions
  ::Skylab::TanMan::TestSupport::CLI[ self ]

  if defined? ::RSpec             # ack - avoid loading rspec-depedant things
    require_relative 'for-rspec'  # when we are running (e.g. visal tests)
  end                             # without rspec -- we might be weening off


  module InstanceMethods

    def cd pathname, &block
      fu = Headless::IO::FU.new -> msg do
        if do_debug
          $stderr.puts "    (tanmun vreeboze: #{ msg })"
        end
      end
      fu.cd pathname, &block
    end

    let :client do # todo how do the other clients function?
      spy = output # StreamSpy::Group
      o = TanMan::CLI.new nil, spy.for( :paystream ), spy.for( :infostream )
      o.program_name = 'timmin'
      o
    end


    attr_reader :dotfile_pathname


    def using_dotfile str
                                  # HUGE TEARDOWN BEGIN:
      if ! api_was_cleared        # ACK sorry we have no nested before hooks
        TanMan::Services.services.api.clear_all_services # when using Quicike!!
      end
      tanman_tmpdir.prepare
                                  # huge teardown END

      pathname = tanman_tmpdir.touch 'floo.dot'
      pathname.open( 'w' ) { |fh| fh.write str }
      with_config  using_dotfile: 'floo.dot'
      @dotfile_pathname = pathname
      nil
    end


    def with_config hash         # assume tmpdir has been cleared
      lines = hash.reduce( [ ] ) do |m, (k, v)|
        /\A[_a-z]+\z/ =~ k.to_s or fail 'sanity'
        m << "#{ k }= #{ v }"
        m
      end
      pathname = tanman_tmpdir.touch_r 'local-conf.d/config'
      pathname.open( 'w' ) do |fh|
        lines.each do |line|
          fh.puts line
          if do_debug
            $stderr.puts "local-conf.d/config: #{ line }"
          end
        end
      end
      pathname
    end
  end
end
