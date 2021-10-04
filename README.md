# Windows Service Action

This action will start, stop or restart a Windows service on an on-prem Windows OS machine.

## Index <!-- omit in toc -->

- [Inputs](#inputs)
- [Prerequisites](#prerequisites)
- [Example](#example)
- [Code of Conduct](#code-of-conduct)
- [License](#license)

## Inputs

| Parameter                  | Is Required | Description                                              |
| -------------------------- | ----------- | -------------------------------------------------------- |
| `action`                   | true        | Specify start, stop, or restart action to perform        |
| `service-name`             | true        | The name of the Windows service to perform the action on |
| `server`                   | true        | The name of the target server                            |
| `service-account-id`       | true        | The service account name                                 |
| `service-account-password` | true        | The service account password                             |
| `server-public-key`        | true        | Path to remote server public ssl key                     |

## Prerequisites

The windows service action uses Web Services for Management, [WSMan], and Windows Remote Management, [WinRM], to create remote administrative sessions. Because of this, Windows OS GitHubs Actions Runners, `runs-on: [windows-2019]`, must be used. If the file deployment target is on a local network that is not publicly available, then specialized self hosted runners, `runs-on: [self-hosted, windows-2019]`,  will need to be used to broker deployment time access.

Inbound secure WinRm network traffic (TCP port 5986) must be allowed from the GitHub Actions Runners virtual network so that remote sessions can be received.

Prep the remote Windows server to accept WinRM management calls.  In general the Windows server needs to have a [WSMan] listener that looks for incoming [WinRM] calls. Firewall exceptions need to be added for the secure WinRM TCP ports, and non-secure firewall rules should be disabled. Here is an example script that would be run on the Windows server:

  ```powershell
  $Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName <<ip-address|fqdn-host-name>>

  Export-Certificate -Cert $Cert -FilePath C:\temp\<<cert-name>>

  Enable-PSRemoting -SkipNetworkProfileCheck -Force

  # Check for HTTP listeners
  dir wsman:\localhost\listener

  # If HTTP Listeners exist, remove them
  Get-ChildItem WSMan:\Localhost\listener | Where -Property Keys -eq "Transport=HTTP" | Remove-Item -Recurse

  # If HTTPs Listeners don't exist, add one
  New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint –Force

  # This allows old WinRm hosts to use port 443
  Set-Item WSMan:\localhost\Service\EnableCompatibilityHttpsListener -Value true

  # Make sure an HTTPs inbound rule is allowed
  New-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)" -Name "Windows Remote Management (HTTPS-In)" -Profile Any -LocalPort 5986 -Protocol TCP

  # For security reasons, you might want to disable the firewall rule for HTTP that *Enable-PSRemoting* added:
  Disable-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)"
  ```

- `ip-address` or `fqdn-host-name` can be used for the `DnsName` property in the certificate creation. It should be the name that the actions runner will use to call to the Windows server.
- `cert-name` can be any name.  This file will used to secure the traffic between the actions runner and the Windows server

## Example

```yml
...

env:
  WINDOWS_SERVER: 'win-server.domain.com'
  SERVICE_NAME: 'deploy-service'
  WINDOWS_SERVER_SERVICE_USER: 'server_service_user'
  WINDOWS_SERVER_SERVICE_PASSWORD: '${{ secrets.SERVER_SERVICE_SECRET }}'
  WINDOWS_SERVER_CERT_PATH: './server-connection-cert.pfx'

jobs:
  Deploy-Service:
    runs-on: [windows-2019]
    steps:
      ...

      - name: Stop Service
        id: stop
        if: steps.zip.outcome == 'success'
        uses: im-open/windows-service-action@initial-release
        with:
          action: 'stop'
          server: ${{ env.WINDOWS_SERVER }}
          service-name: ${{ env.SERVICE_NAME }}
          service-account-id: ${{ env.WINDOWS_SERVER_SERVICE_USER }}
          service-account-password: ${{ env.WINDOWS_SERVER_SERVICE_PASSWORD }}
          server-public-key: ${{ env.WINDOWS_SERVER_CERT_PATH }}
        continue-on-error: true
```

## Code of Conduct

This project has adopted the [im-open's Code of Conduct](https://github.com/im-open/.github/blob/master/CODE_OF_CONDUCT.md).

## License

Copyright &copy; 2021, Extend Health, LLC. Code released under the [MIT license](LICENSE).
