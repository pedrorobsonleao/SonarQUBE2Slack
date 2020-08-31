Import-Module .\lib\Slack-Library.psm1;
Import-Module .\lib\SonarQUBE-Library.psm1

# Load and parse the JSON configuration file
try {
	# $global:Config = Get-Content "appsettings.json2" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
	$global:Config = Get-Content "appsettings.json" -Raw  | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
}
catch {
	Write-Error -Message "The Base configuration file is missing!" -Stop
	return
}

$ArrayStr = Get-SonarQUBE

ForEach ( $Str in $ArrayStr ) {
	Write-Host $Str
	Send-SlackMessage $Str -Url $global:Config.Slack.url  -Channel $global:Config.Slack.channel  -Emoji $global:Config.Slack.icon_emoji  -IconUrl $global:Config.Slack.icon_url -Username $global:Config.Slack.username;
}