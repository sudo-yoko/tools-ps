$TargetFolder = "C:\Users\gagip\AppData\Local\Temp"
$OutputFile = "C:\temp\folder_sizes.txt"

# 各フォルダのサイズを計算して一覧を取得
$Result = Get-ChildItem -Path $TargetFolder -Directory | ForEach-Object {
    $CurrentFolder = $_

    # サブフォルダ内を含むすべてのファイルサイズを合計
    $SizeSum = Get-ChildItem -Path $CurrentFolder.FullName -File -Recurse -ErrorAction SilentlyContinue |
    Measure-Object -Property Length -Sum

    # 単位MBに変換（小数点2桁）
    $SizeInMB = [math]::Round(($SizeSum.Sum / 1MB), 2)

    [PSCustomObject]@{
        "フォルダ名"   = $CurrentFolder.Name
        "サイズ(MB)" = $SizeInMB
    }
}

# テキストファイルに整形して出力
$Result | Format-Table -AutoSize | Out-File -FilePath $OutputFile -Encoding utf8

# 出力したテキストファイルを既定のアプリ（メモ帳など）で開く
Invoke-Item -Path $OutputFile
# Start-Process $OutputFile