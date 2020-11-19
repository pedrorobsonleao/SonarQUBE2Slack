Import-Module .\lib\Slack-Library.psm1;
Import-Module .\lib\SonarQUBE-Library.psm1

# Load and parse the JSON configuration file
try {
	$global:Config = Get-Content "appsettings.json" -Raw  | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
}
catch {
	Write-Error -Message "The Base configuration file is missing!" -Stop
	return
}

$Str = ""
# Get info from all modules
ForEach ($component in $Global:Config.SonarQUBE.projects) {
	try {
		$Str += Get-SonarQUBE $component
	} catch {
		if( $_.Exception.Message -ne "ThresholdAlertException" ) {
			$Str +=  $_.Exception.Message
		} 
	}
}

# sent message to slack
Send-SlackMessage $Str -Url $global:Config.Slack.url  -Channel $global:Config.Slack.channel  -Emoji $global:Config.Slack.icon_emoji  -IconUrl $global:Config.Slack.icon_url -Username $global:Config.Slack.username;