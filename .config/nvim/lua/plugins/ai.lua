-- if true then return {} end

return {
  {
    -- apt-get install sox libsox-fmt-mp3
    "robitx/gp.nvim",
    config = function()
      require("gp").setup({
        log_sensitive = false,
        log_file = vim.fn.stdpath("log"):gsub("/$", "") .. "/gp.nvim.log",
        state_dir = vim.fn.stdpath("data"):gsub("/$", "") .. "/gp/persisted",
        whisper = {
          disable = true,
        },
        image = { disable = true },
        providers = {
          openai = {
            disable = false,
            endpoint = "https://api.openai.com/v1/chat/completions",
            secret = os.getenv("OPENAI_API_KEY"),
          },
          ollama = {
            endpoint = "http://localhost:11434/v1/chat/completions",
          },
        },
        agents = {
          {
            name = "ChatGPT3-5",
            disable = false,
            provider = "openai",
            chat = true,
            command = true,
            model = { model = "gpt-3.5-turbo" },
            system_prompt = require("gp.defaults").chat_system_prompt,
          },
        },
        cmd_prefix = "Gp",
        curl_params = {},

        -- directory for storing chat files
        chat_dir = vim.fn.stdpath("data"):gsub("/$", "") .. "/gp/chats",
        -- chat user prompt prefix
        chat_user_prefix = "💬:",
        -- chat assistant prompt prefix (static string or a table {static, template})
        -- first string has to be static, second string can contain template {{agent}}
        -- just a static string is legacy and the [{{agent}}] element is added automatically
        -- if you really want just a static string, make it a table with one element { "🤖:" }
        chat_assistant_prefix = { "🤖:", "[{{agent}}]" },
        -- The banner shown at the top of each chat file.
        chat_template = require("gp.defaults").chat_template,
        -- if you want more real estate in your chat files and don't need the helper text
        -- chat_template = require("gp.defaults").short_chat_template,
        -- chat topic generation prompt
        chat_topic_gen_prompt = "Summarize the topic of our conversation above"
          .. " in two or three words. Respond only with those words.",
        -- chat topic model (string with model name or table with model name and parameters)
        -- explicitly confirm deletion of a chat file
        chat_confirm_delete = true,
        -- conceal model parameters in chat
        chat_conceal_model_params = true,
        -- local shortcuts bound to the chat buffer
        -- (be careful to choose something which will work across specified modes)
        chat_shortcut_respond = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g><C-g>" },
        chat_shortcut_delete = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>d" },
        chat_shortcut_stop = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>s" },
        chat_shortcut_new = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>c" },
        -- default search term when using :GpChatFinder
        chat_finder_pattern = "topic ",
        chat_finder_mappings = {
          delete = { modes = { "n", "i", "v", "x" }, shortcut = "<C-d>" },
        },
        -- if true, finished ChatResponder won't move the cursor to the end of the buffer
        chat_free_cursor = false,
        -- use prompt buftype for chats (:h prompt-buffer)
        chat_prompt_buf_type = false,

        -- how to display GpChatToggle or GpContext
        ---@type "popup" | "split" | "vsplit" | "tabnew"
        toggle_target = "vsplit",

        -- styling for chatfinder
        ---@type "single" | "double" | "rounded" | "solid" | "shadow" | "none"
        style_chat_finder_border = "single",
        -- margins are number of characters or lines
        style_chat_finder_margin_bottom = 8,
        style_chat_finder_margin_left = 1,
        style_chat_finder_margin_right = 2,
        style_chat_finder_margin_top = 2,
        -- how wide should the preview be, number between 0.0 and 1.0
        style_chat_finder_preview_ratio = 0.5,

        -- styling for popup
        ---@type "single" | "double" | "rounded" | "solid" | "shadow" | "none"
        style_popup_border = "single",
        -- margins are number of characters or lines
        style_popup_margin_bottom = 8,
        style_popup_margin_left = 1,
        style_popup_margin_right = 2,
        style_popup_margin_top = 2,
        style_popup_max_width = 160,

        -- in case of visibility colisions with other plugins, you can increase/decrease zindex
        zindex = 49,

        -- command config and templates below are used by commands like GpRewrite, GpEnew, etc.
        -- command prompt prefix for asking user for input (supports {{agent}} template variable)
        command_prompt_prefix_template = "🤖 {{agent}} ~ ",
        -- auto select command response (easier chaining of commands)
        -- if false it also frees up the buffer cursor for further editing elsewhere
        command_auto_select_response = true,

        -- templates
        template_selection = "I have the following from {{filename}}:"
          .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}",
        template_rewrite = "I have the following from {{filename}}:"
          .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}"
          .. "\n\nRespond exclusively with the snippet that should replace the selection above.",
        template_append = "I have the following from {{filename}}:"
          .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}"
          .. "\n\nRespond exclusively with the snippet that should be appended after the selection above.",
        template_prepend = "I have the following from {{filename}}:"
          .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}"
          .. "\n\nRespond exclusively with the snippet that should be prepended before the selection above.",
        template_command = "{{command}}",
        -- example hook functions (see Extend functionality section in the README)
        hooks = {
          -- GpInspectPlugin provides a detailed inspection of the plugin state
          InspectPlugin = function(plugin, params)
            local bufnr = vim.api.nvim_create_buf(false, true)
            local copy = vim.deepcopy(plugin)
            local key = copy.config.openai_api_key or ""
            copy.config.openai_api_key = key:sub(1, 3) .. string.rep("*", #key - 6) .. key:sub(-3)
            local plugin_info = string.format("Plugin structure:\n%s", vim.inspect(copy))
            local params_info = string.format("Command params:\n%s", vim.inspect(params))
            local lines = vim.split(plugin_info .. "\n" .. params_info, "\n")
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
            vim.api.nvim_win_set_buf(0, bufnr)
          end,

          -- GpInspectLog for checking the log file
          InspectLog = function(plugin, params)
            local log_file = plugin.config.log_file
            local buffer = plugin.helpers.get_buffer(log_file)
            if not buffer then
              vim.cmd("e " .. log_file)
            else
              vim.cmd("buffer " .. buffer)
            end
          end,

          -- GpImplement rewrites the provided selection/range based on comments in it
          Implement = function(gp, params)
            local template = "Having following from {{filename}}:\n\n"
              .. "```{{filetype}}\n{{selection}}\n```\n\n"
              .. "Please rewrite this according to the contained instructions."
              .. "\n\nRespond exclusively with the snippet that should replace the selection above."

            local agent = gp.get_command_agent()
            gp.logger.info("Implementing selection with agent: " .. agent.name)

            gp.Prompt(
              params,
              gp.Target.rewrite,
              agent,
              template,
              nil, -- command will run directly without any prompting for user input
              nil -- no predefined instructions (e.g. speech-to-text from Whisper)
            )
          end,

          -- your own functions can go here, see README for more examples like
          -- :GpExplain, :GpUnitTests.., :GpTranslator etc.

          -- -- example of making :%GpChatNew a dedicated command which
          -- -- opens new chat with the entire current buffer as a context
          -- BufferChatNew = function(gp, _)
          -- 	-- call GpChatNew command in range mode on whole buffer
          -- 	vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatNew")
          -- end,

          -- -- example of adding command which opens new chat dedicated for translation
          -- Translator = function(gp, params)
          -- 	local chat_system_prompt = "You are a Translator, please translate between English and Chinese."
          -- 	gp.cmd.ChatNew(params, chat_system_prompt)
          --
          -- 	-- -- you can also create a chat with a specific fixed agent like this:
          -- 	-- local agent = gp.get_chat_agent("ChatGPT4o")
          -- 	-- gp.cmd.ChatNew(params, chat_system_prompt, agent)
          -- end,

          -- -- example of adding command which writes unit tests for the selected code
          -- UnitTests = function(gp, params)
          -- 	local template = "I have the following code from {{filename}}:\n\n"
          -- 		.. "```{{filetype}}\n{{selection}}\n```\n\n"
          -- 		.. "Please respond by writing table driven unit tests for the code above."
          -- 	local agent = gp.get_command_agent()
          -- 	gp.Prompt(params, gp.Target.enew, agent, template)
          -- end,

          -- -- example of adding command which explains the selected code
          -- Explain = function(gp, params)
          -- 	local template = "I have the following code from {{filename}}:\n\n"
          -- 		.. "```{{filetype}}\n{{selection}}\n```\n\n"
          -- 		.. "Please respond by explaining the code above."
          -- 	local agent = gp.get_chat_agent()
          -- 	gp.Prompt(params, gp.Target.popup, agent, template)
          -- end,
        },
      })
      require("which-key").add({
        -- VISUAL mode mappings
        -- s, x, v modes are handled the same way by which_key
        {
          mode = { "v" },
          nowait = true,
          remap = false,
          { "<C-g><C-t>", ":<C-u>'<,'>GpChatNew tabnew<cr>", desc = "ChatNew tabnew" },
          { "<C-g><C-v>", ":<C-u>'<,'>GpChatNew vsplit<cr>", desc = "ChatNew vsplit" },
          { "<C-g><C-x>", ":<C-u>'<,'>GpChatNew split<cr>", desc = "ChatNew split" },
          { "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", desc = "Visual Append (after)" },
          { "<C-g>b", ":<C-u>'<,'>GpPrepend<cr>", desc = "Visual Prepend (before)" },
          { "<C-g>c", ":<C-u>'<,'>GpChatNew<cr>", desc = "Visual Chat New" },
          { "<C-g>g", group = "generate into new .." },
          { "<C-g>ge", ":<C-u>'<,'>GpEnew<cr>", desc = "Visual GpEnew" },
          { "<C-g>gn", ":<C-u>'<,'>GpNew<cr>", desc = "Visual GpNew" },
          { "<C-g>gp", ":<C-u>'<,'>GpPopup<cr>", desc = "Visual Popup" },
          { "<C-g>gt", ":<C-u>'<,'>GpTabnew<cr>", desc = "Visual GpTabnew" },
          { "<C-g>gv", ":<C-u>'<,'>GpVnew<cr>", desc = "Visual GpVnew" },
          { "<C-g>i", ":<C-u>'<,'>GpImplement<cr>", desc = "Implement selection" },
          { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
          { "<C-g>p", ":<C-u>'<,'>GpChatPaste<cr>", desc = "Visual Chat Paste" },
          { "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", desc = "Visual Rewrite" },
          { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop" },
          { "<C-g>t", ":<C-u>'<,'>GpChatToggle<cr>", desc = "Visual Toggle Chat" },
          { "<C-g>w", group = "Whisper" },
          { "<C-g>wa", ":<C-u>'<,'>GpWhisperAppend<cr>", desc = "Whisper Append" },
          { "<C-g>wb", ":<C-u>'<,'>GpWhisperPrepend<cr>", desc = "Whisper Prepend" },
          { "<C-g>we", ":<C-u>'<,'>GpWhisperEnew<cr>", desc = "Whisper Enew" },
          { "<C-g>wn", ":<C-u>'<,'>GpWhisperNew<cr>", desc = "Whisper New" },
          { "<C-g>wp", ":<C-u>'<,'>GpWhisperPopup<cr>", desc = "Whisper Popup" },
          { "<C-g>wr", ":<C-u>'<,'>GpWhisperRewrite<cr>", desc = "Whisper Rewrite" },
          { "<C-g>wt", ":<C-u>'<,'>GpWhisperTabnew<cr>", desc = "Whisper Tabnew" },
          { "<C-g>wv", ":<C-u>'<,'>GpWhisperVnew<cr>", desc = "Whisper Vnew" },
          { "<C-g>ww", ":<C-u>'<,'>GpWhisper<cr>", desc = "Whisper" },
          { "<C-g>x", ":<C-u>'<,'>GpContext<cr>", desc = "Visual GpContext" },
        },

        -- NORMAL mode mappings
        {
          mode = { "n" },
          nowait = true,
          remap = false,
          { "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", desc = "New Chat tabnew" },
          { "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat vsplit" },
          { "<C-g><C-x>", "<cmd>GpChatNew split<cr>", desc = "New Chat split" },
          { "<C-g>a", "<cmd>GpAppend<cr>", desc = "Append (after)" },
          { "<C-g>b", "<cmd>GpPrepend<cr>", desc = "Prepend (before)" },
          { "<C-g>c", "<cmd>GpChatNew<cr>", desc = "New Chat" },
          { "<C-g>f", "<cmd>GpChatFinder<cr>", desc = "Chat Finder" },
          { "<C-g>g", group = "generate into new .." },
          { "<C-g>ge", "<cmd>GpEnew<cr>", desc = "GpEnew" },
          { "<C-g>gn", "<cmd>GpNew<cr>", desc = "GpNew" },
          { "<C-g>gp", "<cmd>GpPopup<cr>", desc = "Popup" },
          { "<C-g>gt", "<cmd>GpTabnew<cr>", desc = "GpTabnew" },
          { "<C-g>gv", "<cmd>GpVnew<cr>", desc = "GpVnew" },
          { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
          { "<C-g>r", "<cmd>GpRewrite<cr>", desc = "Inline Rewrite" },
          { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop" },
          { "<C-g>t", "<cmd>GpChatToggle<cr>", desc = "Toggle Chat" },
          { "<C-g>w", group = "Whisper" },
          { "<C-g>wa", "<cmd>GpWhisperAppend<cr>", desc = "Whisper Append (after)" },
          { "<C-g>wb", "<cmd>GpWhisperPrepend<cr>", desc = "Whisper Prepend (before)" },
          { "<C-g>we", "<cmd>GpWhisperEnew<cr>", desc = "Whisper Enew" },
          { "<C-g>wn", "<cmd>GpWhisperNew<cr>", desc = "Whisper New" },
          { "<C-g>wp", "<cmd>GpWhisperPopup<cr>", desc = "Whisper Popup" },
          { "<C-g>wr", "<cmd>GpWhisperRewrite<cr>", desc = "Whisper Inline Rewrite" },
          { "<C-g>wt", "<cmd>GpWhisperTabnew<cr>", desc = "Whisper Tabnew" },
          { "<C-g>wv", "<cmd>GpWhisperVnew<cr>", desc = "Whisper Vnew" },
          { "<C-g>ww", "<cmd>GpWhisper<cr>", desc = "Whisper" },
          { "<C-g>x", "<cmd>GpContext<cr>", desc = "Toggle GpContext" },
        },

        -- INSERT mode mappings
        {
          mode = { "i" },
          nowait = true,
          remap = false,
          { "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", desc = "New Chat tabnew" },
          { "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat vsplit" },
          { "<C-g><C-x>", "<cmd>GpChatNew split<cr>", desc = "New Chat split" },
          { "<C-g>a", "<cmd>GpAppend<cr>", desc = "Append (after)" },
          { "<C-g>b", "<cmd>GpPrepend<cr>", desc = "Prepend (before)" },
          { "<C-g>c", "<cmd>GpChatNew<cr>", desc = "New Chat" },
          { "<C-g>f", "<cmd>GpChatFinder<cr>", desc = "Chat Finder" },
          { "<C-g>g", group = "generate into new .." },
          { "<C-g>ge", "<cmd>GpEnew<cr>", desc = "GpEnew" },
          { "<C-g>gn", "<cmd>GpNew<cr>", desc = "GpNew" },
          { "<C-g>gp", "<cmd>GpPopup<cr>", desc = "Popup" },
          { "<C-g>gt", "<cmd>GpTabnew<cr>", desc = "GpTabnew" },
          { "<C-g>gv", "<cmd>GpVnew<cr>", desc = "GpVnew" },
          { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
          { "<C-g>r", "<cmd>GpRewrite<cr>", desc = "Inline Rewrite" },
          { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop" },
          { "<C-g>t", "<cmd>GpChatToggle<cr>", desc = "Toggle Chat" },
          { "<C-g>w", group = "Whisper" },
          { "<C-g>wa", "<cmd>GpWhisperAppend<cr>", desc = "Whisper Append (after)" },
          { "<C-g>wb", "<cmd>GpWhisperPrepend<cr>", desc = "Whisper Prepend (before)" },
          { "<C-g>we", "<cmd>GpWhisperEnew<cr>", desc = "Whisper Enew" },
          { "<C-g>wn", "<cmd>GpWhisperNew<cr>", desc = "Whisper New" },
          { "<C-g>wp", "<cmd>GpWhisperPopup<cr>", desc = "Whisper Popup" },
          { "<C-g>wr", "<cmd>GpWhisperRewrite<cr>", desc = "Whisper Inline Rewrite" },
          { "<C-g>wt", "<cmd>GpWhisperTabnew<cr>", desc = "Whisper Tabnew" },
          { "<C-g>wv", "<cmd>GpWhisperVnew<cr>", desc = "Whisper Vnew" },
          { "<C-g>ww", "<cmd>GpWhisper<cr>", desc = "Whisper" },
          { "<C-g>x", "<cmd>GpContext<cr>", desc = "Toggle GpContext" },
        },
      })
      -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
    end,
  },
}
