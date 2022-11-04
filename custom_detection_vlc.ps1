$path1 = "C:\Program Files\VideoLAN\VLC"
$path2 = "C:\Program Files (x86)\VideoLAN\VLC"

if ((test-path -PathType container $path1) -Or (test-path -PathType container $path2)) {
    Write-Host "Vlc is installed!"
    exit 0
}
else {
    exit 1
}