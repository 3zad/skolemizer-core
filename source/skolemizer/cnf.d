module skolemizer.cnf;

import skolemizer.model;
import skolemizer.parser;

public ASTNode*[hash_t][hash_t] toDisjunctForm(ASTNode* node)
{
    // hashset workaround using an associative array
    ASTNode*[hash_t] clauses;
    splitOnConj(node, clauses);
    ASTNode*[hash_t][hash_t] disjunctClauses;
    foreach (hash, clause; clauses) {
        ASTNode*[hash_t] disjunctSet;
        splitOnDisj(clause, disjunctSet);
        disjunctClauses[hash] = disjunctSet;
    }
    return disjunctClauses;
}

private void splitOnDisj(ASTNode* node, ref ASTNode*[hash_t] disjuncts)
{
    if (node is null) return;

    if (node.type == NodeType.Disjunction) {
        splitOnDisj(node.left, disjuncts);
        splitOnDisj(node.right, disjuncts);
    } else {
        auto hash = hashOfASTNode(node);
        disjuncts[hash] = node;
    }
}

private void splitOnConj(ASTNode* node, ref ASTNode*[hash_t] clauses)
{
    if (node is null) return;

    if (node.type == NodeType.Conjunction) {
        splitOnConj(node.left, clauses);
        splitOnConj(node.right, clauses);
    } else {
        auto hash = hashOfASTNode(node);
        clauses[hash] = node;
    }
}


unittest
{
    import std.stdio;
    import skolemizer.parser;
    import skolemizer.lexer;
    import skolemizer.token;

    auto tokens = tokenize("a ∧ (b ∨ c)");
    auto ast = parse(tokens);
    auto clauses = toDisjunctForm(ast);
    writeln("Clauses:");
    writeln("{");
    foreach (hash, clause; clauses) {
        write("\t{");
        foreach (hash2, disjunct; clause) {
            write(*disjunct, ", ");
        }
        writeln("}");
    }
    writeln("}");
}
