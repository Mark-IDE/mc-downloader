# MC 下载器

一个**参考 PCL 启动器（Plain Craft Launcher）设计思路**的 Minecraft 版本下载器：
PC 端把 Java 版「从清单到资源、依赖、natives」整套文件下载并整理成启动器可直接识别的目录结构，
还能装模组加载器（Fabric / Quilt / Forge / NeoForge）、从 Modrinth 下 Mod、管理已装的 Mod；
安卓端负责基岩版 APK 与 Java 版运行环境（PojavLauncher / JRE）的下载。

![主界面](docs/ui-java.png)

---

## 功能一览

### PC · Java 版

| 能力 | 说明 |
| --- | --- |
| 全版本清单 | 直接读取 Mojang 官方 `version_manifest_v2.json`，正式版 / 快照 / 远古版 / 愚人节共 900+ 条 |
| 一键安装 | `client.jar`、依赖库、natives 解压、资源文件（assets）、日志配置一次下载到位 |
| 镜像加速 | 内置 Bang Bang（BMCLAPI）镜像，按域名规则映射；镜像失败自动回退官方源 |
| 断点续传 | 下载写入 `.part`，中断后重跑自动从断点继续，已完成的文件直接跳过 |
| SHA1 校验 | 每个文件按清单里的 sha1 校验，不一致自动重下 |
| 多线程 | 默认 16 线程（可调 1~64），大版本几秒到几十秒完成 |
| 兼容性 | 生成的目录可被 PCL / HMCL / 官方启动器直接识别（含 `launcher_profiles.json`） |
| 旧版本支持 | 处理 1.7 之前的 `virtual` / `map_to_resources` 资源索引，自动做资源虚拟化 |
| 架构适配 | 按本机架构过滤 natives（x64 机器不会装 arm64 动态库），避免动态库互相覆盖 |

### 模组 · 加载器 / Mod 市场 / Mod 管理

| 能力 | 说明 |
| --- | --- |
| 四种加载器 | Fabric、Quilt、Forge、NeoForge，版本列表自动拉取，可挑任意版本 |
| Fabric / Quilt | 纯文件安装：官方 meta 的 `profile.json` + 全部依赖库，装完即可用；缺原版会自动先装原版 |
| Forge / NeoForge | 自动下载官方安装器并调用（需要 Java 17+），装完直接生成 `versions/<mc>-forge-<版本>` |
| Mod 市场 | Modrinth 公开 API 搜索，按 MC 版本 + 加载器过滤，看下载量 / 作者 / 简介 |
| 一键装 Mod | 选文件版本直接下到 `mods`，可自动带上**必需的前置 Mod**（递归解析依赖） |
| Mod 管理 | 列出已装 Mod、一键启用/禁用（改名 `.jar` ↔ `.jar.disabled`）、删除、打开目录 |
| 版本隔离 | 自动识别 `versions/<版本>/mods`（版本隔离）与共享 `mods` 两种布局 |

![Mod 市场](docs/ui-mods-market.png)

### 安卓 · 基岩版

官方没有公开的 APK 直链，所以这里做成**可插拔下载源**，三种方式任选：

| 源 | 说明 |
| --- | --- |
| Internet Archive 存档 | 拉取 archive.org 上 `mcpe-apk` 存档的文件清单，覆盖 0.x 到最新版本；**需要能访问 archive.org** |
| 自定义 JSON 清单 | 自建 / 私有镜像，填一个 JSON 地址即可（格式见下） |
| 直接粘贴链接 | 手上有 APK 直链时直接下，带 sha1 时自动校验 |

![安卓基岩版](docs/ui-android.png)

### 安卓 · 启动器

从 GitHub Releases 获取 **PojavLauncher**（可在手机上运行 Java 版 Minecraft）与配套 JRE 运行时。

---

## 快速开始

### 方式一：双击启动

双击 `启动.bat`。脚本会依次尝试系统 `python` → `py -3` → DSH 自带运行时，找到带 tkinter 的 Python 3 后启动界面。

### 方式二：命令行

```bash
python main.py            # 打开图形界面
python main.py --version  # 版本号
```

> 环境要求：Windows + Python 3.9 及以上（自带 tkinter 即可），**不需要安装任何第三方库**。
> 装 Forge / NeoForge 时需要一个 Java 17+（程序会自动查找，也可在「设置」里指定 java.exe）。

### 三条典型流程

**① 装原版**

1. 左侧选 **PC · Java 版** → 选版本（可搜索、按类型筛选）
2. 右侧确认「安装目录」，勾选需要下载的内容（默认全选）
3. 点 **开始下载**，完成后把该目录交给 PCL / HMCL / 官方启动器

**② 装加载器 + Mod**

1. 左侧选 **模组 · Mod** → 「加载器安装」：选原版版本、加载器、加载器版本 → **安装加载器**
2. 切到「Mod 市场」：搜索 Mod → 选中条目 → 挑文件版本 → **下载到 mods 目录**
3. 需要前置的 Mod（如 Sodium 的依赖）会自动一起下；已装的 Mod 在「已装 Mod」页管理

