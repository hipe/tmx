require File.expand_path('../../task', __FILE__)
require 'skylab/face/open2'
require 'skylab/face/path-tools'
require 'pathname'

require 'net/http'

module Skylab::Dependency
  class TaskTypes::Get < Task
    include ::Skylab::Face::Open2
    include ::Skylab::Face::PathTools::InstanceMethods

    attribute :from
    attribute :get, :required => true

    attribute :build_dir, :required => true, :from_context => true
    attribute :dry_run, :boolean => true, :from_context => true

    emits(:all,
      :info => :all,
      :error => :all,
      :shell => :all,
      :stdout => :all,
      :stderr => :all
    )

    def bytes path
      File.stat(path).size if File.exist?(path)
    end

    def execute args
      @context ||= (args[:context] || {})
      valid? or raise(invalid_reason)
      workunits = []
      pairs.each do |from_url, to_file|
        case (bytes = self.bytes(to_file))
        when nil
          workunits.push [from_url, to_file]
        when 0
          emit :info, "had zero byte file (strange), overwriting: #{pretty_path to_file}"
          workunits.push [from_url, to_file]
        else
          emit :info, "assuming already downloaded b/c exists " <<
            "(erase/move to re-download): #{pretty_path to_file}"
        end
      end
      ! workunits.map do |from_file, to_file|
        curl_or_wget from_file, to_file
      end.index{ |b| ! b }
    end

    def pairs
      if @from.nil?
        Pathname.new(@get).tap { |pn| @from = pn.dirname.to_s; @get = pn.basename.to_s }
      end
      get_these = @get.kind_of?(Array)?  @get : [@get]
      get_these.map do |tail|
        [File.join(@from, tail), File.join(build_dir, tail)]
      end
    end

    def curl_or_wget from_url, to_file
      cmd = "curl -o #{escape_path(pretty_path to_file)} #{from_url}"
      # cmd = "wget -O #{escape_path to_file} #{from_url}"
      emit(:shell, cmd)
      uri = URI.parse(from_url)
      response = nil
      Net::HTTP.start(uri.host, uri.port) do |h|
        req = Net::HTTP::Get.new(uri.request_uri)
        response = h.request req
      end
      # the *only* distinguishing thing that adsf does in lieu of a 404 is
      # that it does not send a "last-modified" header (and writes a message in the body)
      if response.to_hash.key?('last-modified')
        File.open(to_file, 'w+') { |fh| fh.write(response.body) }
        true
      else
        emit(:error, "File not found: #{from_url}")
        false
      end
    end
  end
end

