:Attempt Uninstalls
echo product where "name like 'TeamViewer%%'" call uninstall /nointeractive|wmic && shutdown /a
"%programfiles(x86)%\TeamViewer\uninstall.exe" /S
"%programfiles%\TeamViewer\uninstall.exe" /S