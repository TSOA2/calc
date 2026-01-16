require "./parse.cr"
require "./lex.cr"

module Calc
  struct DV
    def initialize
    end

    def diff(ast : Parser::Node) : Parser::Node
      case ast.id
      when ID::Power
        bn = ast.as(BN)
        if bn.right.is_constant
          BN.new(ID::Multiply,
            NN.new(bn.right.eval),
            BN.new(ID::Power,
              bn.left.clone,
              BN.new(ID::Minus, bn.right.clone, NN.new(1.0))))
        else
          raise "Derivatives for non-constant powers not implemented yet."
        end
      when ID::Multiply
        bn = ast.as(BN)
        f = bn.left.clone
        g = bn.right.clone
        fd = diff f
        gd = diff g
        BN.new(ID::Plus,
          BN.new(ID::Multiply, f, gd),
          BN.new(ID::Multiply, g, fd))
      when ID::Divide
        bn = ast.as(BN)
        f = bn.left.clone
        g = bn.right.clone
        fd = diff f
        gd = diff g
        BN.new(ID::Divide,
          BN.new(ID::Minus,
            BN.new(ID::Multiply, g, fd),
            BN.new(ID::Multiply, f, gd)),
          BN.new(ID::Power, g, NN.new(2)))
      when ID::Plus
        bn = ast.as(BN)
        BN.new(ID::Plus, diff(bn.left), diff(bn.right))
      when ID::Minus
        bn = ast.as(BN)
        BN.new(ID::Minus, diff(bn.left), diff(bn.right))
      when ID::Number
        NN.new(0.0)
      when ID::X
        NN.new(1.0)
      else
        raise "Invalid AST node for derivative."
      end
    end

    def diff(runner : Runner) : Parser::Node
      diff(runner.ast)
    end
  end
end
