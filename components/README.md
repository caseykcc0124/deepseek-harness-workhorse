# 按需下載元件

主 repo 保留一般原始碼、設定、測試和元件清單；大型執行材料放在 [GitHub Releases](https://github.com/caseykcc0124/deepseek-harness-workhorse/releases/tag/offline-win-x64-20261014)，不放進 Git 歷史。

## 有網路的準備電腦

clone repo 後，在 PowerShell 執行：

```powershell
# 查看元件與大小
.\components\Get-Component.ps1 -List

# 只下載一個外掛安裝包；不啟用
.\components\Get-Component.ps1 -Name dsh-what-changed -Destination C:\DSHOffline

# RTL 工作環境，會一併下載 core
.\components\Get-Component.ps1 -Name core,rtl,office-python -Destination C:\DSHOffline

# 瀏覽器自動化
.\components\Get-Component.ps1 -Name browser -Destination C:\DSHOffline

# Microsoft 365 的本機工具，不會登入或授權
.\components\Get-Component.ps1 -Name microsoft365 -Destination C:\DSHOffline

# 全部材料
.\components\Get-Component.ps1 -Name all -Destination C:\DSHOffline
```

若在命令列用 `powershell.exe -File` 呼叫，建議一次指定一個元件，或開啟 PowerShell 後使用以上陣列語法，避免舊版 shell 將逗號當成一般字串。

每個檔案都有固定版本、下載 URL、大小與 SHA-256。腳本驗證下載後，把元件展開到同一個資料夾；重新執行會重用已驗證的下載快取，不再次下載相同檔案。解開或覆蓋元件檔案不是啟用功能，腳本不會登入帳號。

## 元件

| id | 內容 |
|---|---|
| [core](https://github.com/caseykcc0124/deepseek-harness-workhorse/releases/download/offline-win-x64-20261014/core-win-x64-20261014.zip) | DSH 0.2.0-rc.2、繁中修補、Node.js 與離線 npm 相依 |
| [browser](https://github.com/caseykcc0124/deepseek-harness-workhorse/releases/download/offline-win-x64-20261014/browser-win-x64-20261014.zip) | Playwright MCP、Chromium、headless shell 與輔助執行檔 |
| [rtl](https://github.com/caseykcc0124/deepseek-harness-workhorse/releases/download/offline-win-x64-20261014/oss-cad-suite-windows-x64-20261013.tgz) | 官方 OSS CAD Suite Windows x64 2026-10-13 安裝包 |
| [office-python](https://github.com/caseykcc0124/deepseek-harness-workhorse/releases/download/offline-win-x64-20261014/office-python-win-x64-20261014.zip) | Python 3.11 安裝器、cocotb 與 Office/PDF wheels |
| [microsoft365](https://github.com/caseykcc0124/deepseek-harness-workhorse/releases/download/offline-win-x64-20261014/microsoft365-win-x64-20261014.zip) | PowerShell 7.6.7、Microsoft Graph 六組模組 |
| [github-tools](https://github.com/caseykcc0124/deepseek-harness-workhorse/releases/download/offline-win-x64-20261014/github-tools-win-x64-20261014.zip) | GitHub MCP、GitHub CLI、PortableGit |
| [dsh-web-search-free](https://github.com/caseykcc0124/deepseek-harness-workhorse/releases/download/offline-win-x64-20261014/dsh-web-search-free-1.8.0.tgz) | 網頁搜尋外掛 1.8.0 |
| [dsh-desktop-token-usage](https://github.com/caseykcc0124/deepseek-harness-workhorse/releases/download/offline-win-x64-20261014/dsh-desktop-token-usage-0.1.6.tgz) | Token 統計外掛 0.1.6 |
| [dsh-what-changed](https://github.com/caseykcc0124/deepseek-harness-workhorse/releases/download/offline-win-x64-20261014/dsh-what-changed-0.4.1.tgz) | 檔案變更外掛 0.4.1 |
| [dsh-todo-guard](https://github.com/caseykcc0124/deepseek-harness-workhorse/releases/download/offline-win-x64-20261014/dsh-todo-guard-0.1.0.tgz) | 待辦檢查外掛 0.1.0 |

外掛可單獨下載，前提是你已有相容的 Harness 環境。其餘工具元件預設帶入 core，便於取得共用的離線還原腳本。core 同時保留鎖定相依的可選平台安裝包以避免缺件，因此體積較大；這次已驗證的目標仍是 Windows x64。

## 離線目標電腦

完整複製準備好的 C:\DSHOffline 資料夾。執行其中的 Install-Offline.ps1；它只安裝目前資料夾內已有的元件。若選了 office-python，先確保已安裝 CPython 3.11 x64，再用 -PythonExe 指定。

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\DSHOffline\Install-Offline.ps1 -PythonExe C:\path\to\Python311\python.exe
C:\DSHOffline\Start-Offline.cmd
```

四個社群外掛保持未啟用，其相容性與 profile 安裝仍需逐一驗證。GitHub、Microsoft 365 與雲端模型呼叫仍需連線及授權。下載腳本應在有網路的準備電腦執行，不能在完全斷網的目標機上下載。
