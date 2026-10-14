# 外掛下載、安裝、啟用與移除

## 先分清楚三種東西

| 類型 | 例子 | 使用方式 |
|---|---|---|
| DSH bundle 外掛 | dsh-what-changed | 安裝到 web profile；依 bundle 設定載入 |
| MCP 服務 | GitHub MCP、Playwright MCP | 安裝服務程式後，再配置 MCP 連線 |
| 外部工具／SDK | Verilator、Yosys、Microsoft Graph | 安裝工具，提供 PATH、技能或受控呼叫介面 |

RTL 工具包和 Graph 模組不是丟進 DSH 外掛頁就能啟用的 bundle。安裝材料、功能配置、帳號授權和實際驗證是不同階段。

## 1. 選擇與下載 DSH 外掛

| 外掛 | 固定版本 | 用途 |
|---|---|---|
| dsh-web-search-free | 1.8.0 | 網頁搜尋與擷取 |
| dsh-desktop-token-usage | 0.1.6 | Token 用量看板 |
| dsh-what-changed | 0.4.1 | 檔案修改與差異檢視 |
| dsh-todo-guard | 0.1.0 | 待辦進度與完成證據檢查 |

在已 clone 的 repo 中：

```powershell
# 只下載；不安裝或啟用
powershell -NoProfile -ExecutionPolicy Bypass -File .\components\Get-Component.ps1 -Name dsh-what-changed -Destination C:\DSHOffline
```

安裝包會在 `C:\DSHOffline\plugins\dsh-what-changed-0.4.1.tgz`，不是下載工具的快取目錄。也可從 [元件清單](../components/README.md) 點選單一下載連結。

repo 的線上 Setup 下載包則放在 repo\downloads\；兩者不要混淆。

## 2. 線上安裝到正確環境

先停止要管理的 Harness 服務。以下指令在 repo 根目錄執行；Plugin.ps1 會使用專案的 Node、pnpm 與 web profile，不依賴系統全域 dsh 命令。

若目前 PowerShell 阻擋直接執行 .ps1，可使用單次程序的等價寫法，不必更改系統永久原則：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\plugins\Plugin.ps1 -Action List
```

其他例子的 Action、Package、OfflineRoot 等參數也可接在同樣的 -File 指令後。進階使用者可用 -ProfileHome 指定自訂 DSH_HOME；一般使用者保留預設即可。

```powershell
# 查看 repo 安裝環境的依賴
.\plugins\Plugin.ps1 -Action List

# 從 npm 安裝固定版本，需要網路
.\plugins\Plugin.ps1 -Action Add -Package dsh-what-changed@0.4.1

# 或使用 repo 的已下載包；相依套件仍可能需要網路
.\plugins\Plugin.ps1 -Action Add -Package (Resolve-Path .\downloads\dsh-what-changed-0.4.1.tgz).Path

