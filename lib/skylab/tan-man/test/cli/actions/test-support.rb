require_relative '../test-support'

module Skylab::TanMan::TestSupport::CLI::Actions
  ::Skylab::TanMan::TestSupport::CLI[ Actions_TestSupport = self ]

  include CONSTANTS


  if defined? ::RSpec             # ack - avoid loading rspec-depedant things
    require_relative 'for-rspec'  # when we are running (e.g. visal tests)
  end                             # without rspec -- we might be weening off


  module InstanceMethods

    def cd pathname, &block
      fu = Headless::IO::FU.new -> msg do
        if do_debug
          TestSupport::Stderr_[].puts "    (tanmun vreeboze: #{ msg })"
        end
      end
      fu.cd pathname, &block
    end

    def client
      @client ||= build_client
    end

    def build_client
      spy = output # IO::Spy::Group
      o = TanMan::CLI.new nil, spy.for( :paystream ), spy.for( :infostream )
      o.program_name = 'timmin'
      o
    end


    attr_reader :dotfile_pathname


    def using_dotfile str
      clear_and_prepare
      pathname = tanman_tmpdir.touch 'floo.dot'
      pathname.open( 'w' ) { |fh| fh.write str }
      with_config  using_dotfile: 'floo.dot'
      @dotfile_pathname = pathname
      nil
    end

    def using_config whole_string  # will clear tmpdir too
      clear_and_prepare
      with_config_file_handle_and_get_pathname do |fh|
        fh.write whole_string
      end
    end

    def clear_and_prepare
      clear_api_if_necessary
      tanman_tmpdir.prepare
      nil
    end

    def with_config hash         # assume tmpdir has been cleared
      lines = hash.reduce( [ ] ) do |m, (k, v)|
        /\A[_a-z]+\z/ =~ k.to_s or fail 'sanity'
        m << "#{ k }= #{ v }"
        m
      end
      with_config_file_handle_and_get_pathname do |fh|
        lines.each do |line|
          fh.puts line
          if do_debug
            TestSupport::Stderr_[].puts "local-conf.d/config: #{ line }"
          end
        end
      end
    end

    def with_config_file_handle_and_get_pathname
      pathname = tanman_tmpdir.touch_r 'local-conf.d/config'
      pathname.open( 'w' ) do |fh|
        yield fh
      end
      pathname
    end
  end
end