**③ 安卓**

- 「安卓 · 基岩版」下 APK；「安卓 · 启动器」下 PojavLauncher + JRE

---

## 命令行

```bash
# 原版
python main.py list --type release --limit 20
python main.py install 1.20.1 --dir D:\Games\.minecraft

# 加载器
python main.py loader list    --mc 1.20.1 --type fabric
python main.py loader install --mc 1.20.1 --type fabric
python main.py loader install --mc 1.20.1 --type forge --java "C:\Java\jdk17\bin\java.exe"

# Mod（Modrinth）
python main.py mod search sodium --mc 1.20.1 --loader fabric
python main.py mod install sodium --mc 1.20.1 --loader fabric
python main.py mod install sodium --mc 1.20.1 --loader fabric --no-deps
python main.py mod list --dir D:\Games\.minecraft
python main.py mod toggle sodium-fabric-0.5.13+mc1.20.1.jar --dir D:\Games\.minecraft
python main.py mod toggle sodium-fabric-0.5.13+mc1.20.1.jar --delete

# 安卓
python main.py apk list
python main.py apk get --url https://example.com/Minecraft.apk --dir D:\APK
python main.py launcher list --repo pojav

# 自检
python main.py selftest
```

---

## 界面

| 加载器安装 | 已装 Mod |
| --- | --- |
| ![加载器](docs/ui-mods-loader.png) | ![Mod 管理](docs/ui-mods-manage.png) |

| 下载中 | 设置 |
| --- | --- |
| ![下载中](docs/ui-downloading.png) | ![设置](docs/ui-settings.png) |

底部状态栏显示总体进度与实时日志（可按「日志 ▾」收起），日志同时写入 `logs/mcdl-YYYYMMDD.log`。

---

## 自定义 APK 清单格式

```json
[
  {
    "version": "1.21.50",
    "channel": "release",
    "filename": "Minecraft-1.21.50-arm64-v8a.apk",
    "url": "https://your-mirror.example.com/Minecraft-1.21.50-arm64-v8a.apk",
    "size": 812345678,
    "sha1": "0123456789abcdef0123456789abcdef01234567"
  }
]
```

也支持包一层：`{"name": "我的源", "versions": [ ... ]}`。
`size` / `sha1` 可以省略（省略时不做长度与哈希校验），`channel` 可选 `release` / `beta` / `preview`。

---

## 目录结构

```
mc-downloader/
├─ main.py                  # 入口：默认开界面，带子命令走 CLI
├─ 启动.bat                  # Windows 启动脚本（自动找 Python）
├─ config.json              # 运行后生成：所有设置（便携，不写注册表）
├─ mc_downloader/
│  ├─ config.py             # 配置与路径
│  ├─ net.py                # 下载引擎：重试 / 续传 / SHA1 / 镜像回退 / TLS 降级
│  ├─ javadl.py             # Java 版：清单、规则求值、安装计划、natives、资源
│  ├─ modloaders.py         # 加载器：Fabric / Quilt / Forge / NeoForge 版本与安装
│  ├─ modrinth.py           # Modrinth：搜索 / 版本 / 下载 / 依赖解析
│  ├─ mods.py               # 本地 Mod 管理：列表、启用禁用、删除
│  ├─ bedrock.py            # 基岩版 APK 的三种下载源
│  ├─ pojav.py              # GitHub Releases（PojavLauncher / JRE）
│  ├─ cli.py                # 命令行实现
│  └─ ui/                   # tkinter 界面（主题、主窗口、各页面）
├─ tools/                   # 生成图标 / 生成截图 / 取消测试
├─ tests/test_core.py       # 离线单元测试（63 项）
└─ docs/                    # 截图
```

安装后的 .minecraft 结构：

```
<安装目录>/
├─ versions/<版本>/<版本>.json      # 版本清单（原样保存，启动器可直接读）
├─ versions/<版本>/<版本>.jar       # client.jar
├─ versions/<版本>/natives/         # 解压后的动态库
├─ versions/fabric-loader-<ver>-<mc>/   # Fabric / Quilt 装出来的版本
├─ versions/<mc>-forge-<ver>/           # Forge / NeoForge 装出来的版本
├─ libraries/                       # 依赖库（maven 目录结构）
├─ assets/indexes/<id>.json         # 资源索引
├─ assets/objects/<ab>/<hash>       # 资源对象（哈希命名）
├─ assets/log_configs/              # 日志配置
├─ mods/*.jar                       # 共享 Mod 目录（或 versions/<版本>/mods 做隔离）
├─ resources/                       # 1.7 之前的旧版资源（虚拟化）
└─ launcher_profiles.json
```

---

## 实现要点

1. **版本清单与镜像**：`javadl.make_sources()` 按设置返回有序源列表（镜像 → 官方），
   `download()` 接收**候选 URL 列表**，一个源失败自动换下一个，所以「自动」模式既有镜像速度又有官方兜底。
