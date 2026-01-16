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
        dv = DV.new
        ast = dv.diff(ast)
        puts "Derivative: #{ast}"
      when Options::ID::Simplify
        sp = SP.new
        ast = sp.simplify(ast)
        puts "Simplified: #{ast}"
      end
    }
  end
end

Calc.main
