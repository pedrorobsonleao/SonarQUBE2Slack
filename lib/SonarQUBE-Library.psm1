$Global:Coverage = 0.0
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

function Reset-Coverage {
    $Global:Coverage = 0.0
}
function Get-Coverage {
    return $Global:Coverage
}
function Get-SonarQUBE {
    Param(
        [Parameter(Mandatory = $true, Position = 0)]$Component
    )
    
    $IconError = $Global:Config.SonarQUBE.icon_error
    $Url = $Global:Config.SonarQUBE.url

    $Hiperlink = $Url.Split("/")[0] + "//" + ` #protocol
                 $Url.Split("/")[2] + "/" +  ` #host
                 "dashboard?id=" + $Component
    
    Try {
        $response =  Request-SonarQUBE  $Component
    }
    Catch {
        $ExceptionMessage = $_.Exception.Message
        throw " ${IconError} *_<${Hiperlink}|${Component}>_* - ``${ExceptionMessage}`` `n"
    }

    if ($response.StatusCode -eq 200) {
        $response = $response.Content | ConvertFrom-Json
        
        if ($response.errors) {
            $ErrorMessage = $response.errors[0].msg
            throw " ${IconError} *_<${Hiperlink}|${Component}>_* - ``${ErrorMessage}`` `n"
        }

        Try {
            $response =  Request-SonarQUBE  $component -PageIndex  $response.paging.total
        }
        Catch {
            $ExceptionMessage = $_.Exception.Message
            throw " ${IconError} *_<${Hiperlink}|${Component}>_* - ``${ExceptionMessage}`` `n"
        }
        
        if ($response.StatusCode -eq 200) {
            $response = $response.Content | ConvertFrom-Json
            
            if ($response.errors) {
                $ErrorMessage = $response.errors[0].msg
                throw " ${IconError} *_<${Hiperlink}|${Component}>_* - ``${ErrorMessage}`` `n"
            }

            $_Coverage = [double]$response.measures[0].history[0].value
            $Global:Coverage +=  $_Coverage
            ForEach ( $Threshold in $Global:Config.SonarQUBE.threshold) {
                if ( $_Coverage -ge $Threshold.value ) {
                    if ($Threshold.alert -eq $false) {
                        throw "ThresholdAlertException"
                    } else {
                        $IconSuccess=$Threshold.icon
                        $_Coverage = ($_Coverage).ToString("000.0")
                        return " ${IconSuccess} ``${_Coverage}%`` - *_<${Hiperlink}|${Component}>_*`n"
                    }
                    break
                }
            } 
        }

    }
}