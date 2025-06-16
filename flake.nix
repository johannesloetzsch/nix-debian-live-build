{
  description = "debian live-build by nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let 
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in
  {
    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        util-linux
        debootstrap
        wget
      ];
      shellHook = ''
        export LIVE_BUILD=$(pwd)
        PATH=$PATH:$LIVE_BUILD/frontend:$LIVE_BUILD/scripts:$LIVE_BUILD/scripts/build

        sed -i 's@/sbin/fdisk@${pkgs.util-linux}/bin/fdisk@' functions/defaults.sh
        sed -i 's@/sbin/losetup@${pkgs.util-linux}/bin/losetup@' functions/defaults.sh
        sed -i 's@/usr/sbin/debootstrap@${pkgs.debootstrap}/bin/debootstrap@' scripts/build/bootstrap_debootstrap
        sed -i 's@/usr/bin/wget@${pkgs.wget}/bin/wget@' scripts/build/chroot_firmware

        LB_SECURITY="false"  ## Hotfix E: The repository 'http://security.debian.org bookworm/updates Release' does not have a Release file.
        lb config --distribution bookworm --security $LB_SECURITY

        lb clean
        lb build

        ls -lh *.iso
      '';
    };
  };
}
