function restGet {
    $json = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json" -Headers $auth
    return $json
}

$doDownload = $false
$orgName = ''

$MyPat = ''
$B64Pat = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("`:$MyPat"))
$auth = @{}
#$auth = @{ Authorization = "Basic $B64Pat" }


$rootDir = Join-Path $env:HOME "proj"
$backupRootPath = Join-Path $rootDir $orgName
New-Item -ErrorAction SilentlyContinue -ItemType Directory -Path $backupRootPath

$urlbase = "https://dev.azure.com/$orgName"
$vrsmurlbase = "https://vsrm.dev.azure.com/$orgName"

$url = $urlbase + "/_apis/projects?api-version=7.0"
$projects = restGet

$output = @()
$pathPrefix = "/home/heas/proj/$orgName"

$projects.value | Sort-Object { $_.Name } | % {
    $projName = $_.Name
    $projPath = Join-Path $backupRootPath $projName
    New-Item -ErrorAction SilentlyContinue -ItemType Directory -Path $projPath
    Set-Location $projPath

    $wikiPath = Join-Path $projPath "wiki"    
    $url = $urlbase + "/$($projName)/_git/$($projName).wiki"
    if ($doDownload) {
        try {        
            if (-not (Test-Path $wikiPath)) {
                git -c http.extraHeader="Authorization: Basic $B64Pat" clone $url
            }
            else {
                Set-Location $wikiPath
                git -c http.extraHeader="Authorization: Basic $B64Pat" pull origin
            }
        }
        catch {        
        }
    }

    #pipelines
    $pipelinePath = Join-Path $projPath "_pipelines"
    New-Item -ErrorAction SilentlyContinue -ItemType Directory $pipelinePath
    Set-Location $pipelinePath
    $url = $urlbase + "/$projName/_apis/pipelines?api-version=7.0"
    if ($doDownload) {
        $response = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json" -Headers @{ Authorization = "Basic $B64Pat" }    
        $response.value | % {
            $id = $_.id
            $name = $_.name
            $url = $urlbase + "/$projName/_apis/build/definitions/$($id)/yaml?api-version=7.0"
            $json = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json" -Headers @{ Authorization = "Basic $B64Pat" }    
            $json.yaml | Out-File -Encoding utf8 -FilePath "$name.yaml"
        }
    }

    #releases
    $releasesPath = Join-Path $projPath "_releases"
    New-Item -ErrorAction SilentlyContinue -ItemType Directory $releasesPath
    Set-Location $releasesPath
    $url = $vrsmurlbase + "/$projName/_apis/release/definitions?api-version=7.0"
    if ($doDownload) {
        $response = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json" -Headers @{ Authorization = "Basic $B64Pat" }    
        $response.value | % {
            $id = $_.id
            $name = $_.name
            $url = $vrsmurlbase + "/$projName/_apis/release/definitions/$($id)?api-version=7.0"
            $json = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json" -Headers @{ Authorization = "Basic $B64Pat" }    
            $json | ConvertTo-Json -Depth 20 | Out-File -Encoding utf8 -FilePath "$name.json"
        }
    }

    $reposPath = Join-Path $projPath "repos"
    $outputReposPath = "$pathPrefix/$projName/repos"
    $output += "mkdir -p $outputReposPath"
    New-Item -ErrorAction SilentlyContinue -ItemType Directory $reposPath
    $url = $urlbase + "/$projName/_apis/git/repositories?api-version=7.0"
    $response = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json" -Headers @{ Authorization = "Basic $B64Pat" }       
    $response.value | % {
        $url = $_.webUrl
        $name = $_.name
        $br = $_.defaultBranch
        $gitPath = Join-Path $projPath $name

        if ($doDownload) {
            Set-Location $reposPath
            if (-not (Test-Path "$gitPath")) {
                git -c http.extraHeader="Authorization: Basic $B64Pat" clone $url    
            }
            else {
                Set-Location $gitPath
                git -c http.extraHeader="Authorization: Basic $B64Pat" pull origin $br
            }        
        }
        else {
            $output += "git clone $url $outputReposPath/$name"
        }
    }
}
$output | Set-Content (Join-Path $backupRootPath "gitclone.sh")