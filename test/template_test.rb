require 'creole/template'

describe Creole::Template do
  it 'should be registered for .creole files' do
    Tilt.mappings['creole'].should.equal Creole::Template
  end

  it 'should prepare and evaluate templates on #render' do
    template = Creole::Template.new { |t| '= Hello World!' }
    3.times { template.render.should.equal '<h1>Hello World!</h1>' }
  end
end
