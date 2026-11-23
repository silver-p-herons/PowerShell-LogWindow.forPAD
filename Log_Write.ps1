#  初期設定
$pipeName = "MyPowerShellPipe"

# 初期表示
Write-Host "PAD動作中です。終了するか案内があるまで放置推奨です。`n途中で止まったりした時は、このウインドウを閉じてください。"


# 無限ループで監視
while ($true) {
	# パイプサーバーの作成(毎回行うことで、送信側が切断しても再接続可能)
	$pipeServer = New-Object System.IO.Pipes.NamedPipeServerStream($pipeName, [System.IO.Pipes.PipeDirection]::In)
	$reader = $null

	# メッセージが送られてくるまで一時停止する
	$pipeServer.WaitForConnection()

	# 届いたデータを読み取って表示
	$reader = New-Object System.IO.StreamReader($pipeServer)
	$message = $reader.ReadLine()

	if ($message -eq "exit") {
		Write-Host "受信終了コマンドを受け取りました。スクリプトを終了します。"
		break
	}

	Write-Host $message

	# 後片付け(やらないとリソースリークする)
	$reader.Dispose()
	$pipeServer.Dispose()

}

# breakしたときの後片付け(比較的すぐに解放されるが連続して起動したいなら必要かも)
$reader.Dispose()
$pipeServer.Dispose()
