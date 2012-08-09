require 'simplecov'
SimpleCov.start do
  add_filter "/vendor/"
  add_filter "/coverage/"
  add_filter "/doc/"
  add_filter "/spec/"
  add_filter "version.rb"
end

ENV['RR_FILE'] = nil

require './lib/remote'
require './lib/remote/version'
require 'stringio'

def capture(*streams)
  streams.map! { |stream| stream.to_s }
  begin
    result = StringIO.new
    streams.each { |stream| eval "$#{stream} = result" }
    yield
  ensure
    streams.each { |stream| eval("$#{stream} = #{stream.upcase}") }
  end
  #pp result.string
  result.string
end

