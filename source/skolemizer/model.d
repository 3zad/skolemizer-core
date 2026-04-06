module skolemizer.model;

import std.string : format;

import std.algorithm;
import std.array;

public enum NodeType { Negation, Universal, Existential, Conjunction, Disjunction, Implication, Biconditional, Variable, Predicate, Function, SkolemFunction }

public struct ASTNode {
    NodeType type;
    dstring value;
    ASTNode* left;
    ASTNode* right;
    ASTNode*[] args; // for predicates and Skolem functions

    public string toString() const {
        if (type == NodeType.Variable) {
            return format("ASTNode[ type: %s, value: %s ]", type, value);
        } else if (type == NodeType.Predicate || type == NodeType.SkolemFunction || type == NodeType.Function) {
            string argsStr;
            foreach (arg; args) {
                argsStr ~= arg.toString() ~ ", ";
            }
            return format("ASTNode[ type: %s, value: %s, args: [%s] ]", type, value, argsStr);
        } else if (type == NodeType.Negation) {
            return format("ASTNode[ type: %s, operand: %s ]", type, left.toString());
        } else if (type == NodeType.Universal || type == NodeType.Existential) {
            return format("ASTNode[ type: %s, variable: %s, body: %s ]", type, value, left.toString());
        } else {
            return format("ASTNode[ type: %s, left: %s, right: %s ]", type, left.toString(), right.toString());
        }
    }
}

public hash_t hashOfASTNode(const ASTNode* node) {
    if (node is null) return 0;
    return cast(hash_t)cast(size_t)node;
}

public bool opEqualsASTNode(const ASTNode* a, const ASTNode* b) {
    return a is b;
}

public ASTNode* cloneAST(const ASTNode* node) {
    if (node is null) return null;

    auto copy = new ASTNode(node.type, node.value);
    copy.left = cloneAST(node.left);
    copy.right = cloneAST(node.right);
    copy.args = node.args.map!(arg => cloneAST(arg)).array;
    return copy;
}