-- if true then return {} end

return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("codecompanion").setup({
      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            provider = {
              name = "ollama",
              param = {
                model = "gemma3", -- Use your pulled model name
                api_base = "http://localhost:11434", -- Ollama's default API address
              },
            },
            parameters = {
              sync = true,
            },
          })
        end,
      },
      display = {
        chat = {
          render_headers = false,
        },
      },
      strategies = {
        chat = { adapter = "ollama" },
        inline = { adapter = "ollama" },
        agent = { adapter = "ollama" },
      },
    })
  end,
}
