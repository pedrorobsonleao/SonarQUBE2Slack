function Get-Color {
    param([Parameter(Mandatory = $true, Position = 0)] $Average)

    $Color = "good"
    
    ForEach ( $Threshold in $Global:Config.SonarQUBE.threshold) {
        if ( $Average -ge $Threshold.value ) {
            if ($Threshold.alert -eq $true) {
                return $Threshold.color
            }
            break
        }
    } 

    return $Color
}
function Send-SlackMessage {
    # Add the "Incoming WebHooks" integration to get started: https://slack.com/apps/A0F7XDUAZ-incoming-webhooks
    param (
        [Parameter(Mandatory = $true, Position = 0)]$Text,
        $Url = "https://hooks.slack.com/services/xxxxx", #Put your URL here so you don't have to specify it every time.
        # Parameters below are optional and will fall back to the default setting for the webhook.
        $Username, # Username to send from.
        $Channel, # Channel to post message. Can be in the format "@username" or "#channel"
        $Emoji, # Example: ":bangbang:".
        $IconUrl, # Url for an icon to use.
        $GeneralAverage #General Threshold 
    )
    
    $Color =  Get-Color -Average $GeneralAverage

    $body = @{ 
        channel = $Channel; 
        username = $Username.split("-")[0]; 
        icon_emoji = $Emoji; 
        icon_url = $IconUrl; 
        color = $Color;
        fields = @(
            @{
                title = ":: " + $Username.split("-")[1] + " SonarQUBE Metrics";
                value = $Text;
                short = $false;
            }
        ) } | ConvertTo-Json 

    #$body = [System.Web.HttpUtility]::UrlEncode($body)

    Write-Host $body
    
    Try {
        $resp = Invoke-WebRequest -UseBasicParsing -Method Post -ContentType "application/json;charset=UTF-8" -Uri $Url -Body $body 
    }
    Catch {
        Write-Error "An exception was caught: $($_.Exception.Message)"
    }

    if ( $resp.StatusCode -ne 200 ) {
        Write-Host "Error: ", $resp.StatusCode, $resp.StatusDescription;
    } 

}
