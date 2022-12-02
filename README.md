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

## Usage
- Clone this repo to your machine and copy the contents of the `/rc` directory into a `/custom` directory alongside your kakrc file. By default this would be: `~/.config/kak/custom`
- Source the rc scripts in your kakrc file:
  ```kakscript
  source "%val{config}/custom/clojure.kak"
  source "%val{config}/custom/rep.kak"
  ```
- With `clojure.kak` sourced, you can update `kakoune-repl-mode` configuration with some new commands/mappings. Example config using `plug.kak`:
  ```kakscript
  plug "jordan-yee/kakoune-repl-mode" config %{
    require-module repl-mode
    map global user r ': enter-user-mode repl<ret>' -docstring "repl mode"

    declare-user-mode repl-commands
    map global repl-commands c ': clojure-repl-command<ret>' -docstring "Prompt for a REPL command to evaluate on the current selection"
    map global repl-commands l ': clojure-repl-command dlet<ret>' -docstring "dlet"

    declare-user-mode ns-repl-commands
    map global ns-repl-commands n ': clojure-namespace-repl-command<ret>' -docstring "Prompt for a REPL command to evaluate on the current namespace symbol"
    map global ns-repl-commands i ': clojure-namespace-repl-command in-ns<ret>' -docstring "in-ns"
    map global ns-repl-commands r ': clojure-namespace-repl-command remove-ns<ret>' -docstring "remove-ns"
    map global ns-repl-commands t ': clojure-namespace-repl-command clojure.test/run-tests<ret>' -docstring "run-tests"

    hook global WinSetOption filetype=clojure %{
      set-option window repl_mode_new_repl_command 'lein repl'

      map window repl c ': enter-user-mode repl-commands<ret>' -docstring "REPL Commands"
      map window repl n ': enter-user-mode ns-repl-commands<ret>' -docstring "Namespace REPL Commands"

      hook -once -always window WinSetOption filetype=.* %{
        unset-option window repl_mode_new_repl_command
        unmap window repl c
        unmap window repl n
      }
    }
  }
  ```
