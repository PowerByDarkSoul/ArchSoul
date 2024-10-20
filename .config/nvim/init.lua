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
opt.mouse = "a"
--status状态栏
opt.laststatus = 2
opt.statusline = "#%n %t %M"
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
opt.completeopt = { "menu", "noinsert", "noselect" }
opt.pumheight = 5
-- opt.pumwidth = 25 -- not work?
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
--移动整行
map.set("v", "J", ":m '>+1<CR>gv=gv")
map.set("v", "K", ":m '<-2<CR>gv=gv")
--使用黑洞寄存器 不复制删除的文字
map.set({ "v", "n" }, "d", "\"_d")
map.set({ "v", "n" }, "c", "\"_c")
--completion
map.set("i", "<A-Enter>", function()
    if vim.bo.omnifunc == '' then
        return "<C-x><C-n>"
    else
        return "<C-x><C-o>"
    end
end, { expr = true })
map.set("i", "<Tab>", function()
    return vim.fn.pumvisible() == 1 and "<Down>" or "<Tab>"
end, { expr = true })
map.set("i", "<S-Tab>", function()
    return vim.fn.pumvisible() == 1 and "<Up>" or "<S-Tab>"
end, { expr = true })
--terminal
map.set("n", "<C-`>", "<cmd>split term://bash | set nonumber | set norelativenumber | resize 10<CR>")
map.set("t", "<C-q>", "<C-\\><C-n>")

---------------
---- netrw ----
---------------
--禁用netrw
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
-- --设置是否显示横幅
-- g.netrw_banner = 0
-- --排序
-- g.netrw_sort_by = "name"
-- g.netrw_sort_direction = "normal"
-- --排序忽略大小写
-- g.netrw_sort_options = "i"
-- --设置目录列表的样式 0,1,2,3
-- g.netrw_liststyle = 3
-- --使用"rm -rf"执行D删除命令
-- g.netrw_localrmdir = "rm -rf"
-- --格式化时间戳
-- g.netrw_timefmt = "%Y-%m-%d %T"
-- --see :help g:netrw_preview
-- g.netrw_preview = 1
-- g.netrw_alto = 0
-- g.netrw_altv = 1
-- --按下回车水平分割文件
-- g.netrw_browse_split = 4
-- --netrw auto size
-- local netrwAutoSize = api.nvim_create_augroup("netrw_auto_size", { clear = true })
-- api.nvim_create_autocmd("BufWinEnter", {
--     desc = "&ft是文件类型, vertical resize的参数不是百分比",
--     group = netrwAutoSize,
--     command = "if &ft == 'netrw' | vertical resize 50 | else | vertical resize 145 | endif",
-- })
-- api.nvim_create_autocmd("FileType", {
--     group = netrwAutoSize,
--     pattern = "netrw",
--     command = "vertical resize 50 | set winfixwidth",
-- })

---------------
----- lsp -----
---------------
local lspGroup = api.nvim_create_augroup("lsp_group", { clear = true })
api.nvim_create_autocmd("LspAttach", {
    desc = "lsp attach",
    group = lspGroup,
    callback = function(args)
        -- 打印参数 使用nvim -V命令打印到日志文件
        -- print(string.format('event fired: %s', vim.inspect(args)))
        -- 打印文件类型
        -- print(vim.bo.filetype)
        local bufnr = args.buf
        local client_id = args.data.client_id
        local client = lsp.get_client_by_id(client_id)
        -- completefunc
        if client.server_capabilities.completionProvider then
            vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
        end
        if client.server_capabilities.definitionProvider then
            vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
        end
        -- autoformat on save
        -- async = false. This ensures that the formatting request will block until it completes, so that it completely finishes formatting before flushing the file to disk.
        api.nvim_create_autocmd("BufWritePre", {
            desc = "lsp autoformat on buffer save",
            group = lspGroup,
            buffer = bufnr,
            callback = function()
                lsp.buf.format({ async = false, id = client_id })
            end,
        })
        -- keymaps
        map.set({ "n", "v" }, "<C-A-l>", lsp.buf.format, { buffer = bufnr, desc = "Lsp Format" })
        map.set({ "i", "n" }, "<C-.>", lsp.buf.code_action, { buffer = bufnr, desc = "Code Action" })
        map.set("n", "gr", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename Symbol" })
        map.set("n", "gD", lsp.buf.declaration, { buffer = bufnr, desc = "Go to Declaration" })
        map.set("n", "gd", lsp.buf.definition, { buffer = bufnr, desc = "Go to Definition" })
        map.set("n", "gi", lsp.buf.implementation, { buffer = bufnr, desc = "Go to Implementation" })
        map.set("n", "gl", vim.diagnostic.open_float, { buffer = bufnr, desc = "Open Diagnostic Float" })
        -- behiver
        opt.formatoptions:remove({ "c", "r", "o" })
    end,
})
api.nvim_create_autocmd("FileType", {
    desc = "lua lsp",
    group = lspGroup,
    pattern = "lua",
    callback = function()
        local lsp_client_name = "lua-ls"
        local client = lsp.get_clients({ name = lsp_client_name })[1]
        local client_id
        if client == nil then
            client_id = lsp.start({
                name = lsp_client_name,
                cmd = { "lua-language-server" },
                settings = { Lua = { diagnostics = { globals = { "vim" } } } },
            })
        else
            client_id = client.id
        end
        lsp.buf_is_attached(0, client_id)
    end,
})
api.nvim_create_autocmd("FileType", {
    desc = "rust lsp",
    group = lspGroup,
    pattern = "rust",
    callback = function()
        local lsp_client_name = "rust-ls"
        local client = lsp.get_clients({ name = lsp_client_name })[1]
        local client_id
        if client == nil then
            client_id = lsp.start({
                name = lsp_client_name,
                cmd = { "rustup", "run", "stable", "rust-analyzer" },
                settings = {
                    ["rust-analyzer"] = {
                        -- search rust-analyer comfiguration
                    }
                }
            })
        else
            client_id = client.id
        end
        lsp.buf_is_attached(0, client_id)
    end,
})

----------------
-- treesitter --
----------------
local treeSitterGroup = api.nvim_create_augroup("tree-sitter-group", { clear = true })
api.nvim_create_autocmd("FileType", {
    desc = "tree-sitter",
    group = treeSitterGroup,
    pattern = { "lua" },
    callback = function()
        pcall(vim.treesitter.start)
        --折叠代码使用
        local winid = api.nvim_get_current_win()
        vim.wo[winid].foldlevel = 99
        vim.wo[winid].foldmethod = "expr"
        vim.wo[winid].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
})
