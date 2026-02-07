local npairs = require("nvim-autopairs")

local Rule = require("nvim-autopairs.rule")

npairs.setup({
	event = "InsertEnter",
	check_ts = true,
	ts_config = {
		lua = { "string" }, -- it will not add a pair on that treesitter node
		javascript = { "template_string" },
		java = false, -- don't check treesitter on java
	},

	-- NOTE: not working yet - check keyboard shortcut
	fast_wrap = {
		map = "<C-b>",
		chars = { "{", "[", "(", '"', "'" },
		pattern = [=[[%'%"%>%]%)%}%,]]=],
		end_key = "$",
		before_key = "h",
		after_key = "l",
		cursor_pos_before = true,
		keys = "qwertyuiopzxcvbnmasdfghjkl",
		manual_position = true,
		highlight = "Search",
		highlight_grey = "Comment",
	},
})

local ts_conds = require("nvim-autopairs.ts-conds")

-- press % => %% only while inside a comment or string
npairs.add_rules({
	Rule("%", "%", "lua"):with_pair(ts_conds.is_ts_node({ "string", "comment" })),
	Rule("$", "$", "lua"):with_pair(ts_conds.is_not_ts_node({ "function" })),
})

-- When typing ```, add closing ``` on a new line (like Python docstrings)
-- Also suppress the default single backtick pairing for the 3rd backtick

npairs.get_rule("`"):with_pair(function(opts)
	return opts.line:sub(1, opts.col):match("``$") == nil
end)

npairs.add_rules({
	Rule("```", "```", { "-vim" })
		:with_pair(function(opts)
			return opts.line:sub(1, opts.col):match("``$") ~= nil
		end)
		:set_end_pair_length(0)
		:replace_endpair(function()
			return "<CR>```<Up><End>"
		end, true),
})

-- To insert `(` after select function or method item
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require('cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)
