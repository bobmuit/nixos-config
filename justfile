# Set the shell to use (default is sh)
set shell := ["bash", "-cu"]

# Local machine

deploy:
    nixos-rebuild switch --flake ~/nixos-config#nixos-dell --sudo

deployhm: 
    home-manager switch --flake ~/nixos-config#bobmuit

debug:
    nixos-rebuild switch --flake ~/nixos-config#nixos-dell --sudo --show-trace --verbose

build:
    nixos-rebuild build --flake ~/nixos-config#nixos-dell --sudo

test:
    nixos-rebuild test --flake ~/nixos-config#nixos-dell --sudo

update:
    nix flake update

clean:
    # remove all generations older than 7 days
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d

gc:
    # garbage collect all unused nix store entries
    sudo nix-collect-garbage --delete-old

# Remote machines
syno: 
    ssh bobmuit@192.168.1.180

pi:
    ssh nixos@192.168.1.63

deploypi:
    nixos-rebuild switch --flake .#nixos-pi --target-host nixos@192.168.1.63 --sudo