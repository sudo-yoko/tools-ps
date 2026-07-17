# 厳格モードの適用
Set-StrictMode -Version 3.0
$ErrorActionPreference = "Stop"

# ライブラリ（アセンブリ）の読み込み
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#######################
# フォームの作成
#######################
$form = New-Object System.Windows.Forms.Form
$form.AutoSize = $true
$form.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.MaximizeBox = $false
$form.TopMost = $true
$form.Opacity = 0.9
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle

# タイトルバーを消す
$form.Text = ""
$form.ControlBox = $false

#######################
# レイアウトコンテナ
#######################
$container = New-Object System.Windows.Forms.FlowLayoutPanel
$container.AutoSize = $true
$container.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
$container.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
$container.WrapContents = $false
$container.Padding = New-Object System.Windows.Forms.Padding(5, 5, 0, 0)
$form.Controls.Add($container)

#######################
# PC画面のみボタン
#######################
$internalButton = New-Object System.Windows.Forms.Button
$internalButton.AutoSize = $false
$internalButton.Size = New-Object System.Drawing.Size(150, 40)
$internalButton.Anchor = [System.Windows.Forms.AnchorStyles]::None
$internalButton.Font = New-Object System.Drawing.Font("Arial", 20)
$internalButton.Text = "internal"
$internalButton.Add_Click({
        Start-Process "displayswitch.exe" -ArgumentList "/internal"
    })
$container.Controls.Add($internalButton)

#######################
# 外付けモニターのみボタン
#######################
$externalButton = New-Object System.Windows.Forms.Button
$externalButton.AutoSize = $false
$externalButton.Size = New-Object System.Drawing.Size(150, 40)
$externalButton.Anchor = [System.Windows.Forms.AnchorStyles]::None
$externalButton.Font = New-Object System.Drawing.Font("Arial", 20)
$externalButton.Text = "external"
$externalButton.Add_Click({
        Start-Process "displayswitch.exe" -ArgumentList "/external"
    })
$container.Controls.Add($externalButton)

#######################
# 複製ボタン
#######################
$cloneButton = New-Object System.Windows.Forms.Button
$cloneButton.AutoSize = $false
$cloneButton.Size = New-Object System.Drawing.Size(150, 40)
$cloneButton.Anchor = [System.Windows.Forms.AnchorStyles]::None
$cloneButton.Font = New-Object System.Drawing.Font("Arial", 20)
$cloneButton.Text = "clone"
$cloneButton.Add_Click({
        Start-Process "displayswitch.exe" -ArgumentList "/clone"
    })
$container.Controls.Add($cloneButton)

#######################
# 閉じるボタン
#######################
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.AutoSize = $false
$closeButton.Size = New-Object System.Drawing.Size(100, 40)
$closeButton.Anchor = [System.Windows.Forms.AnchorStyles]::None # コンテナの上下中央に配置
$closeButton.Font = New-Object System.Drawing.Font("Arial", 20)
$closeButton.Text = "close"
$closeButton.Add_Click({
        $form.Close()
    })
$container.Controls.Add($closeButton)

#######################
# デバッグ用機能
#######################
# $form.BackColor = [System.Drawing.Color]::Green
# $container.BackColor = [System.Drawing.Color]::Blue
# $timeLabel.BackColor = [System.Drawing.Color]::Red
$esc = New-Object System.Windows.Forms.Timer
$esc.Interval = 2000
$esc.Add_Tick({
        [System.Windows.Forms.SendKeys]::SendWait("{ESC}")
        Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Escキー送信"
    })
$esc.start()
#$form.BackColor = [System.Drawing.Color]::Yellow

#######################
# フォームの移動
#######################
# マウスが押された瞬間のクリック位置を記憶しておく変数
$script:lastMousePos = [System.Drawing.Point]::Empty

# フォーム、コンテナ、に同じイベントを登録する
$dragTargets = @($form, $container)
foreach ($target in $dragTargets) {
    # マウスが押された時
    $target.Add_MouseDown({
            param($_sender, $e)
            $null = $_sender    # 未使用パラメータの警告抑制のため
            if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
                $script:lastMousePos = [System.Windows.Forms.Cursor]::Position
            }
        })
    # マウスが動いているとき
    $target.Add_MouseMove({
            param($_sender, $e)
            $null = $_sender    # 未使用パラメータの警告抑制のため
            if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left -and !$script:lastMousePos.IsEmpty) {
                # マウスの位置を取得して移動させる
                $currentPos = [System.Windows.Forms.Cursor]::Position
                $deltaX = $currentPos.X - $script:lastMousePos.X
                $deltaY = $currentPos.Y - $script:lastMousePos.Y
                $form.Location = New-Object System.Drawing.Point(
                    ($form.Location.X + $deltaX),
                    ($form.Location.Y + $deltaY)
                )
                $script:lastMousePos = $currentPos
            }
        })
    # マウスボタンが離された時
    $target.Add_MouseUp({
            $script:lastMousePos = [System.Drawing.Point]::Empty
        })
}

#######################
# フォーム終了時
#######################
$form.Add_FormClosing({
        $esc.Stop()
        $esc.Dispose()
    })

#######################
# イベントループの開始
#######################
[System.Windows.Forms.Application]::Run($form)

#######################
# 終了後にリソースを開放
#######################
$form.Dispose()
