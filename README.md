# Windows Service Action

This action will start, stop or restart a Windows service on a target Windows OS machine.

## Index <!-- omit in toc -->

- [Inputs](#inputs)
- [Prerequisites](#prerequisites)
- [Example](#example)
- [Contributing](#contributing)
  - [Incrementing the Version](#incrementing-the-version)
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

## Prerequisites

1. The target windows machine that will be running the service will need to have a WinRM SSL listener setup. This will have to be setup through a service ticket because a specifically formatted SSL certificate will need be set up in the correct certificate container.
2. A deployment service account will need to be created and put into the local admins group of the target server. This has to be done through a service desk ticket by an team.

## Example

```yml
...

env:
  WINDOWS_SERVER: 'win-server.domain.com'
  SERVICE_NAME: 'deploy-service'
  WINDOWS_SERVER_SERVICE_USER: 'server_service_user'
  WINDOWS_SERVER_SERVICE_PASSWORD: '${{ secrets.SERVER_SERVICE_SECRET }}'

jobs:
  Deploy-Service:
    runs-on: [windows-2019]
    steps:
      ...

      - name: Stop Service
        id: stop
        if: steps.zip.outcome == 'success'
        uses: im-open/windows-service-action@v2.0.2
        with:
          action: 'stop'
          server: ${{ env.WINDOWS_SERVER }}
          service-name: ${{ env.SERVICE_NAME }}
          service-account-id: ${{ env.WINDOWS_SERVER_SERVICE_USER }}
          service-account-password: ${{ env.WINDOWS_SERVER_SERVICE_PASSWORD }}
        continue-on-error: true
```

## Contributing

When creating new PRs please ensure:

1. For major or minor changes, at least one of the commit messages contains the appropriate `+semver:` keywords listed under [Incrementing the Version](#incrementing-the-version).
2. The `README.md` example has been updated with the new version.  See [Incrementing the Version](#incrementing-the-version).
3. The action code does not contain sensitive information.

### Incrementing the Version

This action uses [git-version-lite] to examine commit messages to determine whether to perform a major, minor or patch increment on merge.  The following table provides the fragment that should be included in a commit message to active different increment strategies.
| Increment Type | Commit Message Fragment                     |
| -------------- | ------------------------------------------- |
| major          | +semver:breaking                            |
| major          | +semver:major                               |
| minor          | +semver:feature                             |
| minor          | +semver:minor                               |
| patch          | *default increment type, no comment needed* |

## Code of Conduct

This project has adopted the [im-open's Code of Conduct](https://github.com/im-open/.github/blob/master/CODE_OF_CONDUCT.md).

## License

Copyright &copy; 2021, Extend Health, LLC. Code released under the [MIT license](LICENSE).

[git-version-lite]: https://github.com/im-open/git-version-lite