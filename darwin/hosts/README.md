# Host-Specific Configurations

This directory contains host-specific configuration files for different machines.

## Usage

Host-specific configurations can be created by adding `.nix` files in this directory and importing them in your main configuration.

## Available Hosts

The flake supports the following predefined host configurations:

### Apple Silicon (M1/M2/M3)
- `mqmbp` - Maxime's MacBook Pro (Apple Silicon) - username: maxime
- `macbook-air-m1` - Generic MacBook Air M1 - username: maxime  
- `macbook-pro-m2` - Generic MacBook Pro M2 - username: developer

### Intel Macs
- `imac-intel` - Generic Intel iMac - username: maxime

### Default
- `default` - Fallback configuration - username: maxime

## Creating Custom Host Configurations

To add a new host, modify `flake.nix` and add an entry to the `darwinConfigurations` section:

```nix
"your-hostname" = mkDarwinSystem {
  hostname = "your-hostname";
  system = "aarch64-darwin"; # or "x86_64-darwin" for Intel
  username = "your-username";
  extraModules = [
    ./darwin/hosts/your-hostname.nix  # optional host-specific config
  ];
};
```

## Building for Different Hosts

```bash
# Build for specific host
darwin-rebuild switch --flake .#mqmbp

# Build for current hostname (if it exists in configurations)
darwin-rebuild switch --flake .

# Build using the default configuration
darwin-rebuild switch --flake .#default
```

## Host Detection

The installation script automatically detects the hostname using `scutil --get LocalHostName` and tries to build the corresponding configuration. If no matching configuration is found, it falls back to the `default` configuration.