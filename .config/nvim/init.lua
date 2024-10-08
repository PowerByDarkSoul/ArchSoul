local opt = vim.opt
local g = vim.g
local map = vim.keymap
local api = vim.api
local lsp = vim.lsp

---------------
--- themes ----
---------------
--vim.cmd.colorscheme("codedark")
vim.cmd.colorscheme("darcula")
--禁用背景颜色
api.nvim_set_hl(0, "Normal", { ctermbg = "none" })

---------------
--- setting ---
---------------
--文件编码
opt.fileencodings = { "utf-8", "cp936" }
--不使用swap文件
opt.swapfile = false
--显示行号
opt.number = true
--显示相对于光标位于每行前面的行的行号
opt.relativenumber = true
--标志列
opt.signcolumn = "no"
--禁用搜索高亮
opt.hlsearch = false
--缩进
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
--禁用鼠标
opt.mouse = ""
--status状态栏
opt.laststatus = 1
opt.statusline = "%t %r"
--按键显示禁用
opt.showcmd = false
--脚标禁用
opt.ruler = false
--禁止换行
opt.wrap = false
--剪切板
opt.clipboard:append("unnamedplus")
--分割
opt.splitright = true
opt.splitbelow = true
--历史记录
opt.history = 100
--auto-complete
opt.completeopt = { "menuone", "preview", "noinsert", "noselect" }
opt.pumheight = 10
--fold
opt.foldlevelstart = 99

---------------
--- keymaps ---
---------------
--Normal Model = n
--Insert Model = i
--Visual Model = v
--help keycode

--切换窗口
map.set("n", "<C-j>", "<C-w>j")
map.set("n", "<C-k>", "<C-w>k")
map.set("n", "<C-h>", "<C-w>h")
map.set("n", "<C-l>", "<C-w>l")
--折叠选中代码
map.set("v", "<C-S-_>", ":fold<CR>")
--移动整行
map.set("v", "J", ":m '>+1<CR>gv=gv")
map.set("v", "K", ":m '<-2<CR>gv=gv")
--自动补全
--map.set("i", "[", "[]<Left>")
--map.set("i", "{", "{}<Left>")
--map.set("i", "(", "()<Left>")
--map.set("i", "<", "<><Left>")
--map.set("i", "\"", "\"\"<Left>")
--复制粘帖
map.set("v", "<C-c>", "y<Esc>")
map.set("i", "<C-v>", "<Esc>pi<Right>")
--使用黑洞寄存器 不复制删除的文字
map.set({ "v", "n" }, "d", "\"_d")
map.set({ "v", "n" }, "c", "\"_c")
--help文档跳转到光标指向的标记
map.set("n", "hn", ":h <C-r><C-w><CR>")

---------------
---- netrw ----
---------------
--禁用netrw
--g.loaded_netrw = 1
--g.loaded_netrwPlugin = 1
--设置是否显示横幅
g.netrw_banner = 0
--排序
g.netrw_sort_by = "name"
g.netrw_sort_direction = "normal"
--排序忽略大小写
g.netrw_sort_options = "i"
--设置目录列表的样式 0,1,2,3
g.netrw_liststyle = 3
--使用"rm -rf"执行D删除命令
g.netrw_localrmdir = "rm -rf"
--格式化时间戳
g.netrw_timefmt = "%Y-%m-%d %T"
--see :help g:netrw_preview
g.netrw_preview = 1
g.netrw_alto = 0
g.netrw_altv = 1
--按下回车水平分割文件
g.netrw_browse_split = 4
--netrw auto size
local netrwAutoSize = api.nvim_create_augroup("netrw_auto_size", { clear = true })
api.nvim_create_autocmd("BufWinEnter", {
    desc = "&ft是文件类型, vertical resize的参数不是百分比, 在2k分辨率下100%是200, 留下5的空缺疑似是sidebar",
    group = netrwAutoSize,
    command = "if &ft == 'netrw' | vertical resize 50 | else | vertical resize 145 | endif",
})
api.nvim_create_autocmd("FileType", {
    group = netrwAutoSize,
    pattern = "netrw",
    command = "vertical resize 50 | set winfixwidth",
})

---------------
----- lsp -----
---------------
local lspGroup = api.nvim_create_augroup("lsp_group", { clear = true })
api.nvim_create_autocmd("LspAttach", {
    desc = "lsp attach",
    group = lspGroup,
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client.server_capabilities.completionProvider then
            vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
        end
        if client.server_capabilities.definitionProvider then
            vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
        end
        map.set({ "n", "v" }, "<C-A-l>", lsp.buf.format)
        map.set("i", "<C-A-l>", function()
            api.nvim_input("<Esc>")
            lsp.buf.format()
        end)
    end,
})
api.nvim_create_autocmd("FileType", {
    desc = "lua lsp",
    group = lspGroup,
    pattern = "lua",
    callback = function()
        local client = lsp.get_clients({ name = "lua-ls" })[1]
        local client_id
        if client == nil then
            client_id = lsp.start({
                name = "lua-ls",
                cmd = { "lua-language-server" },
                settings = { Lua = { diagnostics = { globals = { 'vim' } } } },
            })
        else
            client_id = client.id
        end
        lsp.buf_is_attached(0, client_id)
        -- 禁用注释行换行自动注释
        opt.formatoptions:remove({ "c", "r", "o" })
    end,
})

----------------
-- treesitter --
----------------
local treeSitterGroup = api.nvim_create_augroup("tree-sitter-group", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    desc = "lua tree-sitter",
    group = treeSitterGroup,
    pattern = "lua",
    callback = function()
        -- vim.treesitter.start(args.buf)
        --折叠代码使用
        local winid = api.nvim_get_current_win()
        vim.wo[winid].foldlevel = 99
        vim.wo[winid].foldmethod = "expr"
        vim.wo[winid].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
})
