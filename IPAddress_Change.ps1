Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# フォームに設定するオブジェクトの縦軸座標位置
$NextLocatePoint = 20

# インターフェイス情報一覧を取得
$InterfaceInfo = @{};
Get-NetIPAddress -AddressFamily ipv4 | ForEach-Object -process {$InterfaceInfo.add($_.InterfaceAlias,$_.IPAddress)}
$KeyCollectionKeys = $InterfaceInfo.Keys
$Keys = @()
foreach ( $KeyCollectionKey in $KeyCollectionKeys){
    $Keys += $KeyCollectionKey
    }

$Form = New-Object System.Windows.Forms.Form
$Form.Text = 'IPアドレス変更'
$Form.Size = New-Object System.Drawing.Size(300,200)
$Form.StartPosition = 'CenterScreen'
$Form.AutoSize = $TRUE

# インターフェイス情報一覧を表示
$InputMessage = New-Object System.Windows.Forms.Label
$InputMessage.Location = New-Object System.Drawing.Point(10,$NextLocatePoint)
$InputMessage.Size = New-Object System.Drawing.Size(280,20)
$InputMessage.Text = '変更するインターフェイスを選択してください'
$InputMessage.AutoSize = $TRUE
$Form.Controls.Add($InputMessage)

# 次のオブジェクトを配置する縦軸座標に更新
$NextLocatePoint = $NextLocatePoint + 20

$IntRadioButon = @();
foreach ($Key in $Keys){
    $Index = [Array]::IndexOf($Keys, $Key)
    $IntRadioButon += (New-Object System.Windows.Forms.RadioButton)
    $IntInfoPoint = $NextLocatePoint + $Index * 20
    $IntRadioButon[$Index].Location = New-Object System.Drawing.Point(10,$IntInfoPoint)
    $IntRadioButon[$Index].Size = New-Object System.Drawing.Size(280,20)
    $IntRadioButon[$Index].Text = $Key + "`t： " + $InterfaceInfo[$Key]
    $IntRadioButon[$Index].AutoSize = $TRUE
    $Form.Controls.Add($IntRadioButon[$Index])
    }

# 次のオブジェクトを配置する縦軸座標に更新
$NextLocatePoint += $NextLocatePoint + (($Keys.Count-1) * 20) + 20

# 入力メッセージ
$InputMessage = New-Object System.Windows.Forms.Label
$InputMessage.Location = New-Object System.Drawing.Point(10,$NextLocatePoint)
$InputMessage.Size = New-Object System.Drawing.Size(280,20)
$InputMessage.Text = 'IPアドレスを入力してください(DHCPクライアントを有効にする場合は文字列"DHCP"を入力)'
$InputMessage.AutoSize = $TRUE
$Form.Controls.Add($InputMessage)

# 次のオブジェクトを配置する縦軸座標に更新
$NextLocatePoint = $NextLocatePoint + 20

# IPアドレス入力フォーム
$AddressMessage = New-Object System.Windows.Forms.Label
$AddressMessage.Location = New-Object System.Drawing.Point(10,$NextLocatePoint)
$AddressMessage.Size = New-Object System.Drawing.Size(70,10)
$AddressMessage.Text = "IP Address："
$Form.Controls.Add($AddressMessage)

$InputAddBox = New-Object System.Windows.Forms.TextBox
$InputAddBox.Location = New-Object System.Drawing.Point(110,$NextLocatePoint)
$InputAddBox.Size = New-Object System.Drawing.Size(100,10)
$InputAddBox.MaxLength = 16
$InputAddBox.Text = "DHCP"
$InputAddBox.AutoSize = $TRUE
$Form.Controls.Add($InputAddBox)

# 次のオブジェクトを配置する縦軸座標に更新
$NextLocatePoint = $NextLocatePoint + 30

# プレフィックス長入力フォーム
$PrefixMessage = New-Object System.Windows.Forms.Label
$PrefixMessage.Location = New-Object System.Drawing.Point(10,$NextLocatePoint)
$PrefixMessage.Size = New-Object System.Drawing.Size(70,10)
$PrefixMessage.Text = "Prefix："
$Form.Controls.Add($PrefixMessage)

