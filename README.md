# SonarQUBE2Slack

This code is a simple bot.

This bot get a SonarQUBE coverage statistics and write in Slack channel.

This is very util to remember your team to see code coverage statistics.

This is a `powershell` code to run in linux you need install powershell or run in docker engine.

To windows environment run native or in docker engine too.

## build

`docker build --pull --rm -f "Dockerfile" -t sonarqube2slack:latest "."`

## run

`docker run --rm --name sonar2slack --volume c:\Temp\appsettings.json:/app/appsettings.json:ro  sonarqube2slack`

## appsettings.json - sample

```json
{
    "Slack": {
        "url": "https://hooks.slack.com/services/XXXXXXXXX/xxxxxxxxxxx/XxXxXxXxXxXxXxXxXxXxXxXx",
        "username": "Coverage Alert",
        "channel": "#sandbox",
        "icon_emoji": ":bomb:",
        "icon_url": "https://www.google.com/url?sa=i&url=https%3A%2F%2Ficonscout.com%2Ficon%2Fbomb-2413017&psig=AOvVaw0dmRJ3pPYnecKm99OkRRXS&ust=1598702745711000&source=images&cd=vfe&ved=0CAIQjRxqFwoTCIirs_3tvesCFQAAAAAdAAAAABAIs"
    },
    "SonarQUBE": {
        "url": "https://sonarqube.company.com.br/api/measures/search_history",
        "projects": [
            "project-one",
            "project-two"
        ],
        "threshold": [
            {
                "value": 80.0,
                "icon": ":sorriso_olhos_sorrindo:",
                "alert": false
            },
            {
                "value": 50.0,
                "icon": ":pensativo:",
                "alert": true
            },
            {
                "value": 0.0,
                "icon": ":bravo:",
                "alert": true
            }
        ],
        "icon_error": ":x:"
    }
}
```