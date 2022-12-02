# Custom commands for working with Clojure code
#
# NOTE: Some commands depend on the `kakoune-repl-mode` plugin!

define-command -override clone-buffer \
-docstring 'Edit a copy of the current file in a new buffer (unsaved).' \
%{
    execute-keys '%\"fy'
    edit "copy"
    execute-keys '\"fR'
}

define-command -override clojure-select-current-ns \
-docstring "selects the current namespace name" %{
    # Handles:
    # - Comments before `(ns ...)` expression
    # - One or more metadata keywords preceding namespace name
    # - Multiple ns definitions in one file.
    # Doesn't handle:
    # - metadata containing spaces (hash-map metadata)
    # Other possibly unexpected behavior:
    # - This would select the last defined ns if the main selection is before
    #   the first defined namespace. An unlikely edge-case, only relevant
    #   for a file containing multiple ns definitions.
    execute-keys "/^\h*\(ns (\^[^\h]+ )*([^\h]+)$<ret>"
    execute-keys "s<c-r>2<ret>"
}

define-command -override clojure-save-current-ns \
-docstring "Saves the current namespace to the 'n' register." %{
    evaluate-commands -draft %{
        clojure-select-current-ns
        set-register n %reg{dot}
    }
    echo -debug "Saved ns to 'n' register: %reg{n}"
}

define-command -override clojure-echo-current-ns \
-docstring "Echos the current namespace." %{
    clojure-save-current-ns
    echo %reg{n}
}

define-command -override -hidden clojure-make-repl-command -params 1..2 \
-docstring "make-repl-command-expression <repl-command> [<arg>]:
Creates an expression to be evaluated at the REPL.

The expression will be in the following format:
`(<repl-command> [<arg>])`

If no explicit <arg> is given, the current selection used instead.

The resulting expression is saved to the <c> register." %{
    evaluate-commands %sh{
        repl_command_arg="$kak_reg_dot"
        if [ $# -eq 2 ]; then
            repl_command_arg="$2"
        fi
        printf "%s\n" "set-register c '($1 $repl_command_arg)'"
    }
    echo -debug "REPL command saved to <c> register: %reg{c}"
}

define-command -override -hidden clojure-make-namespace-repl-command -params 1 \
-docstring "make-repl-command-expression <repl-command>:
Creates an expression to be evaluated at the REPL.

The current namespace symbol (quoted) is given as the argument to the provided <repl-command>.

The expression will be in the following format:
`(<repl-command> '<current-namespace>)`

The resulting expression is saved to the <c> register." %{
    clojure-save-current-ns
    # TODO: Accept a switch that dictates whether to prefix the current
    # namespace with a quote. This could also be made the job of a wrapper macro
    # instead.
    clojure-make-repl-command %arg{1} "''%reg{n}"
}

# ------------------------------------------------------------------------------
# repl-mode integration

# --------------------------------------
# clojure-repl-command

define-command -override -hidden clojure-repl-command-prompt \
-docstring "INTERNAL: prompt branch for `clojure-repl-command`" %{
    prompt "REPL Command: " %{
        clojure-make-repl-command %val{text}
        repl-mode-eval-text %reg{c}
    }
}
define-command -override -hidden clojure-repl-command-arg -params 1 \
-docstring "INTERNAL: arg branch for `clojure-repl-command`" %{
    clojure-make-repl-command %arg{1}
    repl-mode-eval-text %reg{c}
}
define-command -override clojure-repl-command -params ..1 \
-docstring "clojure-repl-command [repl-command]:
Evaluate the current selection using the given [repl-command]

An expression of the following format will be sent to the REPL window for evaluation:
`([repl-command] <current-selection>)`

If no command is given, you will be prompted for one instead." %{
    evaluate-commands %sh{
        if [ $# -eq 0 ]; then
            printf "%s\n" "clojure-repl-command-prompt"
        else
            printf "%s\n" "clojure-repl-command-arg $1"
        fi
    }
}

# --------------------------------------
# clojure-namespace-repl-command

define-command -override -hidden clojure-namespace-repl-command-prompt \
-docstring "INTERNAL: prompt branch for `clojure-namespace-repl-command`" %{
    prompt "REPL Command: " %{
        clojure-make-namespace-repl-command %val{text}
        repl-mode-eval-text "%reg{c}"
    }
}
define-command -override -hidden clojure-namespace-repl-command-arg -params 1 \
-docstring "INTERNAL: arg branch for `clojure-namespace-repl-command`" %{
    clojure-make-namespace-repl-command %arg{1}
    repl-mode-eval-text "%reg{c}"
}
define-command -override clojure-namespace-repl-command -params ..1 \
-docstring "clojure-namespace-repl-command [repl-command]:
Evaluate the current namespace symbol using the given [repl-command]

An expression of the following format will be sent to the REPL window for evaluation:
`([repl-command] '<current-namespace>)`

If no command is given, you will be prompted for one instead." %{
    evaluate-commands %sh{
        if [ $# -eq 0 ]; then
            printf "%s\n" "clojure-namespace-repl-command-prompt"
        else
            printf "%s\n" "clojure-namespace-repl-command-arg $1"
        fi
    }
}
