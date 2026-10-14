# Windows x64 離線材料

這些腳本需放在已準備好的 `DSH-offline-win-x64` 資料夾根目錄，不能只 clone 本 repo 就宣稱擁有離線環境。大型安裝包與工具不提交到原始碼 Git。

## 搬移

完整複製 `DSH-offline-win-x64` 資料夾，不只複製 app 或外掛 tgz。建議放在短路徑，例如 `C:\DSHOffline`；工具鏈和部分第三方工具對深層 Windows 路徑比較敏感。保留所有 LICENSE、安裝包和 SHA256SUMS。

目標：Windows x64；Python 原生 wheels 鎖定 CPython 3.11 x64，其他 Python ABI 不相容。已附 Python 3.11.9 完整離線安裝程式，若目標電腦沒有 Python 3.11，先安裝它（包含 pip）。Git 另有 PortableGit 自解壓安裝包。

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-Offline.ps1 -PythonExe 'C:\path\to\Python311\python.exe'
.\Start-Offline.cmd
```

如果只使用已準備好的 app/node_modules，可以直接啟動；Python 的 venv 需要在目標電腦建立，不能依賴原機 venv 的絕對路徑。

## 已下載的能力

- Harness 0.2.0-rc.2、繁中修補、4 個未啟用外掛，及相依 npm tarballs。
- Node.js 22.23.3（含 npm）、pnpm；app 與 browser-tools 的 lockfile 已改成指向本機 tarballs。
- GitHub MCP 2.0.2、GitHub CLI 2.102.0、PortableGit 2.56.0.2。
- Playwright MCP 0.0.83 與鎖定相依、Chromium revision 1247、headless shell、FFmpeg、Winldd。MCP 使用產生的範例內明確指定 Chromium 路徑。
- OSS CAD Suite 2026-10-13 Windows x64，含 Verilator、Icarus Verilog、Yosys、SymbiYosys、求解器與相關工具。套件以每日發行內容為準。
- cocotb 2.1.0、Word/Excel/PowerPoint/PDF Python 程式庫及其遞迴相依 wheels。
- DSH 的 Windows 原生 LibreOffice Kit 0.1.5，供文件渲染；不是 Microsoft Office 桌面產品。
- PowerShell 7.6.7 及 Microsoft.Graph Authentication/Mail/Calendar/Files/Sites/Teams 2.41.1 模組。

`Install-Offline.ps1` 只讀本機安裝材料，npm 使用 `--offline`，pip 使用 `--no-index`。不執行線上版 Setup.ps1，也不要在離線環境執行 `npx ...@latest`。

## 工具環境與 MCP

在 PowerShell 執行 `. .\Enter-Workhorse.ps1` 載入 PATH、Graph 模組路徑和 RTL 資源路徑。Windows 原生 lint 使用 `verilator_bin.exe --lint-only ...`；已設定 VERILATOR_ROOT，避免指向原建置機的 /yosyshq 路徑。

`Generate-McpConfig.ps1` 依目標資料夾位置產生 MCP 範例。GitHub MCP 預設 read-only，token 從環境變數取得。這只產生範例，不自動啟用、不授權、不登入。

GitHub 與 Microsoft 365 的服務呼叫仍需網路；雲端模型 API 同樣需要可達的端點。離線材料解決的是安裝下載，不等於雲端服務可以離線運作。

Microsoft Graph 是 SDK/PowerShell 能力，不是假裝已接好的 Microsoft 365 MCP。租戶、權限和服務 API 需另外設定。此資料夾不含帳密、token、郵件、Teams 訊息或公司檔案，也不含 Microsoft Office/Teams 商用安裝檔、商用 EDA、PDK 或模型權重。

## 驗證範圍

已在原機測試 npm --offline 安裝與繁中測試、pip --no-index 安裝、Chromium 本機頁面操作、GitHub MCP 版本、Graph 模組載入、Office 文件產生與原生 Word→PDF 渲染。RTL 實測結果見 verification.json。

這些測試使用禁止套件索引抓取的安裝選項，沒有停用整台電腦網路，不等於做過完整網路封鎖測試。目標機的作業系統版本、公司限制、字型和硬體仍可能影響執行；文件渲染測試回報缺少 Courier，精確排版需目標機字型驗證。
