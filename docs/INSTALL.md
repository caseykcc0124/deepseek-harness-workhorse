# 主程式安裝與搬移

## 選擇流程

| 情境 | 操作 |
|---|---|
| 這台電腦可連 npm／GitHub | 線上安裝 |
| 目的地不能下載，但有一台準備電腦能下載 | 在準備電腦按需下載，搬移後離線安裝 |
| 只想增加一個外掛 | 先確認主程式可用，再看 [外掛說明](PLUGINS.md) |

本專案已驗證 Windows x64。主程式固定 DSH 0.2.0-rc.2；繁中修補也針對此版本。大型材料在 [Release](https://github.com/caseykcc0124/deepseek-harness-workhorse/releases/tag/offline-win-x64-20261014)，不在 git clone 的原始碼內。

## A. 線上安裝

先安裝官方 Node.js（含 npm）與 Git。開啟 PowerShell：

```powershell
git clone https://github.com/caseykcc0124/deepseek-harness-workhorse.git
cd deepseek-harness-workhorse
powershell -NoProfile -ExecutionPolicy Bypass -File .\Setup.ps1
.\Start.cmd
```

Setup 會安裝鎖定相依、套用繁中並執行測試，再下載 4 個外掛安裝包。外掛尚未安裝或啟用。若現有 Node 低於 22.19，腳本會另下載 22.23.3 到專案的 `.runtime/`。

安裝需要網路；不要在離線目標機使用這條流程。PowerShell 的 Bypass 只用於這一次腳本程序，指令不會修改系統永久執行原則。

## B. 準備離線材料

在有網路的 Windows x64 電腦 clone repo，進入 repo 目錄後執行：

```powershell
# 列出可選元件與大小
powershell -NoProfile -ExecutionPolicy Bypass -File .\components\Get-Component.ps1 -List

# 最小主程式
powershell -NoProfile -ExecutionPolicy Bypass -File .\components\Get-Component.ps1 -Name core -Destination C:\DSHOffline

# 全部材料；不自動啟用外掛或登入
powershell -NoProfile -ExecutionPolicy Bypass -File .\components\Get-Component.ps1 -Name all -Destination C:\DSHOffline
```

只下載需要的元件，可在 PowerShell 內使用陣列：

```powershell
# RTL 加 cocotb / Python
.\components\Get-Component.ps1 -Name rtl,office-python -Destination C:\DSHOffline

# 瀏覽器自動化
.\components\Get-Component.ps1 -Name browser -Destination C:\DSHOffline

# Outlook / Teams / SharePoint 的本機 Graph 工具
.\components\Get-Component.ps1 -Name microsoft365 -Destination C:\DSHOffline
```

工具元件會自動帶入 core；4 個 DSH 外掛可以單獨下載。下載工具會核對 SHA-256、重用快取，並把所選元件整理到同一個目的地。手動下載也可以，入口見 [元件清單](../components/README.md)，但要自行核對雜湊與核心相依。

建議準備電腦和目標電腦都使用短路徑 `C:\DSHOffline`。完整複製這個資料夾，不要只拿某個外掛 tgz；也保留一份 repo 原始碼，供閱讀文件和使用 plugins/Plugin.ps1。

## C. 離線目標機安裝

進入搬移好的 C:\DSHOffline：

```powershell
cd C:\DSHOffline

# 只有 core、browser、rtl、microsoft365 或 github-tools 時
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-Offline.ps1

.\Start-Offline.cmd
```

若有 office-python 元件，需 CPython 3.11 x64。沒有時，先執行 `installers\python-3.11.9-amd64.exe`，包含 pip；安裝器是完整離線版，不是網路 bootstrapper。再指定實際 Python 路徑：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-Offline.ps1 -PythonExe 'C:\path\to\Python311\python.exe'
.\Start-Offline.cmd
```

Install-Offline 會解開 Node、用 npm `--offline` 還原 app／已選的 browser-tools、解開已選工具；有 wheels 才建立 Python 環境並用 pip `--no-index` 安裝。它不會補下載缺少的材料。重新執行會重裝 npm 相依，並重建可拋棄的 python-env；不要把自己的檔案放在這些環境目錄。

## D. 啟動、語言與模型

預設服務位址是 `http://127.0.0.1:3080/`。啟動器通常會開啟帶存取令牌的入口；若直接開根網址被拒絕，使用啟動輸出提供的完整入口，不要關閉驗證。需要其他埠：

```powershell
# 線上 repo 安裝
.\Start.cmd --port 3081

# 離線材料安裝
.\Start-Offline.cmd --port 3081
```

在設定選「繁體中文（台灣）」，並設定模型供應商/API Key。本專案不附 API Key 或模型權重。雲端模型、GitHub 和 Microsoft 365 的服務呼叫仍需可達的網路；安裝可以離線，不代表雲端服務可以離線。

## 資料位置

| 安裝方式 | 設定與對話 |
|---|---|
| repo 的 Start.cmd | repo\.dsh-home\ |
| 離線 Start-Offline.cmd | C:\DSHOffline\app\.dsh-home\ |
| web profile 的外掛依賴與設定 | 對應 DSH_HOME\profiles\web\ |

原本全域安裝的 DSH 和這兩種環境可能使用不同的 home。管理外掛時要選對環境；不要在某個 home 安裝後，啟動另一個 home 再找外掛。`.dsh-home` 可能有帳密和私人資料，不可提交到公開 repo。

## 安裝後驗證與常見問題

- 瀏覽器能開啟、語言選單有繁中，才算主程式啟動成功。
- 找不到外掛：看 [外掛的安裝與驗證](PLUGINS.md)，下載成功不代表安裝成功。
- 離線缺件：回準備電腦補所需元件，再搬移；不要改執行 npx @latest。
- Python wheels 不相容：確認是 CPython 3.11 x64，並指定正確的 -PythonExe。
- Verilator 找不到 /yosyshq 資源：執行 `. .\Enter-Workhorse.ps1`，或透過 Start-Offline 啟動，確認 VERILATOR_ROOT 指向搬移後的 share/verilator。
- 公司帳號無法存取：這是租戶、授權或網路問題，不代表 Graph 模組沒下載。
- 精確 Office 排版：目標機字型仍要驗證；原機測試曾回報缺少 Courier。

實測範圍見 [verification.json](../offline/verification.json)。尚未做整台電腦斷網測試，也不把小型 RTL 測試當成正式專案 sign-off。
