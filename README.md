# kakoune-clojure
A Kakoune plugin that improves the experience of working with Clojure code.

STATUS:
- This project should be considered pre-alpha and subject to change a lot.

[Kakoune (the best code editor via Linux-as-an-IDE)](http://kakoune.org/)  
[Clojure (the best language: a modern, practical lisp)](https://clojure.org/)

## Background / Goals
This is starting as a dumping ground for kakscript (and more) that I've accumulated for working with Clojure using Kakoune.

This will include custom commands and glue-code for other Kakoune plugins or external utilities that are useful for Clojure development.

The core of my Kakoune setup for working in Clojure involves:
- [kak-lsp](https://github.com/kak-lsp/kak-lsp) + [clojure-lsp](https://clojure-lsp.io/):
  Intelligent language editing features via LSP
- [kakoune-repl-mode](https://github.com/jordan-yee/kakoune-repl-mode):
  Better integration with a terminal REPL instance
- [parinfer-rust](https://github.com/eraserhd/parinfer-rust):
  Dynamic s-expression editing
- [rep](https://github.com/eraserhd/rep):
  A single-shot nREPL client designed for shell invocation

In particular, I needed a place to put REPL-based functionality that rides on `kakoune-repl-mode` or `rep`, both of which can be used to evaluate Clojure code at the REPL.
