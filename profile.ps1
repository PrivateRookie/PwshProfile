# Set-Proxy command
Function SetProxy() {
    Param(
        $Addr = $null,
        [switch]$ApplyToSystem
    )
    
    $env:HTTP_PROXY = $Addr;
    $env:HTTPS_PROXY = $Addr; 
    $env:http_proxy = $Addr;
    $env:https_proxy = $Addr;
  
    if ($null -eq $addr) {
        [Net.WebRequest]::DefaultWebProxy = New-Object Net.WebProxy;
        if ($ApplyToSystem) { SetSystemProxy $null; }
        Write-Output "Successful unset all proxy variable";
    }
    else {
        [Net.WebRequest]::DefaultWebProxy = New-Object Net.WebProxy $Addr;
        if ($ApplyToSystem) {
            $matchedResult = ValidHttpProxyFormat $Addr;
            # Matched result: [URL Without Protocol][Input String]
            if (-not ($null -eq $matchedResult)) {
                SetSystemProxy $matchedResult.1;
            }
        }
        Write-Output "Successful set proxy as $Addr";
    }
}
Function SetSystemProxy($Addr = $null) {
    Write-Output $Addr
    $proxyReg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings";

    if ($null -eq $Addr) {
        Set-ItemProperty -Path $proxyReg -Name ProxyEnable -Value 0;
        return;
    }
    Set-ItemProperty -Path $proxyReg -Name ProxyServer -Value $Addr;
    Set-ItemProperty -Path $proxyReg -Name ProxyEnable -Value 1;
}
Function ValidHttpProxyFormat ($Addr) {
    $regex = "(?:https?:\/\/)(\w+(?:.\w+)*(?::\d+)?)";
    $result = $Addr -match $regex;
    if ($result -eq $false) {
        throw [System.ArgumentException]"The input $Addr is not a valid HTTP proxy URI.";
    }

    return $Matches;
}

# python 设置
function pipenv {
    python.exe -m pipenv $args
}

function bbat {
    bat $args
}

function CodeRemote {
    <#
        .Description
        code 命令打开远程文件
    #>
    param (
        # 远端服务器 [user@]hostname
        [Parameter(Mandatory = $true)]
        [string]
        $remote,

        
        # 远端目录路径
        [Parameter(Mandatory = $true)]
        [string]
        $path
    )
    $path = ssh $remote echo $path
    code --remote ssh-remote+$remote $path
}

function open-link {
    <#
        .Description
        使用 MS Edge 打开连接
    #>
    param (
        # 网页地址
        [string]
        $url
    )
    $edge = "C:\Users\rookie\AppData\Local\Microsoft\Edge SXS\Application\msedge.exe"
    Start-Process $edge $url
}

enum SearchEngine {
    Doge
    Bing
    Google
    Baidu
}

function search-thing {
    <#
        .Description
        使用浏览器搜索
    #>
    param (
        # 搜索关键字
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $keyword,

        # 指定搜索引擎
        [SearchEngine]
        $engine = [SearchEngine]::Doge
    )
    switch ($engine) {
        { [SearchEngine]::Doge } { $url = "https://www.dogedoge.com/results?q=$keyword"; break }
        { [SearchEngine]::Bing } { $url = "https://cn.bing.com/search?q=$keyword"; break }
        { [SearchEngine]::Google } { $url = "https://google.com/search?q=$keyword"; break }
        { [SearchEngine]::Baidu } { $url = "https://www.baidu.com/s?wd=$keyword"; break }
        Default { $url = "https://www.dogedoge.com/results?q=$keyword" }
    }
    open-link $url
}

Set-Alias -Name ll -Value ls
Set-Alias -Name set-proxy -Value SetProxy
Set-Alias -Name cat -Value bbat
Set-Alias -Name code-remote -Value CodeRemote

# 如果没有安装 starship, 注释下面的命令
Invoke-Expression (&starship init powershell)

# rustup 设置
# $env:RUSTUP_DIST_SERVER = 'http://mirrors.rustcc.cn'
# $env:RUSTUP_DIST_SERVER = 'https://mirrors.tuna.tsinghua.edu.cn/rustup'
# $env:RUSTUP_UPDATE_ROOT = 'http://mirrors.rustcc.cn/rustup'

$MaximumHistoryCount = 200
$historyPath = Join-Path (split-path $profile) history.clixml

Register-EngineEvent -SourceIdentifier powershell.exiting -SupportEvent -Action {
    Get-History | Export-Clixml $historyPath
}.GetNewClosure()

if ((Test-Path $historyPath)) {
    Import-Clixml $historyPath | Where-Object { $count++; $true } | Add-History
    Write-Host -Fore Green "`nLoaded $count history item(s).`n"
}
