-- if true then return {} end

return {
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("minuet").setup({
        backend = "ollama", -- can also be "ollama" or "any-completion"
        model = "llama3", -- or "gpt-3.5-turbo"
        notify = debug,
        endpoint = "http://localhost:11434", -- for Ollama
        completion = {
          enabled = true, -- <-- this turns on as-you-type suggestions
          trigger_characters = { ".", ":", "(", "," }, -- optional
        },
        -- api_key = os.getenv("OPENAI_API_KEY"), -- or hardcode it
      })
      require("blink-cmp").setup({
        keymap = {
          -- Manually invoke minuet completion.
          ["<A-y>"] = require("minuet").make_blink_map(),
        },
        sources = {
          -- Enable minuet for autocomplete
          default = { "lsp", "path", "buffer", "snippets", "minuet" },
          -- For manual completion only, remove 'minuet' from default
          providers = {
            minuet = {
              name = "minuet",
              module = "minuet.blink",
              async = true,
              -- Should match minuet.config.request_timeout * 1000,
              -- since minuet.config.request_timeout is in seconds
              timeout_ms = 3000,
              score_offset = 50, -- Gives minuet higher priority among suggestions
            },
          },
        },
        -- Recommended to avoid unnecessary request
        completion = { trigger = { prefetch_on_insert = false } },
      })
    end,
  },
  { "nvim-lua/plenary.nvim" },
  -- optional, if you are using virtual-text frontend, nvim-cmp is not
  -- required.
  { "hrsh7th/nvim-cmp" },
  -- optional, if you are using virtual-text frontend, blink is not required.
  { "Saghen/blink.cmp" },
}
