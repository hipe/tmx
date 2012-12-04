module Skylab::Dependency
  class TaskTypes::VersionFrom < Dependency::Task
    include Face::Open2

    attribute :must_be_in_range
    attribute :parse_with
    attribute :show_version, :from_context => true, :boolean => true
    attribute :version_from, :required => true

    emits :all, :info => :all, :payload => :all


    rx_rx = %r{\A/(.+)/([a-z]*)\z}
    modifier_rx = /\A[imox]*\z/

    define_method :build_regex do |str|
      md = rx_rx.match str
      if md
        regex_body, modifiers = md.captures
        modifier_rx =~ modifiers or
          fail("had modifiers #{modifiers.inspect}, need #{modifier_rx.source}")
        ::Regexp.new regex_body, modifiers
      else
        fail "Failed to parse regexp: #{ str.inspect }. #{
          }#{ rx_rx.source }"
      end
    end

    def build_version_range
      @must_be_in_range or fail(<<-S.gsub(/\n */,' ').strip)
        Do not use "version from" as a target without a "must be in range" assertion.
      S
      TaskTypes::VersionRange.build @must_be_in_range
    end

    def check_version
      version_range = build_version_range
      version_string = get_version_string
      if version_range.match(version_string)
        emit :info, "#{hi 'version ok'}: version #{version_string} " <<
          "is in range #{version_range}"
        true
      else
        emit :info, "#{no 'version mismatch'}: needed #{version_range} " <<
          "had #{version_string}"
        false
      end
    end

    def execute args
      @context ||= (args[:context] || {})
      valid? or fail(invalid_reason)
      show_version? ? _show_version : check_version
    end

    def get_version_string
      parse_version_string.first
    end

    def parse_version_string
      @parse_with and @regex = build_regex(@parse_with)
      buffer = Dependency::Services::StringIO.new
      read = lambda { |s| buffer.write(s) }
      open2(version_from) { |on| on.out(&read); on.err(&read) }
      str = buffer.rewind && buffer.read
      if @regex and @regex =~ str
        [$1, true]
      else
        [str, false]
      end
    end

    def _show_version
      version, used_regex = parse_version_string
      (used_regex ? [version] : version.split("\n")).each do |line|
        emit :payload, "#{hi 'version:'} #{line}"
      end
      true
    end
  end
end
