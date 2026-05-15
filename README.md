# Dotfile Bootstrapper

一个轻量级 dotfiles 管理框架。它只负责把配置拆成可独立管理的 `item`，并通过统一入口执行安装、依赖检查、状态检查和卸载。

这个目录是框架本体，不包含任何具体个人配置。你可以从空的 `items/` 开始，为自己的配置逐个添加 item。

## 核心概念

- `bootstrap`：框架入口，负责解析命令、preset、目标 item 和执行模式。
- `item`：一个可独立部署的配置单元，位于 `items/<name>/`。
- `item.conf`：item 的生命周期脚本，定义依赖、安装、检查和卸载。
- `src/`：item 管理的真实配置文件，新增 item 时自行创建。
- `presets.conf`：可选批量安装组合。
- `bootstrap.conf`：本机配置，由首次运行自动生成，不纳入 git。

## 快速开始

初始化一个 item：

```bash
./bootstrap init --item=fish
```

然后把配置放进：

```text
items/fish/src/
```

编辑：

```text
items/fish/item.conf
```

安装：

```bash
./bootstrap install --item=fish -v
```

检查状态：

```bash
./bootstrap -ls
```

安装依赖并安装 item：

```bash
./bootstrap install --item=fish -c -D -v
```

## Preset

复制示例：

```bash
cp presets.conf.example presets.conf
```

编辑后使用：

```bash
./bootstrap install --preset=base -c -D -v
```

## Dry Run 注意事项

当前 `-n/--dry-run` 只会阻止通过 `run` 函数执行的命令。item 中直接写的 `mkdir`、`mv`、`cp`、`ln`、重定向等仍会执行。

新增 item 时，建议在 `install()` 中显式处理：

```bash
if [[ "${dry_run:-0}" == 1 ]]; then
  echo "Would link $target -> $src"
  return 0
fi
```

也可以参考 `templates/item.conf`。

