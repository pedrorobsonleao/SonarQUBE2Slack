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
    Param(
        [Parameter(Mandatory = $true, Position = 0)]$Component
    )
    
    $IconError = $Global:Config.SonarQUBE.icon_error
    
    Try {
        $response =  Request-SonarQUBE  $Component
    }
    Catch {
        $ExceptionMessage = $_.Exception.Message
        throw " ${IconError} *_${Component}_* - ``${ExceptionMessage}`` `n"
    }

    if ($response.StatusCode -eq 200) {
        $response = $response.Content | ConvertFrom-Json
        
        if ($response.errors) {
            $ErrorMessage = $response.errors[0].msg
            throw " ${IconError} *_${Component}_* - ``${ErrorMessage}`` `n"
        }

        Try {
            $response =  Request-SonarQUBE  $component -PageIndex  $response.paging.total
        }
        Catch {
            $ExceptionMessage = $_.Exception.Message
            throw " ${IconError} *_${Component}_* - ``${ExceptionMessage}`` `n"
        }
        
        if ($response.StatusCode -eq 200) {
            $response = $response.Content | ConvertFrom-Json
            
            if ($response.errors) {
                $ErrorMessage = $response.errors[0].msg
                throw " ${IconError} *_${Component}_* - ``${ErrorMessage}`` `n"
            }

            $Coverage = $response.measures[0].history[0].value 
            ForEach ( $Threshold in $Global:Config.SonarQUBE.threshold) {
                if ( [double]$Coverage -ge $Threshold.value ) {
                    if ($Threshold.alert -eq $false) {
                        throw "ThresholdAlertException"
                    } else {
                        $IconSuccess=$Threshold.icon
                        return " ${IconSuccess} *_${Component}_* - ``${Coverage}%`` `n"
                    }
                    break
                }
            } 
        }

    }
}