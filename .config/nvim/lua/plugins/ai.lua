--if true then return {} end
--
return {
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp", -- Completion framework (highly recommended)
    },
    config = function()
      require("minuet").setup({
        model = "gemma3", -- Or the Gemma model you downloaded with Ollama
        api_key = "TERM",
        --        api_base = "http://localhost:11434", -- Default Ollama API address
        end_point = "http://localhost:11434/v1/completions",
        --  Optional settings:
        prompt_prefix = "User: ",
        prompt_suffix = "Assistant:",
        max_tokens = 512, -- Adjust as needed
        temperature = 0.7, -- Adjust for creativity
        top_p = 0.9,
      })
    end,
  },
}
