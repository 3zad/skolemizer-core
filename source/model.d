module model;

import std.string : format;

public enum NodeType { Negation, Universal, Existential, Conjunction, Disjunction, Implication, Biconditional, Variable, Predicate, SkolemFunction }

public struct ASTNode {
    NodeType type;
    dstring value;
    ASTNode* left;
    ASTNode* right;
    ASTNode*[] args; // for predicates and Skolem functions

    public string toString() const {
        if (type == NodeType.Variable) {
            return format("ASTNode[ type: %s, value: %s ]", type, value);
        } else if (type == NodeType.Predicate || type == NodeType.SkolemFunction) {
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