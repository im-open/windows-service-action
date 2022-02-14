Param(
    [parameter(Mandatory = $true)]
    [ValidateSet( 'start', 'stop', 'restart')]
    [string]$action,
    [parameter(Mandatory = $true)]
    [string]$service_name,
    [parameter(Mandatory = $true)]
    [string]$server,
    [parameter(Mandatory = $true)]
    [string]$user_id,
    [parameter(Mandatory = $true)]
    [SecureString]$password,
    [parameter(Mandatory = $true)]
    [string]$cert_path
)

$display_action = 'Windows Service'
$title_verb = (Get-Culture).TextInfo.ToTitleCase($action)

$display_action += " $title_verb"
$past_tense = "ed"
switch ($action) {
    "start" {}
    "restart" { break; }
    "stop" { $past_tense = "ped"; break; }
}
$display_action_past_tense = "$display_action$past_tense"

Write-Output $display_action

$credential = [PSCredential]::new($user_id, $password)
$so = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
$session = New-PSSession $server -SessionOption $so -UseSSL -Credential $credential

if ($cert_path.Length -gt 0) {
    Write-Output "Importing remote server cert..."
    Import-Certificate -Filepath $cert_path -CertStoreLocation 'Cert:\LocalMachine\Root'
}
$script = {
    # Relies on WebAdministration Module being installed on the remote server
    # This should be pre-installed on Windows 2012 R2 and later
    # https://docs.microsoft.com/en-us/powershell/module/?term=webadministration

    # Only try to stop if it exists
    $exists = Get-Service -Name $Using:service_name -ErrorAction 'SilentlyContinue'
    if ($exists) {
        if ($Using:action -eq 'stop' -or $Using:action -eq 'restart') {
            net stop $Using:service_name
        }
        if ($Using:action -eq 'start' -or $Using:action -eq 'restart') {
            net start $Using:service_name
        }
    }
    else {
        Write-Output "Service not found: $Using:service_name"
    }
}

Invoke-Command `
    -Session $session `
    -ScriptBlock $script

Write-Output "$display_action_past_tense."