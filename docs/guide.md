# 目录
1. [摘要](#摘要)
2. [常用](#常用)
    1. [用户指南](#用户指南)
    2. [启动](#启动)
        - [参考文献](#reference-1)
        - [初始化](#初始化)
    3. [标签](#标签)
        - [参考文献](#reference-2)
    4. [Language Server Protocol](#language-server-protocol)
        - [参考文献](#reference-3)
        - [快速开始](#快速开始)
3. [杂项](#杂项)

## 摘要

本文为Neovim配置的简要指南, 主要参考资料包括
1. [Neovim官方的用户文档](https://neovim.io/doc/user/).
2. [Lua官方的文档](https://www.lua.org/manual/5.4/)
3. 其他用户的配置
4. 插件文档

## 用户指南

### 使用 `lua`

- nvim 命令行中可以这样调用 `lua` 命令
```lua
:lua print("Hello!")
```
- 每个 `:lua` 命令都有自己的作用域:
```lua
:lua local foo = 1
:lua print(foo)
" prints "nil" instead of "1"
```
- 使用`:lua =...`, 这等价于 `:lua vim.print(...)`

- 作为外部文件使用 `lua` 脚本, 可以使用 `:source` 命令, 正如调用 `Vimscript` 文件

```lua
:source ~/programs/baz/myluafile.lua
```

## 常用

### 启动

<h4 id="reference-1">参考文献</h4>

- [官方 开始](https://neovim.io/doc/user/starting.html#startup)

#### 初始化

在启动阶段, Neovim 会检查环境变量, 文件以及设置对应值, 执行过程如下:

1. 设置 `shell` 选项, 见 [shell](https://neovim.io/doc/user/options.html#'shell')

2. 处理传入参数, 即审查启动 vim 时传入的参数及文件名
    - `-V` 选项用于显示或记录接下来将发生什么, 常常用于初始化阶段的调试
    - `--cmd` 在此阶段执行

3. 启动一个服务(server), 除非参数`--listen` 给定.
    并且设定 `v:servername`, 见 [v:servername](https://neovim.io/doc/user/vvars.html#v%3Aservername).

4. 如果启动项中选用了 `embed`, 则等待UI连接.

5. 设置默认键位绑定`default-mappings`和默认自动命令`default-autocmds`以及创建弹出菜单`popup-menu`(一个菜单, 其在鼠标右键时显示), 见[default-mappings](https://neovim.io/doc/user/vim_diff.html#default-mappings), [default-autocmds](https://neovim.io/doc/user/vim_diff.html#default-autocmds) 和 [popup-menu](https://neovim.io/doc/user/gui.html#popup-menu).

6. 启动 `filetype` 和 `indent` 插件, 等价于
```vim
:runtime! ftplugin.vim indent.vim
```

7. 加载用户配置文件, 配置文件位置为
```shell
	Unix			~/.config/nvim/init.vim		(or init.lua)
	Windows			~/AppData/Local/nvim/init.vim	(or init.lua)
	$XDG_CONFIG_HOME  	$XDG_CONFIG_HOME/nvim/init.vim	(or init.lua)
```

8. 启动判断文件类型的脚本, 等价于
```vim
:runtime! filetype.lua
```
此过程可以跳过, 例如使用命令 `:filetype off` 或者启动时使用参数 `-u NONE`.

9. 启动语法高亮脚本, 等价于
```vim
:runtime! syntax/syntax.vim
```
此过程可以跳过, 例如使用命令 `:syntax off` 或者启动时使用参数 `-u NONE`.

10. 加载插件脚本, 等价于
```vim
:runtime! plugin/**/*.{vim,lua}
```
- 这个过程中 Neoim 会搜索 `runtimepath`(一个由目录组成的字符串数组, 见[runtimepath](https://neovim.io/doc/user/options.html#'runtimepath')) 中所有目录中的子目录 `plugin` 和 所有以 `.vim` 或 `.lua` 的文件.
搜索顺序按字典序, 先执行 `*.vim` 后执行 `*.lua`
- `runtimepath` 中以 `after` 结尾的将会跳过, 因其将在 `packages` (插件, 位于目录`start`, 其中 `start` 应于字符串数组变量 `packpath` 每项所指目录中) 后加载, 见 [packages](https://neovim.io/doc/user/repeat.html#packages)
- 插件加载将不进行, 如果
    - 在启动时使用参数`--noplugin`
    - 在启动时使用参数`--clean`
    - 在启动时使用参数`- u NONE`

11. 设置 `shellpipe` 和 `shellredir` 选项

12. 如果使用启动参数 `-n`, 则将 `updatecount` 设置到 0.

13. 如果使用启动参数 `-b`, 设置二进选项.

14. 读取 `shada-file`, 见 [shada-file](https://neovim.io/doc/user/starting.html#shada-file)

15. 如果使用启动参数 `-q` 或者退出失败, 读取 `quickfix` 文件.

16. 打开所有窗口: 
    - 当使用启动参数 `-o` 时, 窗口将被打开(但未显示)
    - 当使用启动参数 `-p` 时, 标签页(tab page) 将被创建.

17. 执行启动命令: 启动参数通过 `-c` 或者 `+cmd` 给定

### 标签

<h4 id="reference-2">参考文献</h4>

- [官方 用户手册29](https://neovim.io/doc/user/usr_29.html#29.1)
- [官方 标签](https://neovim.io/doc/user/tagsrch.html#tags)

### Language Server Protocol

<h4 id="reference-3">参考文献</h4>

- [官方 LSP](https://neovim.io/doc/user/lsp.html#lsp)

#### 快速开始

Neovim 提供了一个 LSP 客户端, 但其服务端由第三方提供.
具体使用方法可以参考下面:

1. 通过包管理插件或者上流安装指引, 安装语言服务端.
    [参考](https://microsoft.github.io/language-server-protocol/implementors/servers/).

2. 当对应文件打开时, 使用命令(`lua`) `vim.lsp.start()` 开启或绑定一个lsp. 例如
```lua
-- Create an event handler for the FileType autocommand
vim.api.nvim_create_autocmd('FileType', {
  -- This handler will fire when the buffer's 'filetype' is "python"
  pattern = 'python',
  callback = function(args)
    vim.lsp.start({
      name = 'my-server-name',
      cmd = {'name-of-language-server-executable', '--option', 'arg1', 'arg2'},
      -- Set the "root directory" to the parent directory of the file in the
      -- current buffer (`args.buf`) that contains either a "setup.py" or a
      -- "pyproject.toml" file. Files that share a root directory will reuse
      -- the connection to the same LSP server.
      root_dir = vim.fs.root(args.buf, {'setup.py', 'pyproject.toml'}),
    })
  end,
})
```

3. 检查当前缓冲区是否绑定到此服务端.
```vim
:checkhealth lsp
```

4. 配置键位绑定以及自动命令, 见 [lsp配置](https://neovim.io/doc/user/lsp.html#lsp-config)

## 杂项

1. [文档](https://neovim.io/doc/user/lua-guide.html#lua-guide-modules) 中写到, 包含文件 `init.lua` 的目录会被 `require` 直接引用, 不需要写全文件名: 即如果目录 `lua/some_module` 中含有 `init.lua` 文件, 则命令 `require("some_module")` 等同于 `require("some_module/init")`
