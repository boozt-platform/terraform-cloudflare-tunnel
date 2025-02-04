<!-- markdownlint-disable -->
[<img src="https://raw.githubusercontent.com/boozt-platform/branding/main/assets/img/platform-logo.png" width="350"/>][homepage]

[![GitHub Tag (latest SemVer)](https://img.shields.io/github/v/tag/boozt-platform/terraform-cloudflare-tunnel.svg?label=latest&sort=semver)][releases]
[![license](https://img.shields.io/badge/license-mit-brightgreen.svg)][license]
<!-- markdownlint-restore -->

# terraform-cloudflare-tunnel

Terraform configurations to manage and deploy Cloudflare Tunnels, enabling
secure and seamless connectivity to private networks or applications. It
includes a modular structure, allowing users to customize and extend
functionality for various platforms and environments.

## Table of Contents

- [How to Use It](#how-to-use-it)
- [About Boozt](#about-boozt)
- [Reporting Issues](#reporting-issues)
- [Contributing](#contributing)
- [License](#license)

## How to Use It

```hcl
module "cloudflare_tunnel" {
    source  = "github.com/boozt-platform/terraform-cloudflare-tunnel"
    version = "1.1.0"

    tunnel_prefix_name = "tf-tunnel"
    tunnel_name = "my-tunnel"
    tunnel_config_src = "cloudflare"
    
    api_token = "optional-cloudflare-account-api-token"
    account_id  = "required-cloudflare-account-id"

    tunnel_config = {
        ingress_rules = [
            {
                hostname = "example.com"
                service  = "http://localhost:8080"
            },
            {
                hostname = "*.example.com"
                service  = "http://localhost:8080"
            }
        ]   
    }

    secret = "your-tunnel-secret"
}
```

## About Boozt

Boozt is a leading and fast-growing Nordic technology company selling fashion
and lifestyle online mainly through its multi-brand webstore [Boozt.com][boozt]
and [Booztlet.com][booztlet].

The company is focused on using cutting-edge, in-house developed technology to
curate the best possible customer experience.

With offices in Sweden, Denmark, Lithuania and Poland, we pride ourselves in
having a diverse team, consisting of 1100+ employees and 38 nationalities.

See our [Medium][blog] blog page for technology-focused articles. Would you
like to make your mark by working with us at Boozt? Take a look at our
[latest hiring opportunities][careers].

## Reporting Issues

Please provide a clear and concise description of the problem or the feature
you're missing along with any relevant context or screenshots.

Check existing issues before reporting to avoid duplicates.

Please follow the [Issue Reporting Guidelines][issues] before opening a new issue.

## Contributing

Contributions are highly valued and very welcome! For the process of reviewing
changes, we use [Pull Requests][pull-request]. For a detailed information
please follow the [Contribution Guidelines][contributing]

## License

[![license](https://img.shields.io/badge/license-mit-brightgreen.svg)][license]

This project is licensed under the MIT. Please see [LICENSE][license] for
full details.

[homepage]: https://github.com/boozt-platform/terraform-cloudflare-tunnel
[releases]: https://github.com/boozt-platform/terraform-cloudflare-tunnel/releases
[issues]: https://github.com/boozt-platform/terraform-cloudflare-tunnel/issues
[pull-request]: https://github.com/boozt-platform/terraform-cloudflare-tunnel/pulls
[contributing]: ./docs/CONTRIBUTING.md
[license]: ./LICENSE
[boozt]: https://www.boozt.com/
[booztlet]: https://www.booztlet.com/
[blog]: https://medium.com/boozt-tech
[careers]: https://careers.booztgroup.com/
