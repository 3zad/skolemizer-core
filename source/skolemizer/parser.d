module skolemizer.parser;

import skolemizer.token;
import skolemizer.model;

import std.stdio;

public ASTNode* parse(Token[] tokens) {
    auto parser = Parser(tokens);
    return parser.parse();
}

// order of operations: Negation > Conjunction > Disjunction > Implication > Biconditional
private struct Parser {
    Token[] tokens;
    size_t  pos;

    Token peek()    { return tokens[pos]; }
    Token consume() { return tokens[pos++]; }

    bool check(TokenType tt) { return peek().tt == tt; }

    ASTNode* parse() { return parseBiconditional(); }

    ASTNode* parseBiconditional() {
        ASTNode* left = parseImplication();

        if (check(TokenType.BICONDITIONAL)) {
            consume();
            ASTNode* right = parseBiconditional();

            // rewrite to skip the double implication step
            ASTNode* notLeft  = new ASTNode(NodeType.Negation, ""d, left,  null);
            ASTNode* notRight = new ASTNode(NodeType.Negation, ""d, right, null);
            ASTNode* disj1    = new ASTNode(NodeType.Disjunction, ""d, notLeft,  right);
            ASTNode* disj2    = new ASTNode(NodeType.Disjunction, ""d, notRight, left);
            return new ASTNode(NodeType.Conjunction, ""d, disj1, disj2);
        }
        return left;
    }

    ASTNode* parseImplication() {
        ASTNode* left = parseDisjunction();

        if (check(TokenType.IMPLICATION)) {
            consume();
            ASTNode* right = parseImplication();
            return new ASTNode(NodeType.Implication, ""d, left, right);
        }
        return left;
    }

    ASTNode* parseDisjunction() {
        ASTNode* left = parseConjunction();

        while (check(TokenType.DISJUNCTION)) {
            consume();
            ASTNode* right = parseConjunction();
            ASTNode* node  = new ASTNode(NodeType.Disjunction, ""d, left, right);
            left = node;
        }
        return left;
    }

    ASTNode* parseConjunction() {
        ASTNode* left = parseNegation();

        while (check(TokenType.CONJUNCTION)) {
            consume();
            ASTNode* right = parseNegation();
            ASTNode* node  = new ASTNode(NodeType.Conjunction, ""d, left, right);
            left = node;
        }
        return left;
    }

    ASTNode* parsePredicate(dstring name) {
        consume();
        ASTNode*[] args;

        while (!check(TokenType.RPAREN)) {
            Token t = consume();
            if (check(TokenType.LPAREN)) {
                args ~= parseFunction(t.literal);
            } else {
                args ~= parseVariable(t.literal);
            }
            if (check(TokenType.COMMA)) consume();
        }
        consume(); // RPAREN

        ASTNode* node = new ASTNode(NodeType.Predicate, name, null, null);
        node.args = args;
        return node;
    }

    ASTNode* parseFunction(dstring name) {
        consume();
        ASTNode*[] args;

        while (!check(TokenType.RPAREN)) {
            Token t = consume();
            if (check(TokenType.LPAREN)) {
                args ~= parseFunction(t.literal);
            } else {
                args ~= parseVariable(t.literal);
            }
            if (check(TokenType.COMMA)) consume();
        }
        consume();

        ASTNode* node = new ASTNode(NodeType.Function, name, null, null);
        node.args = args;
        return node;
    }

    ASTNode* parseVariable(dstring name) {
        return new ASTNode(NodeType.Variable, name, null, null);
    }

    ASTNode* parseNegation() {
        if (check(TokenType.NEGATION)) {
            consume();
            ASTNode* operand = parseNegation();
            return new ASTNode(NodeType.Negation, ""d, operand, null);
        }
        return parseQuantifier();
    }

    ASTNode* parseQuantifier() {
        if (check(TokenType.UNIVERSAL)) {
            Token t = consume();
            ASTNode* inner = parseNegation();
            return new ASTNode(NodeType.Universal, t.literal, inner, null);
        } else if (check(TokenType.EXISTENTIAL)) {
            Token t = consume();
            ASTNode* inner = parseNegation();
            return new ASTNode(NodeType.Existential, t.literal, inner, null);
        }
        return parsePrimary();
    }

    ASTNode* parsePrimary() {
        if (check(TokenType.LPAREN)) {
            consume();
            ASTNode* inner = parseBiconditional();
            consume();
            return inner;
        }

        Token t = consume();

        if (t.tt == TokenType.PREDICATE) {
            if (check(TokenType.LPAREN)) {
                return parsePredicate(t.literal); // has args: P(x,y)
            }
            throw new Exception("Unexpected predicate token without '(': " ~ cast(string)t.literal);
        }

        if (t.tt == TokenType.FUNCTION) {
            if (check(TokenType.LPAREN)) {
                return parseFunction(t.literal); // has args: f(x,y)
            }
            throw new Exception("Unexpected function token without '(': " ~ cast(string)t.literal);
        }

        if (t.tt == TokenType.VARIABLE) {
            return parseVariable(t.literal);
        }

        assert(false, "Unexpected token: " ~ cast(string)t.literal);
    }
}

unittest {
    // todo
}