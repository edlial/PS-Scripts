$content = 'ServerBaseURL = "https://10.248.248.2:9174"
StrictSSLCheckingEnabled = false
HTTPProxy = ""'
Set-Content -Path "C:\Program Files\PaperCut Print Deploy Client\data\config\client.conf.toml" -Value $content