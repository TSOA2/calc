require "./parse.cr"
require "./lex.cr"

module Calc
  module SP
    private def self.combine_nums(n : BN) : Parser::Node
      if n.left.id == ID::Number && n.right.id == ID::Number
        NN.new(n.eval)
      else
        n
      end
    end

    private def self.simplify_pow(n : BN) : Parser::Node
      r = simplify n.right
      if r.id == ID::Number
        if r.as(NN).num == 0.0
          return NN.new(1.0)
        elsif r.as(NN).num == 1.0
          return n.left.clone
        end
      end
      BN.new(ID::Power, simplify(n.left), r)
    end

    private def self.simplify_mul(n : BN) : Parser::Node
      lr = {simplify(n.left), simplify(n.right)}
      rl = lr.reverse
      lr.map_with_index { |s, i|
        if s.id == ID::Number
          if s.as(NN).num == 1.0
            return rl[i]
          elsif s.as(NN).num == 0.0
            return NN.new(0.0)
          end
        end

        if s.id == ID::Divide
          sr = s.as(BN).right
          if rl[i].equals(sr)
            return s.as(BN).left
          end
        end

        if rl[i].id == ID::Number
          if s.id == ID::Multiply
            slr = { s.as(BN).left, s.as(BN).right }
            srl = slr.reverse
            slr.map_with_index { |z, j|
              if z.id == ID::Number
                return BN.new(ID::Multiply,
                  NN.new(BN.new(ID::Multiply, z, rl[i]).eval),
                  srl[j])
              end
            }
          end
        end
      }
      return BN.new(ID::Multiply, lr[0], lr[1])
    end

    private def self.simplify_div(n : BN) : Parser::Node
      l, r = {simplify(n.left), simplify(n.right)}
      if l.id == ID::Number
        if l.as(NN).num == 0.0
          return NN.new(0.0)
        end
      end
      if r.id == ID::Number
        if r.as(NN).num == 1.0
          return l
        end
      end
      if l.equals(r)
        return NN.new(1.0)
      end
      BN.new(ID::Divide, l, r)
    end

    private def self.simplify_plus(n : BN) : Parser::Node
      lr = {simplify(n.left), simplify(n.right)}
      rl = lr.reverse
      lr.map_with_index { |s, i|
        if s.id == ID::Number
          if s.as(NN).num == 0.0
            return rl[i]
          end
        end

        if s.id == ID::Minus
          sr = s.as(BN).right
          if rl[i].equals(sr)
            return s.as(BN).left
          end
        end

        if rl[i].id == ID::Number
          if s.id == ID::Plus
            slr = { s.as(BN).left, s.as(BN).right }
            srl = slr.reverse
            slr.map_with_index { |z, j|
              if z.id == ID::Number
                return BN.new(ID::Plus,
                  NN.new(BN.new(ID::Plus, z, rl[i]).eval),
                  srl[j])
              end
            }
          end
        end
      }
      BN.new(ID::Plus, lr[0], lr[1])
    end

    private def self.simplify_minus(n : BN) : Parser::Node
      l, r = {simplify(n.left), simplify(n.right)}
      if r.id == ID::Number
        if r.as(NN).num == 0.0
          return l
        end
      end
      if l.equals(r)
        return NN.new(0.0)
      end

      BN.new(ID::Minus, l, r)
    end

    def self.simplify(ast : Parser::Node) : Parser::Node
      if ast.id == ID::Number || ast.id == ID::X
        return ast.clone
      end

      node = case ast.id
      when ID::Power    then simplify_pow(ast.as(BN))
      when ID::Multiply then simplify_mul(ast.as(BN))
      when ID::Divide   then simplify_div(ast.as(BN))
      when ID::Plus     then simplify_plus(ast.as(BN))
      when ID::Minus    then simplify_minus(ast.as(BN))
      else
        raise "Invalid AST node to simplify."
      end

      if node.id == ID::Number || node.id == ID::X
        return node
      end

      bn = node.as(BN)
      combine_nums(bn)
    end

    def self.simplify(runner : Runner) : Parser::Node
      simplify(runner.ast)
    end
  end
end
