# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "advent"

require "minitest/autorun"

DUMMY_ROOT_PATH = Pathname.new File.expand_path("dummy", __dir__)

class Advent::TestCase < Minitest::Test
  def with_stdin_input(input)
    require "stringio"

    io = MockSTDIN.new
    io.puts input
    io.rewind

    real_stdin, $stdin = $stdin, io
    yield
  ensure
    $stdin = real_stdin
  end

  def with_readline_input(input)
    require "readline"

    input_file_name = "#{name}.input"

    f = File.open(input_file_name, "w+")
    f.write input
    f.rewind

    ::Readline.input = f
    yield
  ensure
    f.close
    File.delete input_file_name
  end
end

class MockHTTP
  def initialize
    @responses = {}
  end

  def add_response(url, cookie, body)
    @responses[url] = {body: body, cookie: cookie}
  end

  def get(uri, headers)
    if (response = @responses[uri.to_s]) && response[:cookie] == headers["Cookie"]
      response[:body]
    end
  end
end

class MockSTDIN < StringIO
  def noecho
    yield self
  end
end
