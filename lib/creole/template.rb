require 'tilt'
require 'creole'

module Creole
  class Template < Tilt::Template
    def prepare
      opts = {}
      [:allowed_schemes, :extensions, :no_escape].each do |k|
        opts[k] = options[k] if options[k]
      end
      @creole = Creole::Parser.new(data, opts)
      @output = nil
    end

    def evaluate(scope, locals, &block)
      @output ||= @creole.to_html
    end
  end
end

Tilt.register 'creole', Creole::Template
