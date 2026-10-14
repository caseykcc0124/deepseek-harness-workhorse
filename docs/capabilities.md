# 工作馬能力與建議安裝順序

調查日期：2026-10-14。下列分清楚「已有套件」「建議接入」「待授權」，不把設定範本視為已完成整合。DSH 外掛、MCP server、Skill、外部工具是不同層，不能互相代替。

## 第一階段：軟體開發

1. 保留 DSH 的終端機、檔案操作、程式碼修改及技能能力。專案自身提供可重現的 build/test/lint 命令，讓 agent 以實際測試判斷完成。
2. 接入 [GitHub 官方 MCP](https://github.com/github/github-mcp-server)：讀取 repo、Issue、PR 與 CI 結果；也可先用 git / gh CLI。不要另裝已封存的舊 GitHub MCP npm server。
3. 接入 [Microsoft Playwright MCP](https://github.com/microsoft/playwright-mcp)：瀏覽器操作與網頁驗證；正式前端測試仍放在專案測試套件中，不以人工觀察取代測試。
4. 選用 dsh-what-changed、dsh-desktop-token-usage；待辦需要額外完成檢查時再加 dsh-todo-guard。網頁搜尋視模型本身和任務需要選用 dsh-web-search-free。

預設先採單一主 agent，加明確測試與提交邊界。需要獨立驗證或可拆工作時才用子代理，避免為了多代理而增加成本。

## 第二階段：RTL／SystemVerilog

優先讓 agent 操作成熟 CLI 與專案建置流程；MCP 是可選介面，並不是取得驗證能力的前提。

| 工具 | 用途 | 注意 |
|---|---|---|
| Verilator | lint、編譯式模擬 | 不等同所有商用模擬器的完整 SystemVerilog/UVM 行為 |
| cocotb | Python RTL testbench | 需相容模擬器及專案測試規格 |
| Yosys | 綜合、結構與資源分析 | 先確認 SystemVerilog 前端與專案語法支援 |
| SymbiYosys | assertion、bounded/unbounded formal flow | 必須記錄假設、深度、引擎和證明結果 |
| GTKWave 或其他波形檢視器 | VCD/FST 除錯 | 波形是除錯證據，不代表覆蓋完整 |

可由 [YosysHQ OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build) 評估整套工具鏈，再按目標平台和已用 EDA 環境選原生 Windows、WSL2 或 Linux runner。[cocotb](https://github.com/cocotb/cocotb) 依測試環境另行設定；[SymbiYosys](https://github.com/YosysHQ/sby) 的 formal 結果應和模擬分開報告。

建議流程：讀規格 → 補 testbench／assertion → lint → simulation → synthesis → 適用的 formal → 留存報告。CDC、RDC、STA、PPA 與 ASIC sign-off 依公司的工具和製程流程處理，不用一般模擬通過宣稱已完成 sign-off。

repo 內的 `skills/rtl-workhorse/` 是待放入 DSH 技能搜尋路徑的技能來源，尚未自動安裝。商用 Questa、VCS、Xcelium、Vivado、Quartus 或 ASIC 工具需既有授權；本 repo 不提供 license、PDK 或私有 RTL。

## 第三階段：Office 與 Microsoft 365

### 本機 Office 檔案

目前 DSH 套件已包含 `@deepseek-ai/dsh-skill-office`，提供 office-docx、office-pptx、office-xlsx 工作流程；也含 Office 預覽相關套件。先確認 profile 是否掛載、Python 程式庫和渲染環境是否可用，再做小型文件驗證，無須立即再裝一套同功能外掛。

參考：[官方 Office skill README](https://github.com/deepseek-ai/deepseek-harness/blob/master/packages/skill/skill-office/README.md)。儲存 `.docx/.xlsx/.pptx` 和操作正在執行的桌面 Office 是不同能力；有巨集、特殊外掛、精確排版或重算需求時，另評估 Office 本身的介面與授權環境。

### Outlook、Teams、SharePoint、OneDrive

優先評估租戶允許的 Microsoft 365 MCP 服務；如果不適用，透過 [Microsoft Graph](https://learn.microsoft.com/en-us/graph/overview) SDK／PowerShell／受控 MCP bridge 接入。Graph 涵蓋 Outlook、Calendar、Excel、OneDrive、SharePoint、Teams 等，但不是每一項 UI 功能都有相同 API，權限和帳號類型也不同。

可先處理讀取郵件摘要、會議準備、搜尋文件，再加入草稿、文件更新等功能。寄信、發 Teams 訊息、改分享權限、刪檔需要明確的工作授權；不因登入一次就假設 agent 可以任意對外操作。

租戶登入、Entra app registration、允許的 delegated scopes、管理員同意、資料政策和使用的雲端模型需和 IT 確認。權杖只留在本機安全儲存，不能進 repo。不要給一般 agent 租戶全域管理員權限。

目前沒有在本機登入上述帳號，也沒有配置 Microsoft 365 MCP endpoint。`config/mcp.example.yml` 只是 DSH 的 Cordis 格式範例；DSH 原生不是讀取其他產品的 `mcpServers` JSON。參考：[DSH MCP client](https://github.com/deepseek-ai/deepseek-harness/blob/master/packages/mcp/mcp-client/README.md)。

## 實際優先序

先完成 GitHub／測試能力和 Office 文件驗證；接著建立一個 RTL 小專案的 lint、simulation、formal 範例；最後在 IT 允許範圍接 Microsoft 365。評估指標應是任務成功率、測試與報告、可回復變更、時間和成本，而不是外掛數量。
