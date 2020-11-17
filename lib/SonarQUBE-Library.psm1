function Request-SonarQUBE {
    Param(
        [Parameter(Mandatory = $true, Position = 0)]$Component,
        $Metrics = "coverage",
        $PageIndex = 1,
        $PageSize = 1
    )

    $Url = $Global:Config.SonarQUBE.url
    $Url += "?component=${Component}&metrics=${Metrics}&pageIndex=${PageIndex}&pageSize=${PageSize}"       

    return Invoke-WebRequest -UseBasicParsing -Method Get -ContentType "application/json;charset=UTF-8" -Uri $Url
}

function Get-SonarQUBE {

    $ResponseArray = $()
    $Send = $false

    ForEach ($component in $Global:Config.SonarQUBE.projects) {
           
        Try {
            $response =  Request-SonarQUBE  $component
        }
        Catch {

            Write-Error "An exception was caught: $($_.Exception.Message)"
            
            $err = $_.Exception.Message

            $icon = $Global:Config.SonarQUBE.icon_error

            $ResponseArray += " ${icon} *_${component}_* - ``${err}`` `n"
            
            $Send = $true
            continue
        }

        if ($response.StatusCode -eq 200) {
            $response = $response.Content | ConvertFrom-Json

            if ($response.errors) {
                $icon = $Global:Config.SonarQUBE.icon_error
                $msg = $response.errors[0].msg 
                $ResponseArray += " ${icon} *_${component}_* - ``${msg}`` `n"
            }
            else {
                Try {
                    $response =  Request-SonarQUBE  $component -PageIndex  $response.paging.total
                }
                Catch {
        
                    Write-Error "An exception was caught: $($_.Exception.Message)"
                    
                    $err = $_.Exception.Message
        
                    $icon = $Global:Config.SonarQUBE.icon_error
        
                    $ResponseArray += " ${icon} *_${component}_* - ``${err}`` `n"
                    
                    $Send = $true
                    continue
                }
                if ($response.StatusCode -eq 200) {
                    $response = $response.Content | ConvertFrom-Json
        
                    if ($response.errors) {
                        $icon = $Global:Config.SonarQUBE.icon_error
                        $msg = $response.errors[0].msg 
                        $ResponseArray += " ${icon} *_${component}_* - ``${msg}`` `n"
                    }
                    else {
                        $Coverage = $response.measures[0].history[0].value 
                        ForEach ( $Threshold in $Global:Config.SonarQUBE.threshold) {
                            if ( [double]$Coverage -ge $Threshold.value ) {
                                $icon = $Threshold.icon
                                $ResponseArray += " ${icon} *_${component}_* - ``${Coverage}%`` `n"
                                if ($Threshold.alert -eq $true) {
                                    $Send = $true
                                }
                                break
                            }
                        } 
                    }
                }
            }
        }
    }

    if ($Send -eq $false) {
        $ResponseArray = $()
    }

    if ($ResponseArray.Count -gt 0) {
        return $ResponseArray
    }
}