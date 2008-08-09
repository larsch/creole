require 'test/unit'
require 'creole'
require 'cgi'
require 'testcases'

$strict = false

class TestC < Test::Unit::TestCase
  include TestCases

  def tc(html, creole)
    output = Creole.creolize(creole)
    assert html === output, "Parsing: #{creole.inspect}\nExpected: #{html.inspect}\n     Was: #{output.inspect}"
  end
end