2. **规则求值**：严格按 Mojang 的 `rules`（`os.name` / `os.arch` / `features`）计算，默认不允许、按顺序覆盖。
3. **架构过滤**：新版 JSON 里 natives 只按系统区分（`natives-windows` 与 `natives-windows-arm64` 同时命中 Windows），
   因此额外按本机架构过滤，否则 arm64 的 DLL 会覆盖 x64 的。
4. **去重**：旧版资源索引里多个文件名指向同一 hash，安装计划按目标路径去重，避免多线程抢同一个文件。
5. **续传与校验**：先写 `.part`，校验 sha1 通过后再改名；再次运行会先核对大小 / 哈希，命中即跳过。
6. **加载器（Fabric / Quilt）**：取官方 meta 的 `profile/json`（带 `inheritsFrom` 与 `libraries`），
   落盘成 `versions/<id>/<id>.json` 再把 maven 依赖全部下载；原版缺失时先用同一套安装器补原版。
7. **加载器（Forge / NeoForge）**：下载官方安装器（镜像优先），自动找 Java 后以
   `java -jar installer.jar --installClient <dir>` 执行，实时把安装器输出转进日志；装完自动定位生成的版本目录。
8. **NeoForge 版本**：从 maven 的 `maven-metadata.xml` 解析，再按 MC 版本前缀（1.21.1 → `21.1.`）过滤；
   1.20.1 时代走 `net.neoforged:forge` 的老坐标。
9. **Mod 依赖**：Modrinth 版本对象里 `dependency_type == required` 的项递归解析（项目 → 匹配当前 MC/加载器的最新文件），
   带 `seen` 去重和深度上限，避免死循环。
10. **进度聚合**：多线程共享一个 `Progress`，按字节 + 文件数 + 滑动窗口速度计算百分比与剩余时间。

---

## 测试

```bash
python tests/test_core.py     # 63 项离线单元测试：规则、架构过滤、镜像映射、去重、APK 源、加载器、Mod 管理
python main.py selftest       # 联网自检：官方源 / 镜像 / GitHub / Modrinth / Fabric / Forge / Java
```

---

## 常见问题

**Q：为什么日志里提示「证书校验失败，已对该站点降级」？**
BMCLAPI 部分节点证书链不完整，Python 校验会失败（浏览器会自己补链）。程序会自动对**该站点**降级重试，只影响这一次连接；
不想降级可在「设置」里关掉「证书异常时允许降级」。

**Q：Forge / NeoForge 装不上，提示没找到 Java？**
这两个加载器的官方安装器是 Java 程序。装一个 Java 17+（1.16 及更早用 Java 8），
程序会自动扫 `JAVA_HOME`、PATH 和常见安装目录，也可以在「设置 → Java 路径」或模组页「指定 java.exe…」手动指定。

**Q：NeoForge 安装器卡在下载？**
NeoForge 安装器会去 `maven.neoforged.net` 拉库，部分地区访问很慢。安装器本身我们走镜像下载，
但安装器内部的下载地址没法替换；网络不通时可以先挂代理，或用 PCL / HMCL 装好 NeoForge 再用本程序装 Mod。

**Q：有没有 CurseForge？**
CurseForge 的 API 必须申请 key，所以当前内置的是 **Modrinth**（开放 API、无需 key）。
大部分主流 Mod 在两个平台都有；需要 CurseForge 可以后续加一个填 key 的适配器。

**Q：安卓基岩版列表一直转圈 / 报错？**
默认的 archive.org 源在部分网络（尤其国内）不可访问。请改用「自定义 JSON 清单」或「直接链接」，
也可以点「在 Google Play 查看」走官方渠道。

**Q：下载中断了怎么办？**
重新点开始即可，已完成的文件会按大小 / sha1 跳过，只补缺失部分。

**Q：下载完怎么启动游戏？**
本程序只负责下载与整理文件，**不包含启动器**。把安装目录交给 PCL / HMCL / 官方启动器（它们会自动识别 `versions/`），
或者用「安卓 · 启动器」页把 PojavLauncher 装到手机上再导入游戏文件。

---

## 免责声明

- 本工具只负责下载与整理文件，不提供任何破解、账号或联网绕过功能。
- Minecraft 是 Mojang Studios / Microsoft 的商标与版权作品，请通过官方渠道购买正版。
- Mod 来自 Modrinth 上作者公开发布的版本，请遵守各 Mod 的许可协议；安卓 APK 来自第三方存档 / 自建清单，请自行确认来源可信。
- 本项目仅供学习交流。

## 参考与致谢

- **PCL / PCL2**（龙腾猫跃）—— 界面布局、下载流程与「镜像优先」策略的灵感来源
- **BMCLAPI**（bangbang93）—— 国内镜像加速（版本清单、maven、Forge / NeoForge 安装器）
- **Modrinth** —— 开放的 Mod 平台 API
- **Fabric / Quilt / Forge / NeoForge** 团队 —— 加载器与官方安装器
- **PojavLauncher** 团队 —— 安卓端 Java 版运行环境