.\Start.cmd
```

如果要管理 C:\DSHOffline 環境，必須指定 OfflineRoot。這個參數選擇安裝位置，**本身不表示禁止網路**：

```powershell
.\plugins\Plugin.ps1 -Action List -OfflineRoot C:\DSHOffline
.\plugins\Plugin.ps1 -Action Add -OfflineRoot C:\DSHOffline -Package C:\DSHOffline\plugins\dsh-what-changed-0.4.1.tgz
C:\DSHOffline\Start-Offline.cmd
```

DSH 安裝 bundle 預設會把它選入 profile；下次啟動時會嘗試載入。下載命令則不會。安裝後若暫時不用，從側邊欄「外掛」頁停用。不要把「設定 → 內建外掛」的唯讀清單當成第三方安裝頁。

## 3. 真正離線的外掛安裝

目前 Release 已提供外掛本體與核心的 npm tarballs，**沒有承諾已準備所有外掛的 pnpm store 或驗證四個 bundle 都能載入**。npm 的離線 tarballs 也不等於 pnpm 的 store。只有一個 tgz，不能保證其相依套件離線安裝成功。

建議在有網路的準備電腦先準備所選外掛的 profile 與 pnpm store，並實際測試。兩台電腦盡量維持同一路徑 C:\DSHOffline：

```powershell
# 準備電腦：這一步允許連網，安裝到準備搬移的環境
.\plugins\Plugin.ps1 -Action Add -OfflineRoot C:\DSHOffline -Package C:\DSHOffline\plugins\dsh-what-changed-0.4.1.tgz -StoreDirectory C:\DSHOffline\pnpm-store
.\plugins\Plugin.ps1 -Action List -OfflineRoot C:\DSHOffline
```

成功後，啟動該環境，檢查外掛是否載入且功能正常，再停止服務。將材料資料夾、pnpm-store 以及所選 web profile 一起搬移。profile 位於 `C:\DSHOffline\app\.dsh-home\profiles\web\`；需要其中的 manifest、lockfile 和設定，不只安裝包。不要公開上傳私人 `.dsh-home`；帳號和對話不是本 repo 的分發材料。

目標機先依 [主程式離線安裝](INSTALL.md) 還原 core，再用 repo 的 Plugin.ps1 還原 profile：

```powershell
# 目標電腦：禁止 pnpm 從套件索引補下載
.\plugins\Plugin.ps1 -Action Restore -OfflineRoot C:\DSHOffline -Offline -StoreDirectory C:\DSHOffline\pnpm-store
C:\DSHOffline\Start-Offline.cmd
```

若 pnpm 回報缺少離線 metadata、tarball 或套件，不要把失敗當成安裝完成；回準備電腦補齊相同 profile 的 store 後再搬移。第三方安裝腳本可能有自己的下載行為，仍需在受控網路環境驗證。此流程是操作指引，尚未對四個外掛逐項完成離線載入驗證。

## 4. 安裝後驗證

1. Plugin.ps1 的程序成功結束；記下外掛名稱、版本與使用的 DSH_HOME。
2. 重新啟動同一個環境，打開側邊欄「外掛」。確認 bundle 沒有載入錯誤。
3. 用小型任務驗證目標功能，例如修改一個測試檔，再查看差異。
4. 記錄結果與診斷；「已安裝」或「已選取」不等於 Host 和瀏覽器都已載入成功。

遇到版本不相容時，保留診斷並確認支援版本；本說明不建議自動使用 allow-version --accept-risk 跳過檢查。git-hosted 外掛的 prepare/build scripts 也需要獨立審查；目前清單以固定 npm 版本／tarball 為主。

## 5. 停用、移除與復原

只想暫時不用：在側邊欄外掛頁停用 bundle，保留其安裝依賴。修改影響使用同一 profile 的所有對話，必要時重啟。

要移除依賴，先停止服務：

```powershell
# repo 安裝環境
.\plugins\Plugin.ps1 -Action Remove -Package dsh-what-changed

# 離線材料環境
.\plugins\Plugin.ps1 -Action Remove -OfflineRoot C:\DSHOffline -Package dsh-what-changed
```

移除時用套件名稱，不用 @version 或 tgz 檔名。操作前可私下備份該 profile；不要把備份加進公開 Git。失敗時保留 `.plugin-manager/logs/` 診斷，檢查 profile manifest／lockfile 是否一致，不刪整個 .dsh-home 當作修復。

## 6. MCP、RTL 與 Microsoft 365

- GitHub／Playwright：下載對應元件並執行 Install-Offline；在材料根目錄執行 Generate-McpConfig.ps1。它產生本機路徑範例，不會自動套用；檢查後才加入 web profile 的 Cordis 設定。GitHub token 放本機環境或安全憑證儲存，不放 YAML 明文或 repo。
- RTL：安裝 rtl 元件，執行 `. .\Enter-Workhorse.ps1`，再用專案原有 lint／simulation／synthesis／formal 命令。cocotb 的 Python 套件在 office-python 元件內。
- Office／Microsoft 365：本機文件技能和 Graph SDK 是不同能力。Graph 模組載入後，Outlook／Teams／SharePoint 仍需公司租戶登入、權限與可達的服務；下載模組不會取得存取權。

官方機制參考：[DSH plugin manager](https://github.com/deepseek-ai/deepseek-harness/blob/master/packages/boot/plugin-manager/README.md)、[DSH MCP client](https://github.com/deepseek-ai/deepseek-harness/blob/master/packages/mcp/mcp-client/README.md)。
