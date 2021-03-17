---
layout: guide
doc_stub: false
search: true
section: Queries
title: Phases of Execution
desc: The steps GraphQL8 takes to run your query
index: 2
---

When GraphQL8 receives a query string, it goes through these steps:

- Tokenize: {{ "GraphQL8::Language::Lexer" | api_doc }} splits the string into a stream of tokens
- Parse: {{ "GraphQL8::Language::Parser" | api_doc }} builds an abstract syntax tree (AST) out of the stream of tokens
- Validate: {{ "GraphQL8::StaticValidation::Validator" | api_doc }} validates the incoming AST as a valid query for the schema
- Rewrite: {{ "GraphQL8::InternalRepresentation::Rewrite" | api_doc }} builds a tree of {{ "GraphQL8::InternalRepresentation::Node" | api_doc }}s which express the query in a simpler way than the AST
- Analyze: If there are any query analyzers, they are run with {{ "GraphQL8::Analysis.analyze_query" | api_doc }}
- Execute: The query is traversed, `resolve` functions are called and the response is built
- Respond: The response is returned as a Hash
