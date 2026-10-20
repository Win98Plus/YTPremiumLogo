# YouTube Premium Logo

This allows users to enable the YouTube Premium Logo because some tweak don't have it, i don't know why??? For YouTube iOS Only, not YouTube Android. 

## Package Contents

| Path | Format | Purpose |
|---|---|---|
| `PremiumYTLogo.x` | Logos source | Contains the tweak's hook implementations. |
| `Headers/PremiumYTLogo.h` | Objective-C header | Declares the tweak's interfaces. |
| `Makefile` | Theos build configuration | Defines the build configuration. |
| `control` | Debian package metadata | Defines package information for Theos packaging. |
| `PremiumYTLogo.plist` | Filter configuration | Defines the injection filter. |

## Installation

Choose the package that matches your environment.

### Rootful jailbreak

Install:

`Packages/com.win98plus.ytpremiumlogo_1.1.0_iphoneos-arm.deb`

The package targets the rootful MobileSubstrate tweak directory:

`/Library/MobileSubstrate/DynamicLibraries/`

### Rootless jailbreak

Install:

`Packages/com.win98plus.ytpremiumlogo_1.1.0_iphoneos-arm64.deb`

### LiveContainer

Use:

`LiveContainer/PremiumYTLogo.dylib`

## Building from Source

The package includes Theos source code

Required source files include:

- `PremiumYTLogo.x`
- `Headers/PremiumYTLogo.h`
- `Makefile`
- `control`
- `PremiumYTLogo.plist`

Install and configure Theos for the intended iOS packaging environment, then build the package using the included Makefile:

```sh
make package
```

The output depends on the local Theos configuration and package scheme. Build and test the rootful and rootless variants in their corresponding environments before distributing them.

## Compatibility Notes

- The tweak relies on YouTube's internal classes and methods. Compatibility may change when YouTube updates its implementation.
- The supported YouTube version range has not been specified here; test the tweak against the intended app version.

## Disclaimer

This project is not affiliated with or endorsed by Google, YouTube.

It is provided for research, code review and educational purposes. The source code and build files are provided without a guarantee of compatibility, correctness or continued support.
