# copyparty

<hr>

* Installation
```bash
bash <(curl -Ls https://raw.githubusercontent.com/co2f2e/copyparty/main/install.sh) 5800 username password
```
* Uninstallation
```bash
bash <(curl -Ls https://raw.githubusercontent.com/co2f2e/copyparty/main/uninstall.sh)
```

* rule
| 路径         | 匿名用户  | 管理员   |
| ---------- | ----- | ----- |
| `/`        | ✔ 可访问 | ✔ 可访问 |
| `/public`  | ✔ 下载  | ✔ 管理  |
| `/private` | ❌     | ✔ 全权  |
| `/inbox`   | ❌     | ✔ 只投  |
| `/sharex`  | ❌     | ✔ 全权  |

