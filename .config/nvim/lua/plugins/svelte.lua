require("lspconfig").svelte.setup({
  settings = {
    svelte = {
      plugin = {
        svelte = {
          compilerWarnings = {
            ["a11y-label-has-associated-control"] = "ignore",
            ["a11y-click-events-have-key-events"] = "ignore",
            ["a11y-no-noninteractive-element-interactions"] = "ignore",
            ["a11y-no-static-element-interactions"] = "ignore",
          },
        },
      },
    },
    css = {
      lint = {
        unknownAtRules = "ignore",
      },
    },
  },
})

return {

  -- {
  --   "neovim/nvim-lspconfig",
  --   config = function()
  --     require("lspconfig").svelte.setup({
  --       cmd = { "svelteserver", "--stdio" },
  --       filetypes = { "svelte" },
  --       settings = {
  --         svelte = {
  --           plugin = {
  --             svelte = {
  --               compilerWarnings = {
  --                 ["a11y-*"] = "ignore",
  --               },
  --             },
  --           },
  --         },
  --       },
  --     })
  --   end,
  -- },
}
