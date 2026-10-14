# DeepSeek Harness Workhorse

將 DeepSeek Harness 配置為軟體開發、RTL 驗證與 OA 工作的工作馬。這是可重建的安裝與設定專案，不是 DeepSeek 官方分支；不把 node_modules、執行環境二進位檔、私人資料或壓縮包提交到 Git。

## 文件入口

| 你要做什麼 | 說明 |
|---|---|
| 第一次安裝、啟動、設定語言與模型 | [主程式安裝說明](docs/INSTALL.md) |
| 目的地不能下載套件 | [準備材料與離線搬移](docs/INSTALL.md#b-準備離線材料) |
| 挑選單一外掛或工具元件 | [按需下載清單與連結](components/README.md) |
| 安裝、驗證、停用或移除外掛 | [外掛下載及安裝說明](docs/PLUGINS.md) |
| 開發軟體、RTL、Office／Microsoft 365 要選什麼 | [能力與安裝順序](docs/capabilities.md) |
| 查已下載來源、雜湊和實測範圍 | [材料清單](offline/materials.lock.json)／[驗證紀錄](offline/verification.json) |

建議順序：**安裝 core → 啟動並設定模型 → 下載所需元件 → 安裝或配置 → 驗證功能**。下載成功、安裝成功、功能已啟用是不同狀態。若目標機不能下載，先在準備電腦取得材料，再搬移。

## 目前已提供

- 鎖定 DSH `0.2.0-rc.2`，透過 package-lock.json 保存 npm 相依版本。
- Windows 安裝與啟動腳本；現有 Node 太舊時，另下載 Node `22.23.3` 到本專案。
- 本機繁體中文（台灣）修補，含來源雜湊檢查、原始檔備份和測試。
- 4 個選用外掛的固定版本與完整性雜湊；Setup 會下載，不會安裝或啟用。
- 軟體／RTL／Microsoft 365 建議清單、MCP 範例及 RTL 工作技能。

Microsoft 365 帳號、GitHub MCP、Playwright、EDA 工具鏈與外掛尚未在此專案啟用。這些是下一階段整合項目，詳見 [能力與安裝順序](docs/capabilities.md)。

Windows x64 的離線材料已另行下載並測試；搬移方式見 [離線說明](offline/README.md)，來源與雜湊見 [材料鎖定清單](offline/materials.lock.json)，測試範圍見 [驗證紀錄](offline/verification.json)。大型安裝檔不在 Git 原始碼中；只 clone 此 repo 不會取得離線材料，需完整複製原機的 `DSH-offline-win-x64` 資料夾。

也可以使用 [按需下載工具](components/README.md)，從 GitHub Releases 只取得需要的元件；支援單一外掛、RTL、瀏覽器、Office、Microsoft 365，或一次取得全部。下載與啟用是分開的步驟。

## Windows 安裝

先安裝官方 Node.js（含 npm）與 Git，再執行：

```powershell
git clone https://github.com/caseykcc0124/deepseek-harness-workhorse.git
cd deepseek-harness-workhorse
powershell -NoProfile -ExecutionPolicy Bypass -File .\Setup.ps1
.\Start.cmd
```

Setup 從 npm 下載相依套件，需要網路，並會執行套件的安裝腳本。其他支援平台可在 Node >=22.19 環境執行 `npm ci`、`npm start`；Windows 腳本以外的平台尚未實際驗證。

資料放在專案內被 Git 忽略的 `.dsh-home/`，不會沿用另一個 DSH 安裝的帳號或對話。瀏覽器開啟後設定模型 API Key；必要時在設定中選擇「繁體中文（台灣）」。`Start.cmd --port 3081` 可使用另一個埠。

## 外掛

| 選用外掛 | 固定版本 | 功能 |
|---|---|---|
| dsh-web-search-free | 1.8.0 | 網頁搜尋與擷取 |
| dsh-desktop-token-usage | 0.1.6 | Token 用量統計 |
| dsh-what-changed | 0.4.1 | 檔案差異檢視 |
| dsh-todo-guard | 0.1.0 | 待辦進度與完成證據檢查 |

`npm run plugins:download` 會重新取得並驗證安裝包。只下載外掛本體，不是完整離線相依環境；各外掛的執行相容性尚待逐項測試。安裝後可能影響工作流程，建議逐一驗證再保留。

已完成線上 Setup 的 repo 環境，可從 repo 根目錄管理外掛：

```powershell
.\plugins\Plugin.ps1 -Action List
.\plugins\Plugin.ps1 -Action Add -Package dsh-what-changed@0.4.1
.\Start.cmd
```

Add 預設會把 bundle 選入 profile；需要暫停使用時在側邊欄「外掛」停用。管理離線材料環境必須指定 -OfflineRoot；離線安裝外掛還需對應 profile 與 pnpm store。完整步驟、驗證及移除指令見 [外掛說明](docs/PLUGINS.md)，不要直接把一個 tgz 視為完整離線安裝環境。

## 驗證與更新

`npm test` 檢查實際版本的繁中修補、JavaScript 語法、重複套用、文字參數保留，以及上游變更拒絕修補。備份位於 `.backups/client.original.js`。修補針對特定版本，不能假設新版 DSH 也相容。

本機原安裝及其設定不會因建立或下載此 repo 而改變。此 repo 不含模型權重、個人 API Key、對話、Outlook 郵件、Teams 訊息、SharePoint 檔案或公司 RTL。

上游：[deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness)。授權及轉換來源見 [NOTICE](NOTICE.md)。
