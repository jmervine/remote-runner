require 'simplecov'
SimpleCov.start do
  add_filter "/vendor/"
  add_filter "/coverage/"
  add_filter "/doc/"
end

require './lib/remote_runner'
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
  #puts result.string
  result.string
end

