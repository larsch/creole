require 'tilt'
require 'creole'

module Creole
  class Template < Tilt::Template
    def prepare
      @creole = Creole::Parser.new(data,
                                   :allowed_schemes => options[:allowed_schemes],
                                   :extensions => options[:extensions],
                                   :no_escape => options[:no_escape])
      @output = nil
    end

    def evaluate(scope, locals, &block)
      @output ||= @creole.to_html
    end
  end
end

Tilt.register 'creole', Creole::Template
