# github-apps

[English](README.md)

這是一個 bash 腳本，用於管理從 github 上安裝的各種開源應用

你可以爲某個 github 上發佈的開源應用創建一個配置腳本，之後就可以使用本腳本對它進行安裝更新與卸載。當你安裝了很多 github 上的開源項目時使用本腳本會讓安裝更新卸載之類的操作變得自動化且條理分明，此外本腳本可以生成自動完成的命令腳本給 bash_completion，所以你可以使用 tab 補齊各種命令參數。

* [爲什麼](#爲什麼)
    * [bash](#bash)
* [安裝](#安裝)
* [如何使用](#如何使用)
    * [命令自動完成](#completion)
    * [查詢應用](#list)
    * [安裝應用](#install)
    * [升級應用](#upgrade)
    * [刪除應用](#remove)
    * [下載緩存](#cache)
* [版本號](#版本號)
* [配置腳本](#配置腳本)
    * [全局變量](#全局變量)
    * [回調函數](#回調函數)
    * [其它源的應用](#其它源的應用)

# 爲什麼

github 上存在大量有用且有趣的開源項目，然而使用它們的一個問題是它們通常沒有發佈到操作系統的軟件包倉庫中，並且不同的系統平臺例如 linux mac windows 包管理器都不盡相同。即使同屬於 linux ，但是 redhat debian arch ... 都使用了不同的軟件包管理器，你很難要求沒有任何盈利來源的開源項目去爲這些平臺發佈對應的軟件包。

即使充滿了這麼多問題，但好用的開源項目依然令人垂涎，於是我決定寫個跨平臺的工具來管理這些應用的安裝更新與刪除。

## bash

關於爲何使用 bash 實現，首先本喵並不喜歡 bash 的語法，但要實現的功能不算太複雜 bash 剛好夠用，再加上 bash 相對其它語言的一些優勢所以選擇了 bash 實現。

本喵經過考慮後使用 bash 主要出於下面幾點：

1. 跨平臺，主流系統都能運行
2. 最主要的理由是大部分系統無需額外依賴就可以運行。js 或 python 會好寫代碼很多，但需要安裝額外的運行環境，本喵有多個不同的環境像是工作機(linux)，家庭電腦(linux)，筆記本(linux)，遊戲機(windows)，路由器(openwrt)，服務器(ubuntu)，還有一些 docker 和 virtualbox 虛擬機，我想在所有環境都使用這個管理工具，但並不想在它們之中都安裝類似 nodejs 或 python 之類的東西
3. 配置腳本需要使用腳本，使用 bash 可以讓配置腳本也使用 bash 這會讓配置腳本的書寫變得靈活與簡單

當然使用 bash 也產生了一些問題比如：

1. 效率並不高，但比人工操作好多了並且安裝和更新都是自動化的慢一小點問題並不大
2. github 的 api 返回的 json 數據，bash 沒有內置的 json 支持，本喵使用的字符串匹配解析數據，如果後續 github api 返回格式變化但可能性不大，或本喵解析的不太對腳本可能會無法工作

# 安裝

本腳本使用 curl 下載安裝包以及請求 github api，請參考 [curl](https://curl.se/download.html) 官網進行安裝。

```
curl -s  http://192.168.251.50/tools/dev/install.sh | bash -s
```
# 如何使用

所有的命令和子命令都可以傳入 `-h` 查看使用說明，本腳本支持如下幾個子命令：

* [completion](#completion)
* [list](#list)
* [install](#install)
* [upgrade](#upgrade)
* [remove](#remove)
* [cache](#cache)

**注意** 大部分指令都可以接受一個 `-t` 的 test 參數，使用此參數會執行所有工作但不會真實的更改應用安裝情況，你可以使用它來跟蹤打印信息以便在操作前可以確認下會如何修改系統檔案

## completion

completion 子命令用於爲 bash 生成命令自動完成的代碼。強烈建議使用如果沒有自動完成，那麼 linux 的 shell 和 windows 的 cmd 那條鹹魚間還有什麼區別😂，輸入 `-h` 參數可查看詳細說明
```
github-apps.sh completion -h
```

要使當前 shell 獲取自動完成功能，可以執行如下指令
```
source <(github-apps.sh completion)
```

對於 *inux 系統可以執行如下指令，使所有新打開的 shell 都獲取自動完成功能

```
github-apps.sh completion > /etc/bash_completion.d/github-app.sh
```

對於 MacOS 可以執行如下指令，使所有新打開的 shell 都獲取自動完成功能

```
github-apps.sh completion > /usr/local/etc/bash_completion.d/github-app.sh
```

## list

list 指令用於列出支持的應用或已經安裝的應用，輸入 `-h` 參數可查看詳細說明
```
github-apps.sh list -h
```


不帶參數的 list 指令會列出所有支持的應用，如果要爲應用添加支持，你需要爲應用寫一個[配置腳本](#配置腳本)
```
github-apps.sh list 
coredns
ariang
```

傳入 `-v` 參數用於顯示出本地安裝的應用版本號，傳入 `-i` 參數則用於要求只顯示出本地已經安裝的應用

```
github-apps.sh list -v
coredns v1.8.7
ariang
```

## install

install 指令用於安裝應用，輸入 `-h` 參數可查看詳細說明

```
github-apps.sh install -h
```

install 可以接受多個要安裝的應用名稱，腳本會依次安裝，下面的指令將安裝 coredns 和 ariang 兩個應用

```
github-apps.sh install coredns ariang
```

install 默認會從 github 上查找最後一個完整的發佈版本進行安裝，你可以使用 `-v` 參數指定一個要安裝的版本，但是如果使用 `-v` 參數 install 就只能接受一個要安裝的應用。下面的指令將安裝 v1.2.0 版本的 coredns

```
github-apps.sh install coredns -v v1.2.0
```

install 會檢測本地已安裝的版本，如果你已經安裝了一個高版本的應用，也可以使用 `install -v` 參數來降級到一個低版本或強制升級到一個不匹配的非兼容高版本應用。請放心嘗試 `-v` 參數，因爲如果沒有使用 `-y` 參數，install 在查找到版本並執行安裝前會向你詢問是否要繼續安裝。

## upgrade

upgrade 指令用於升級已安裝的應用，輸入 `-h` 參數可查看詳細說明

```
github-apps.sh upgrade -h
```

upgrade 和 install 一樣可以接受多個要升級的應用名稱，腳本會依次執行升級。同時如果只升級一個應用 upgrade 也支持 `-v` 參數，但 upgrade 不能降級到一個低版本應用或升級到一個非兼容的高版本，要那麼做只能使用 install 指令。下面的指令將升級 coredns 和 ariang 兩個應用

```
github-apps.sh upgrade coredns ariang
```

值得一提的是 upgrade 可以不輸入應用名稱，這樣 upgrade 就會檢測已經安裝的應用並依次爲它們執行升級操作

```
github-apps.sh upgrade
```

## remove

當你不在需要某個應用時，可以使用 remove 來刪除它，輸入 `-h` 參數可查看詳細說明

```
github-apps.sh remove -h
```
remove 同樣可以接受多個要刪除的應用名稱，腳本會依次執行刪除。下面的指令將刪除 coredns 和 ariang 兩個應用

```
github-apps.sh remove coredns ariang
```

**注意** remove 在刪除前不會再向你發出詢問，所以請確定真的想刪除時才執行此命令。

通常 remove 只會刪除應用程式，而保留應用的配置檔案和數據檔案，例如 mysql 的配置屬於配置檔案，mysql 數據庫屬於數據檔案。你可以使用 `-c` 參數通知 remove 將配置檔案一起刪除，`-d` 參數通知 remove 將數據檔案也刪除。另外 `-a` 指令會同時指定刪除配置檔案和數據檔案

```
github-apps.sh remove coredns -a
```

**注意** 實際的刪除工作是由應用的配置腳本完成的，默認提供的配置腳本都遵循了 `-c -d` 參數的提示工作，但如果你使用第三方提供的配置腳本需要自己確定配置腳本是否遵循了這個設計要求

## cache

install 和 upgrade 會將下載下來的安裝包存儲到 github-app.sh 所在位置的 github-apps.cache 檔案夾下，如果一切順利 github-app.sh 會自動刪除用完的緩存數據，如果發生了意外你也可以使用 cache 指令查看緩存和清空緩存數據

同樣輸入 `-h` 參數可查看詳細說明

```
github-app.sh cache -h
```

下面指令查看緩存佔用磁盤大小
```
github-app.sh cache
```

下面指令清空緩存
```
github-app.sh cache -d
```

# 版本號

使用語義化的版本號，支持兩種形式

* MAJOR.MINOR.PATCH
* vMAJOR.MINOR.PATCH

MAJOR MINOR PATCH 是一個正整數，MAJOR 是主版本號，當應用升級時只有相同的 MAJOR 才匹配。但是有一個例外可以從 MAJOR 0，升級到 MAJOR 1。

# 配置腳本

不同的開源應用安裝配置都各不相同，爲了支持它們需要創建 **配置腳本**。github-apps.sh 負責解析用戶傳入的參數，查找應用版本並下載等複雜的操作，而用戶需要自己爲應用編寫配置腳本用於指定安裝路徑，解壓壓縮包到磁盤，刪除磁盤等操作。

配置腳本需要設置到 github-apps.sh 所在路徑的 **github-apps.configure** 檔案夾下並且以 .sh 爲後綴的 bash 腳本。github-apps.sh 會使用 source 來加載配置腳本。

你可以參考 [內置的配置腳本](https://github.com/powerpuffpenguin/github-apps/tree/main/bin/github-apps.configure) 來實現自己的配置腳本，本喵推薦查看 [coredns.sh](https://github.com/powerpuffpenguin/github-apps/blob/main/bin/github-apps.configure/coredns.sh) 這個腳本裏面帶有詳細的註釋說明，其它內置腳本可能沒有完整的註釋

**注意** 配置腳本中自定義的全局變量和函數不要覆蓋 github-apps.sh 中同名變量或函數，建議使用一個自定義的名稱前綴，下面幾個前綴都是安全且建議的
* self
* this
* my
* conf

> 多個配置腳本間不用擔心名稱衝突，每次調用配置腳本前 github-apps.sh 都會重新 source 配置腳本

## 全局變量

github-apps.sh 中定義了幾個全局變量，配置腳本和 github-apps.sh 需要通過這幾個變量進行通信(誰讓 bash 函數連返回值都沒有呢😂)

|變量名|型別|描述|
|--|--|--|
|FlagPlatformError  |字符串 |如果平臺不支持應用，請將錯誤描述設置到此變量|
|FlagInstallDir|    字符串| 安裝路徑|
|FlagTest   | 0 或者 1| 如果爲 1，測試執行|
|FlagVersion   | 字符串| 目標版本|
|FlagYes   | 0 或者 1| 如果爲 1，自動回覆 yes|
|FlagNo   | 0 或者 1| 如果爲 1，自動回覆 no|
|FlagSum | 0 或者 1|    如果爲 1，需要檢測下載安裝包的 checksum|
|FlagDeleteConf| 0 或者 1|    如果爲 1，刪除應用配置檔案|
|FlagDeleteData| 0 或者 1|    如果爲 1，刪除應用數據檔案|
|FlagDownloadFile| 字符串|    應用安裝包下載地址|
|FlagDownloadHash| 字符串|    包含安裝包 checksum 網址|
|FlagUrlLatest| 字符串|    [github api 獲取最後發佈版本的地址](https://docs.github.com/en/rest/reference/releases#get-the-latest-release)|
|FlagUrlList| 字符串|    [github api 獲取版本列表的地址](https://docs.github.com/en/rest/reference/releases#list-releases)|
|FlagUrlTag| 字符串|    [github api 獲取指定版本的地址](https://docs.github.com/en/rest/reference/releases#get-a-release-by-tag-name)|

## 回調函數

在配置腳本中你需要實現一些回調函數，以協助 github-apps.sh 完成工作。github-apps.sh 通過全局變量和配置腳本進行數據交互。

### AppsPlatform

這個函數會是第一個被調用的函數，你應該在裏面檢測系統平臺是否支持當前應用如果不支持就設置 **FlagPlatformError** 變量爲非空，這樣 github-apps.sh 就會將 FlagPlatformError 以錯誤信息輸出並結束工作。不要在此函數裏面使用 echo 輸出，而是將錯誤信息設置到 FlagPlatformError，因爲 github-apps.sh 會在很多不希望輸出錯誤信息時調用 AppsPlatform 用以檢測應用是否支持當前平臺

如果當前平臺支持應用，則你需要將應用安裝路徑設置到 **FlagInstallDir** 變量中

### AppsSetUrl

在執行安裝或升級之前會調用此函數，你需要設置好 **FlagUrlLatest** **FlagUrlList** **FlagUrlTag** 三個變量來告訴 github-apps.sh 到哪裏去查找應用版本信息

此外你可以檢測 **FlagVersion** 不爲空則代表用戶指定了一個版本號，只有在此時才需要設置 **FlagUrlTag** 變量

### AppsSetFile

當從 github 上查找到版本的可下載資產時，對於每個資產都會調用一次此函數，其第一個傳入參數是資產名稱，第二個傳入參數是下載地址

你需要依據資產名稱確定是否是當前平臺的安裝包，如果是則設置下載地址到變量 **FlagDownloadFile** 中

同時如果你查找到 checksum 檔案，則可以設置它的下載地址到 **FlagDownloadHash** 中，這樣在安裝前會檢測下載包的 checksum 值

### AppsHash

AppsHash 是可選實現的

如果 FlagDownloadHash 被設置並且用戶沒有使用 **--skip-checksum** 參數，則會調用 AppsHash 計算 checksum。AppsHash 第一個參數是下載的安裝包路徑，你需要在裏面計算 checksum 並輸出，github-apps.sh 會使用輸出的值作爲 checksum

AppsHash 的默認實現是直接調用 `sha256sum "$1"`

### AppsUnpack

AppsUnpack 的第一個傳入參數是下載的安裝包路徑，你需要在此函數中解開壓縮包將應用安裝到 **FlagInstallDir** 指定的路徑中去

記得在真實安裝應用前檢測 **FlagTest** 變量如果爲非 0，則代表用戶只是想測試看看，不要執行真實的安裝應該只是打印下安裝流程就好

### AppsRemove

當刪除應用時會調用 AppsRemove 回調，你應該在此函數中刪除安裝到 **FlagInstallDir** 路徑中的應用

記得在真實刪除應用前檢測 **FlagTest** 變量如果爲非 0，則代表用戶只是想測試看看，不要執行真實的刪除應該只是打印下刪除流程就好

### AppsVersion

AppsVersion 是可選實現的

如果傳入的第二個參數爲空字符串則需要返回當前安裝的應用版本號到變量 **AppsVersionValue** 中

如果傳入的第二個參數爲非空字符串則第二個參數是正在安裝的應用版本號，你需要將到它持久化到某處以便日後可以返回版本號供 github-apps.sh 查詢

當沒有實現 AppsVersion 函數時，默認的行爲是在 FlagInstallDir 指定的安裝路徑下創建一個 apps.version 檔案用於記錄應用版本號

## 其它源的應用

github-apps.sh 默認只能支持 github 上發佈的應用，因爲它只解析了 github api 返回的數據，但是如果有另外一個網站返回類似 github api 的返回結果則 github-apps.sh 也可以工作。此外有兩個回調函數可以在你的配置檔案中重寫，用於替代默認的 github api 請求與解析以支持額外來源的應用：

* [AppsRequestVersion](#AppsRequestVersion)
* [AppsRequestVersionList](#AppsRequestVersionList)

## AppsRequestVersion

如果配置腳本提供了此函數則會替代默認的版本請求，你需要在此函數中

1. 依據全局變量 **FlagVersion** 如果爲空查找最後的發佈的完整版本信息，如果非空查找指定的版本信息。
2. 調用 `VersionNext "找到的版本號"` 函數進行設置，並且判斷返回值 **VersionNextOk** 爲 1 以確定版本號格式被支持
3. 將找到的版本號設置到變量 **FlagVersion** 中
4. 將安裝包下載地址設置到 **FlagDownloadFile** 變量
5. 如果存在 checksum 且 **FlagSum** 變量不爲 0，則將 checksum 下載地址設置到 **FlagDownloadHash** 變量

## AppsRequestVersionList

如過配置腳本提供了此函數，則當最後發佈的版本與當前安裝的版本不匹配時，調用此函數查找最後的可升級版本。你需要在此函數中
1. 查找到最後的可升級版本
2. 調用 `VersionNext "找到的版本號"` 函數進行設置，並且判斷返回值 **VersionNextOk** 爲 1 以確定版本號格式被支持
3. 將找到的版本號設置到變量 **FlagVersion** 中
4. 將安裝包下載地址設置到 **FlagDownloadFile** 變量
5. 如果存在 checksum 且 **FlagSum** 變量不爲 0，則將 checksum 下載地址設置到 **FlagDownloadHash** 變量