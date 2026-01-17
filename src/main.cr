# Calculator: parses and does stuff with math expressions
# Made while procrastinating Calc HW

require "./options.cr"
require "./lex.cr"
require "./parse.cr"
require "./integrate.cr"
require "./derivative.cr"
require "./simplify.cr"

module Calc
  def self.main
    options = Options.new
    parser = Parser.new options.expr
    ast = parser.parse
    puts "Original: #{ast}"
    options.steps.each { |step|
      case step.id
      when Options::ID::Integrate
        data = step.data.as(Options::IGStep)
        ig = IG.new(data.method, data.low, data.high, data.parts)
        val = ig.integrate(Runner.new(parser, ast))
        puts "Integration: #{val}"
      when Options::ID::Derivative
        ast = DV.diff(ast)
        puts "Derivative: #{ast}"
      when Options::ID::Simplify
        ast = SP.simplify(ast)
        puts "Simplified: #{ast}"
      when Options::ID::Execute
        data = step.data.as(Options::EXStep)
        val = Runner.new(parser, ast).run(data.x)
        puts "Execute: #{val}"
      end
    }
  end
end

Calc.main
