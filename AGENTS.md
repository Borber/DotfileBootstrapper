# AGENTS.md

## 项目定位

这是一个通用 dotfiles bootstrapper 框架。它不包含具体配置，只提供从零管理配置文件的组织方式和执行入口。

框架的基本原则是：`bootstrap` 只做编排，具体配置由每个 `items/<item>/item.conf` 自己负责。

## 目录约定

```text
.
├── bootstrap
├── bootstrap.conf
├── presets.conf
├── presets.conf.example
├── templates/
│   └── item.conf
├── utils/
│   └── replace.awk
└── items/
    └── <item>/
        ├── item.conf
        └── src/
```

`bootstrap.conf` 是本机配置，不应提交。`presets.conf` 可以提交，也可以按机器维护。

## Item 接口

每个 `item.conf` 应定义：

```bash
function check_dep() { return 0; }
function install_dep() { :; }
function check() { return 1; }
function install() { :; }
function uninstall() { :; }
```

返回值约定：

- `check_dep()` 返回 `0` 表示依赖已满足，返回 `1` 表示依赖缺失。
- `check()` 返回 `0` 表示 item 已安装且状态正确，返回 `1` 表示未安装或状态不正确。
- `install()` 和 `uninstall()` 应尽量幂等，重复执行不应破坏用户数据。

## 新增 Item 流程

1. 运行 `./bootstrap init --item=<name>` 创建骨架。
2. 把配置文件放入 `items/<name>/src/`。
3. 根据 `templates/item.conf` 改写 `items/<name>/item.conf`。
4. 优先使用软链接；确实需要实体文件时再复制。
5. 覆盖已有普通文件或目录前先备份为 `.bak`。
6. 路径一律加引号，避免硬编码用户名。

## Dry Run 规则

`bootstrap -n` 不是全局事务模拟。它只影响 `run` 函数。

新增 item 时，如果 `install()` 内有 `mkdir`、`mv`、`cp`、`ln`、重定向等写操作，需要显式处理：

```bash
if [[ "${dry_run:-0}" == 1 ]]; then
  echo "Would install <item>"
  return 0
fi
```

## 验证

修改框架或 item 后至少运行：

```bash
bash -n bootstrap
find items -name item.conf -print -exec bash -n {} \;
```

对单个 item 先检查 dry-run 行为：

```bash
./bootstrap install --item=<name> -n -v
```

## 维护原则

不要把具体个人配置提交到框架目录。具体配置应只出现在使用该框架创建的新 dotfiles 仓库中。

不要把 item 专属逻辑写进 `bootstrap`。只有多个 item 都需要同一种通用能力时，才扩展框架。

需要处理机器差异时，优先使用 `sys_id`、模板变量文件或 item 内的小型 helper，不要复制整套框架。