$InputPreBox = New-Object System.Windows.Forms.TextBox
$InputPreBox.Location = New-Object System.Drawing.Point(110,$NextLocatePoint)
$InputPreBox.Size = New-Object System.Drawing.Size(20,10)
$InputPreBox.MaxLength = 2
$InputPreBox.Text = "24"
$InputPreBox.AutoSize = $TRUE
$Form.Controls.Add($InputPreBox)

# 次のオブジェクトを配置する縦軸座標に更新
$NextLocatePoint = $NextLocatePoint + 30

# デフォルトゲートウェイ入力フォーム
$GatewayMessage = New-Object System.Windows.Forms.Label
$GatewayMessage.Location = New-Object System.Drawing.Point(10,$NextLocatePoint)
$GatewayMessage.Size = New-Object System.Drawing.Size(100,20)
$GatewayMessage.Text = "Default Gateway："
$Form.Controls.Add($GatewayMessage)

$InputGateBox = New-Object System.Windows.Forms.TextBox
$InputGateBox.Location = New-Object System.Drawing.Point(110,$NextLocatePoint)
$InputGateBox.Size = New-Object System.Drawing.Size(100,10)
$InputGateBox.MaxLength = 16
$InputGateBox.Text = "192.168.1.1"
$InputGateBox.AutoSize = $TRUE
$Form.Controls.Add($InputGateBox)

# 次のオブジェクトを配置する縦軸座標に更新
$NextLocatePoint = $NextLocatePoint + 30

# OKボタン
$OkButton = New-Object System.Windows.Forms.Button
$OkButton.Location = New-Object System.Drawing.Point(75,$NextLocatePoint)
$OkButton.Size = New-Object System.Drawing.Size(75,23)
$OkButton.Text = 'OK'
$OkButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$Form.AcceptButton = $OkButton
$Form.Controls.Add($OkButton)

# キャンセルボタン
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,$NextLocatePoint)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$Form.CancelButton = $CancelButton
$Form.Controls.Add($CancelButton)

# フォームを最上部に移動
$Form.Topmost = $TRUE

# フォームのアクティブ化
$Form.Add_Shown({$InputAddBox.Select()})

# フォームを表示
$Result = $Form.ShowDialog()

# OKボタンが押下された場合の処理
if ($Result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $IP_Address = $InputAddBox.text

    # ユーザ入力の値がIPアドレス範囲、またはDHCPの場合に処理を実行
    if(($IP_Address -match "^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$") -Or ($IP_Address -eq "DHCP"))
    {
        
        # ラジオボタンの状態をループでチェック
        foreach ($Key in $Keys){
            $Index = [Array]::IndexOf($Keys, $Key)

            # ラジオボタンが選択されている対象に対して処理を実行
            if($IntRadioButon[$Index].Checked){

                # 入力がDHCPの場合、DHCPクライアントを有効化
                if($IP_Address -eq "DHCP")
                {
                    Start-Process powershell.exe -ArgumentList "Get-NetAdapter -Name $Key | Set-NetIPInterface -AddressFamily IPv4 -Dhcp Enabled" -Verb runas
                    #Start-Sleep -s 20
                    #Start-Process powershell.exe -ArgumentList "Restart-NetAdapter -Name $Key -Confirm:$False" -Verb runas
                    # DHCP変換後、なぜか自己割り当てIPアドレスになる。時間を置いた後アダプター再起動により復旧する。なぜだ
                }
                
                # それ以外(IPアドレス範囲)の場合、IPアドレスを入力値で変更
                else
                {
                    if(($InputPreBox.Text -match "^[12]?[1-9]$") -And ($InputGateBox.Text -match "^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"))
                    {
                        Start-Process powershell.exe -ArgumentList "Get-NetAdapter -Name $Key | New-NetIPAddress -AddressFamily IPv4 -IPAddress $IP_Address -PrefixLength $InputPreBox.Text -DefaultGateway $InputGateBox.Text" -Verb runas
                    }
                    else
                    {
                        [System.Windows.MessageBox]::Show("プレフィックスの値が不正です。","入力エラー","YesNoCancel","Error")
                    }
                }
            }
        }
    }
    # ユーザ入力が不正な場合の処理
    else
    {
        [System.Windows.MessageBox]::Show("入力が有効なIPアドレス範囲を逸脱しています。","入力エラー","YesNoCancel","Error")
    }
}
