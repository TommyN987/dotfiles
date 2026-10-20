-- SurrealQL language server: `surreal install lsp`, run as `surreal lsp stdio`.
-- It builds its own copy of the grammar into the binary, so it doesn't depend
-- on the editor's surrealql tree-sitter parser.
return {
	cmd = { "surreal", "lsp", "stdio" },
	filetypes = { "surql" },
	-- The server reads every .surql file under the root, for schema across files.
	root_markers = { ".git" },
	settings = {
		surrealql = {
			-- Schema from the workspace's files only. "workspace+db" (the default)
			-- also needs a `connection`, which isn't set.
			metadata = { mode = "workspace" },
		},
	},
}
